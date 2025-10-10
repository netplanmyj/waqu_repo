import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wq_report/config/keys.dart';
import 'package:wq_report/services/history_service.dart';
import 'package:wq_report/services/settings_service.dart';

// ステップ1で取得したGASのWebアプリURLに置き換えてください
const String gasUrl = gasWebAppURL;

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
  // 1. 日次チェック
  if (await isSentToday()) {
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
    // 2. 設定を取得
    final settings = await SettingsService.getSettings();

    // 3. 送信データの準備
    final now = DateTime.now();
    final monthDay =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final chlorineFormatted = chlorine.toStringAsFixed(2);

    // デバッグモードに応じて送信先を決定
    final recipientEmail = settings.isDebugMode
        ? settings.testRecipientEmail
        : settings.recipientEmail;

    // 4. GASへのリクエスト
    final client = http.Client();
    final uri = Uri.parse(gasUrl).replace(
      queryParameters: {
        'monthDay': monthDay,
        'time': time,
        'chlorine': chlorineFormatted,
        'locationNumber': settings.locationNumber,
        'recipientEmail': recipientEmail,
        'debugMode': settings.isDebugMode.toString(),
      },
    );

    final response = await client.get(uri);
    client.close();

    // 200 (OK) と 302 (Found/Redirect) の両方を成功として扱う
    if (response.statusCode == 200 || response.statusCode == 302) {
      String jsonResponseBody = response.body;

      // 302の場合、レスポンスボディが空の可能性があるため、成功とみなす
      if (response.statusCode == 302 || jsonResponseBody.isEmpty) {
        // 成功時：最終送信日を保存
        final prefs = await SharedPreferences.getInstance();
        final currentDate = DateTime.now();
        await prefs.setString(lastSentDateKey, currentDate.toIso8601String());

        // 履歴に保存
        await HistoryService.addHistory(
          date: currentDate,
          time: time,
          chlorine: chlorine,
          success: true,
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
          // 成功時：最終送信日を保存
          final prefs = await SharedPreferences.getInstance();
          final currentDate = DateTime.now();
          await prefs.setString(lastSentDateKey, currentDate.toIso8601String());

          // 履歴に保存
          await HistoryService.addHistory(
            date: currentDate,
            time: time,
            chlorine: chlorine,
            success: true,
          );

          // 設定を再取得してメッセージに含める
          final currentSettings = await SettingsService.getSettings();
          final modeMessage = currentSettings.isDebugMode
              ? '（テストモード: ${currentSettings.testRecipientEmail}）'
              : '（通常モード: ${currentSettings.recipientEmail}）';

          return 'メールが正常に送信されました。$modeMessage';
        } else {
          // 送信失敗時も履歴に保存
          await HistoryService.addHistory(
            date: DateTime.now(),
            time: time,
            chlorine: chlorine,
            success: false,
          );
          return '送信に失敗しました: ${jsonResponse['message']}';
        }
      } catch (e) {
        // JSONパースエラーの場合も成功とみなす（302リダイレクトの可能性）
        final prefs = await SharedPreferences.getInstance();
        final currentDate = DateTime.now();
        await prefs.setString(lastSentDateKey, currentDate.toIso8601String());

        // 履歴に保存
        await HistoryService.addHistory(
          date: currentDate,
          time: time,
          chlorine: chlorine,
          success: true,
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
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: time,
        chlorine: chlorine,
        success: false,
      );
      return 'サーバーエラーが発生しました (ステータスコード: ${response.statusCode})';
    }
  } catch (e) {
    // 通信エラー時も履歴に保存
    await HistoryService.addHistory(
      date: DateTime.now(),
      time: time,
      chlorine: chlorine,
      success: false,
    );
    return '通信エラーが発生しました: $e';
  }
}
