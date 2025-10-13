import 'package:shared_preferences/shared_preferences.dart';
import 'package:waqu_repo/services/firebase_email_service.dart';

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

// メイン関数 - Firebase版を使用
Future<String> sendDailyEmail({
  required String time,
  required double chlorine,
}) async {
  // Firebase版のメール送信を使用
  return await sendDailyEmailWithFirebase(time: time, chlorine: chlorine);
}
