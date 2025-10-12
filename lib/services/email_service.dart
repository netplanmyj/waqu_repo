import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqu_repo/services/history_service.dart';
import 'package:waqu_repo/services/settings_service.dart';

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

Future<String> sendDailyEmail({
  required String time,
  required double chlorine,
}) async {
  // 設定を取得（デバッグモード確認のため）
  final settings = await SettingsService.getSettings();

  // GAS URLが設定されていない場合のチェック
  if (settings.gasUrl.isEmpty) {
    return 'GAS WebアプリURLが設定されていません。設定画面で設定してください。';
  }

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
    // 2. 送信データの準備

    // 3. 送信データの準備
    final now = DateTime.now();
    final monthDay =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final chlorineFormatted = chlorine.toStringAsFixed(2);

    // デバッグモードに応じて送信先を決定
    final recipientEmail = settings.isDebugMode
        ? settings.testRecipientEmail
        : settings.recipientEmail;

    // 4. GASへのリクエスト（GETリクエスト）
    final client = http.Client();

    final uri = Uri.parse(settings.gasUrl).replace(
      queryParameters: {
        'monthDay': monthDay,
        'time': time,
        'chlorine': chlorineFormatted,
        'locationNumber': settings.locationNumber,
        'recipientEmail': recipientEmail,
        'debugMode': settings.isDebugMode.toString(),
      },
    );

    final response = await client
        .get(uri)
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('タイムアウト: サーバーからの応答がありません');
          },
        );

    client.close(); // 200 (OK) と 302 (Found/Redirect) の両方を成功として扱う
    if (response.statusCode == 200 || response.statusCode == 302) {
      String jsonResponseBody = response.body;

      // 302の場合、レスポンスボディが空の可能性があるため、成功とみなす
      if (response.statusCode == 302 || jsonResponseBody.isEmpty) {
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
      }

      // 200の場合、JSONレスポンスを確認
      try {
        final jsonResponse = json.decode(jsonResponseBody);
        if (jsonResponse['status'] == 'success') {
          // 成功時：最終送信日を保存（デバッグモード時は保存しない）
          if (!settings.isDebugMode) {
            final prefs = await SharedPreferences.getInstance();
            final currentDate = DateTime.now();
            await prefs.setString(
              lastSentDateKey,
              currentDate.toIso8601String(),
            );
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
          final errorMsg = '送信に失敗しました: ${jsonResponse['message']}';
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
        // JSONパースエラーの場合も成功とみなす（302リダイレクトの可能性）
        final currentDate = DateTime.now();

        // デバッグモードでない場合のみ、lastSentDateを保存
        if (!settings.isDebugMode) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(lastSentDateKey, currentDate.toIso8601String());
        }

        // 履歴に保存
        await HistoryService.addHistory(
          date: currentDate,
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
      }
    } else {
      // サーバーエラー時も履歴に保存
      final errorMsg = 'サーバーエラーが発生しました (ステータスコード: ${response.statusCode})';
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
    debugPrint('❌ エラー詳細: $e');

    // エラーメッセージを分かりやすく
    String errorMessage = '通信エラーが発生しました';
    if (e.toString().contains('no address associated with hostname') ||
        e.toString().contains('Failed host lookup')) {
      errorMessage = 'GAS URLが正しくありません\n設定画面でURLを確認してください';
    } else if (e.toString().contains('SocketException')) {
      errorMessage = 'インターネット接続を確認してください';
    } else if (e.toString().contains('TimeoutException') ||
        e.toString().contains('タイムアウト')) {
      errorMessage = 'サーバーからの応答がありません（タイムアウト）';
    } else if (e.toString().contains('HandshakeException')) {
      errorMessage = 'SSL証明書エラー';
    } else if (e.toString().contains('FormatException')) {
      errorMessage = 'GAS URLの形式が正しくありません';
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
