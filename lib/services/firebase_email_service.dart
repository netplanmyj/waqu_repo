import 'package:flutter/foundation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqu_repo/services/history_service.dart';
import 'package:waqu_repo/services/settings_service.dart';
import 'package:waqu_repo/services/auth_service.dart';

// 日付を保存するキー
const String lastSentDateKey = 'lastSentDate';

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

Future<String> sendDailyEmailWithFirebase({
  required String time,
  required double chlorine,
}) async {
  // 認証チェック
  if (!AuthService.isSignedIn) {
    return 'Googleアカウントにサインインしてください。';
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
      return '${lastDate.month}月${lastDate.day}日は送信済みです。';
    } else {
      return '既に本日の送信は完了しています。';
    }
  }

  try {
    // 2. Gmail APIアクセス用のクレデンシャルを取得
    final credentials = await AuthService.getGmailCredentials();
    if (credentials == null) {
      return 'Gmail送信権限がありません。認証し直してください。';
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
      return settings.isDebugMode
          ? 'テスト送信先メールアドレスが設定されていません。'
          : '送信先メールアドレスが設定されていません。';
    }

    // 4. Firebase Functions呼び出し
    final functions = FirebaseFunctions.instance;
    final callable = functions.httpsCallable('sendWaterQualityEmail');

    final result = await callable.call({
      'monthDay': monthDay,
      'time': time,
      'chlorine': chlorineFormatted,
      'locationNumber': settings.locationNumber,
      'recipientEmail': recipientEmail,
      'debugMode': settings.isDebugMode,
      'accessToken': credentials.accessToken.data,
    });

    final data = result.data as Map<String, dynamic>;

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

      return 'メールが正常に送信されました。$modeMessage';
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
      return errorMsg;
    }
  } catch (e) {
    debugPrint('❌ Firebase Functions エラー詳細: $e');

    // エラーメッセージを分かりやすく
    String errorMessage = 'メール送信に失敗しました';

    if (e.toString().contains('unauthenticated')) {
      errorMessage = '認証が失敗しました。再ログインしてください。';
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
    } else if (e.toString().contains('network')) {
      errorMessage = 'インターネット接続を確認してください';
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

    return fullErrorMessage;
  }
}

// 後方互換性のための関数（既存のGAS版）
Future<String> sendDailyEmail({
  required String time,
  required double chlorine,
}) async {
  // Firebase版を使用
  return await sendDailyEmailWithFirebase(time: time, chlorine: chlorine);
}
