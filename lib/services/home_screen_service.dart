import 'package:shared_preferences/shared_preferences.dart';
import 'gmail_service.dart';
import 'settings_service.dart';
import 'history_service.dart';

/// ホーム画面のビジネスロジックを管理するサービスクラス
class HomeScreenService {
  /// 本日の送信状態を確認
  static Future<Map<String, dynamic>> checkSentStatus() async {
    final settings = await SettingsService.getSettings();
    final locationNumber = settings.locationNumber;
    final isDebugMode = settings.isDebugMode;

    // デバッグモードの場合は常に送信可能
    if (isDebugMode) {
      return {
        'isSentToday': false,
        'message': '【デバッグモード】何度でも送信できます',
        'locationNumber': locationNumber,
        'isDebugMode': true,
      };
    }

    // 通常モードの場合、送信済み状態を確認
    final wasAlreadySent = await isSentToday();

    if (wasAlreadySent) {
      final prefs = await SharedPreferences.getInstance();
      final lastDateString = prefs.getString('lastSentDate');

      String message = '本日は送信済みです';
      if (lastDateString != null) {
        final lastDate = DateTime.parse(lastDateString);
        message = '${lastDate.month}月${lastDate.day}日に送信済みです';
      }

      return {
        'isSentToday': true,
        'message': message,
        'locationNumber': locationNumber,
        'isDebugMode': false,
      };
    }

    return {
      'isSentToday': false,
      'message': 'データを入力して送信ボタンを押してください',
      'locationNumber': locationNumber,
      'isDebugMode': false,
    };
  }

  /// メール送信処理を実行
  static Future<String> sendEmail({
    required String time,
    required double chlorine,
  }) async {
    // 通常モード: 実際に送信
    return await sendDailyEmail(time: time, chlorine: chlorine);
  }

  /// 最新の送信履歴を取得
  static Future<EmailHistory?> getLastHistory() async {
    final histories = await HistoryService.getHistories();
    return histories.isNotEmpty ? histories.first : null;
  }
}
