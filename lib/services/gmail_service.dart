import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqu_repo/services/history_service.dart';
import 'package:waqu_repo/services/settings_service.dart';
import 'package:waqu_repo/services/auth_service.dart';

// 日付を保存するキー
const String lastSentDateKey = 'lastSentDate';

// ネットワークエラーが再試行可能かどうかを判定
bool _isRetriableNetworkError(dynamic error) {
  if (error is FirebaseFunctionsException) {
    const retriableCodes = {
      'deadline-exceeded',
      'unavailable',
      'resource-exhausted',
      'internal',
      'unknown',
    };
    return retriableCodes.contains(error.code);
  }

  final errorString = error.toString().toLowerCase();
  // ネットワーク関連エラー、タイムアウト、一時的なエラーは再試行可能
  return errorString.contains('network') ||
      errorString.contains('timeout') ||
      errorString.contains('interrupted') ||
      errorString.contains('unreachable') ||
      errorString.contains('connection') ||
      errorString.contains('network-request-failed') ||
      errorString.contains('unavailable') ||
      errorString.contains('deadline-exceeded');
}

Future<bool> isSentToday() async {
  final prefs = await SharedPreferences.getInstance();
  final lastDateString = prefs.getString(lastSentDateKey);

  if (lastDateString == null) return false;

  final lastDate = DateTime.parse(lastDateString);
  final now = DateTime.now();

  // 今日送信済みならtrueを返す
  return lastDate.year == now.year &&
      lastDate.month == now.month &&
      lastDate.day == now.day;
}

Future<String> sendDailyEmail({
  required String time,
  required double chlorine,
}) async {
  final overallStopwatch = Stopwatch()..start();
  bool overallLogged = false;

  String finishWithLog(String message) {
    if (!overallLogged) {
      overallLogged = true;
      overallStopwatch.stop();
      debugPrint('⏱️ 送信処理合計: ${overallStopwatch.elapsedMilliseconds}ms');
    }
    return message;
  }

  // 認証チェック
  if (!AuthService.isSignedIn) {
    return finishWithLog('Googleアカウントにサインインしてください。');
  }

  // 設定を取得（デバッグモード確認のため）
  final settings = await SettingsService.getSettings();

  // 1. 日次チェック（デバッグモード時はスキップ）
  if (!settings.isDebugMode && await isSentToday()) {
    // 送信済みの日付を取得してメッセージに含める
    final prefs = await SharedPreferences.getInstance();
    final lastDateString = prefs.getString(lastSentDateKey);

    if (lastDateString != null) {
      final lastDate = DateTime.parse(lastDateString);
      return finishWithLog('${lastDate.month}月${lastDate.day}日は送信済みです。');
    } else {
      return finishWithLog('既に本日の送信は完了しています。');
    }
  }

  try {
    // 2. Gmail APIアクセス用のクレデンシャルを取得
    final gmailStopwatch = Stopwatch()..start();
    final credentials = await AuthService.getGmailCredentials();
    gmailStopwatch.stop();
    debugPrint('⏱️ Gmail認証情報取得: ${gmailStopwatch.elapsedMilliseconds}ms');

    if (credentials == null) {
      debugPrint('❌ Gmail認証情報を取得できませんでした');
      return finishWithLog('Gmail送信権限がありません。設定画面から「Gmail権限を再取得」を試してください。');
    }

    // トークンの有効期限チェック（UTCで比較）
    if (credentials.accessToken.expiry.isBefore(DateTime.now().toUtc())) {
      debugPrint('❌ アクセストークンが期限切れです');
      return finishWithLog('アクセストークンの有効期限が切れています。設定画面から「Gmail権限を再取得」を試してください。');
    }

    // 3. 送信データの準備
    final now = DateTime.now();
    final monthDay =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final chlorineFormatted = chlorine.toStringAsFixed(2);

    // デバッグモードに応じて送信先を決定
    final recipientEmail = settings.isDebugMode
        ? settings.testRecipientEmail
        : settings.recipientEmail;

    if (recipientEmail.isEmpty) {
      return finishWithLog(
        settings.isDebugMode
            ? 'テスト送信先メールアドレスが設定されていません。'
            : '送信先メールアドレスが設定されていません。',
      );
    }

    // 4. Firebase Functions呼び出し（リトライロジック付き）
    const maxRetries = 3;
    const timeout = Duration(seconds: 90);
    Map<String, dynamic>? data;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('🔄 メール送信試行 ${attempt + 1}/$maxRetries');

        // リージョンを明示的に指定（us-central1）
        final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
        final callable = functions.httpsCallable(
          'sendWaterQualityEmail',
          options: HttpsCallableOptions(timeout: timeout),
        );

        final functionsStopwatch = Stopwatch()..start();
        final result = await callable.call<Map<String, dynamic>>({
          'monthDay': monthDay,
          'time': time,
          'chlorine': chlorineFormatted,
          'locationNumber': settings.locationNumber,
          'emailSubject': settings.emailSubject, // 件名を追加
          'recipientEmail': recipientEmail,
          'debugMode': settings.isDebugMode,
          'accessToken': credentials.accessToken.data,
        });
        functionsStopwatch.stop();
        debugPrint(
          '⏱️ Functions呼び出し: ${functionsStopwatch.elapsedMilliseconds}ms',
        );

        data = result.data;
        debugPrint('✅ Firebase Functions呼び出し成功');
        break; // 成功したのでループを抜ける
      } catch (e) {
        debugPrint(
          '❌ Firebase Functions呼び出しエラー (試行 ${attempt + 1}/$maxRetries): $e',
        );

        // 最後の試行でない場合、かつネットワークエラーの場合のみリトライ
        if (attempt < maxRetries - 1 && _isRetriableNetworkError(e)) {
          // 指数バックオフで待機（1秒, 2秒, 4秒, ...）
          final waitTime = Duration(seconds: 1 << attempt);
          debugPrint('⏳ ${waitTime.inSeconds}秒後に再試行します...');
          await Future<void>.delayed(waitTime);
          continue;
        }

        // 再試行できない、またはすべての試行が失敗した場合
        rethrow;
      }
    }

    // データがnullの場合（すべての試行が失敗）
    if (data == null) {
      throw Exception('メール送信に失敗しました: 最大試行回数に達しました');
    }

    if (data['status'] == 'success') {
      // 成功時：最終送信日を保存（デバッグモード時は保存しない）
      if (!settings.isDebugMode) {
        final prefs = await SharedPreferences.getInstance();
        final currentDate = DateTime.now();
        await prefs.setString(lastSentDateKey, currentDate.toIso8601String());
      }

      // 履歴に保存
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: time,
        chlorine: chlorine,
        success: true,
        isDebugMode: settings.isDebugMode,
      );

      // 設定を再取得してメッセージに含める
      final currentSettings = await SettingsService.getSettings();
      final modeMessage = currentSettings.isDebugMode
          ? '（テストモード: ${currentSettings.testRecipientEmail}）'
          : '（通常モード: ${currentSettings.recipientEmail}）';

      return finishWithLog('メールが正常に送信されました。$modeMessage');
    } else {
      // 送信失敗時も履歴に保存
      final errorMsg = '送信に失敗しました: ${data['message']}';
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: time,
        chlorine: chlorine,
        success: false,
        isDebugMode: settings.isDebugMode,
        errorMessage: errorMsg,
      );
      return finishWithLog(errorMsg);
    }
  } catch (e) {
    debugPrint('❌ Firebase Functions エラー: $e');

    // エラーメッセージを分かりやすく
    String errorMessage = 'メール送信に失敗しました';

    if (e.toString().contains('unauthenticated')) {
      errorMessage = '認証が失敗しました。設定画面から「Gmail権限を再取得」を試してください。';
    } else if (e.toString().contains('permission-denied')) {
      errorMessage = 'Gmail送信権限がありません。設定を確認してください。';
    } else if (e.toString().contains('invalid-argument')) {
      errorMessage = '送信パラメータに誤りがあります。';
    } else if (e.toString().contains('resource-exhausted')) {
      errorMessage = '送信制限に達しました。しばらく時間をおいてから再試行してください。';
    } else if (e.toString().contains('FirebaseFunctionsException')) {
      // Firebase Functionsの詳細エラーを抽出
      try {
        final errorString = e.toString();
        final start = errorString.indexOf('message:') + 8;
        final end = errorString.indexOf(',', start);
        if (start > 7 && end > start) {
          errorMessage = errorString.substring(start, end).trim();
        }
      } catch (_) {
        errorMessage = 'Firebase Functions呼び出しエラー';
      }
    } else if (e.toString().contains('network-request-failed')) {
      errorMessage = 'ネットワークエラーが発生しました。インターネット接続を確認して、再度お試しください。';
    } else if (e.toString().contains('timeout')) {
      errorMessage = '通信がタイムアウトしました。しばらく時間をおいてから再度お試しください。';
    } else if (e.toString().contains('network')) {
      errorMessage = 'インターネット接続を確認してください';
    } else if (e.toString().contains('unavailable')) {
      errorMessage = 'サービスが一時的に利用できません。しばらく時間をおいてから再度お試しください。';
    }

    final fullErrorMessage = '$errorMessage\n\n技術詳細: ${e.toString()}';

    // 通信エラー時も履歴に保存
    await HistoryService.addHistory(
      date: DateTime.now(),
      time: time,
      chlorine: chlorine,
      success: false,
      isDebugMode: settings.isDebugMode,
      errorMessage: fullErrorMessage,
    );

    return finishWithLog(fullErrorMessage);
  }
}
