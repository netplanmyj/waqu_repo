import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wq_report/config/keys.dart';

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
    // 2. 送信データの準備
    final now = DateTime.now();
    final monthDay =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final chlorineFormatted = chlorine.toStringAsFixed(2);

    // 3. GASへのリクエスト
    final client = http.Client();
    final response = await client.post(
      Uri.parse(gasUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'monthDay': monthDay, 'time': time, 'chlorine': chlorineFormatted},
    );
    client.close();

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse['status'] == 'success') {
        // 3. 成功時：最終送信日を保存
        final prefs = await SharedPreferences.getInstance();
        final currentDate = DateTime.now().toIso8601String();
        await prefs.setString(lastSentDateKey, currentDate);
        return 'メールが正常に送信されました。';
      } else {
        return '送信に失敗しました: ${jsonResponse['message']}';
      }
    } else {
      return 'サーバーエラーが発生しました (ステータスコード: ${response.statusCode})';
    }
  } catch (e) {
    return '通信エラーが発生しました: $e';
  }
}
