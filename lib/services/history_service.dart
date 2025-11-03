import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmailHistory {
  final DateTime date;
  final String time;
  final double chlorine;
  final bool success;
  final bool isDebugMode;
  final String? errorMessage; // エラーメッセージ（失敗時のみ）

  EmailHistory({
    required this.date,
    required this.time,
    required this.chlorine,
    required this.success,
    this.isDebugMode = false, // デフォルトはfalse（既存データとの互換性のため）
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'chlorine': chlorine,
      'success': success,
      'isDebugMode': isDebugMode,
      'errorMessage': errorMessage,
    };
  }

  factory EmailHistory.fromJson(Map<String, dynamic> json) {
    return EmailHistory(
      date: DateTime.parse(json['date']),
      time: json['time'],
      chlorine: json['chlorine'],
      success: json['success'],
      isDebugMode: json['isDebugMode'] ?? false, // 既存データとの互換性のため
      errorMessage: json['errorMessage'],
    );
  }
}

class HistoryService {
  static const String historyKey = 'email_history';
  static const int retentionYears = 1; // 保存期間: 1年間

  // 履歴を保存
  static Future<void> addHistory({
    required DateTime date,
    required String time,
    required double chlorine,
    required bool success,
    bool isDebugMode = false,
    String? errorMessage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    // 新しい履歴を追加
    final newHistory = EmailHistory(
      date: date,
      time: time,
      chlorine: chlorine,
      success: success,
      isDebugMode: isDebugMode,
      errorMessage: errorMessage,
    );

    histories.add(newHistory);

    // 日付順でソート（新しい順）
    histories.sort((a, b) => b.date.compareTo(a.date));

    // 1年以上前のデータを削除（閏年を考慮）
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - retentionYears, now.month, now.day);
    histories.removeWhere((history) => history.date.isBefore(oneYearAgo));

    // SharedPreferencesに保存
    final historyJsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(historyKey, json.encode(historyJsonList));
  }

  // 履歴を取得
  static Future<List<EmailHistory>> getHistories() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(historyKey);

    if (historyJson == null) return [];

    try {
      final List<dynamic> historyList = json.decode(historyJson);
      var histories = historyList
          .map((json) => EmailHistory.fromJson(json))
          .toList();

      // 1年以上前のデータを自動削除（閏年を考慮）
      final now = DateTime.now();
      final oneYearAgo = DateTime(
        now.year - retentionYears,
        now.month,
        now.day,
      );
      final validHistories = histories
          .where((history) => history.date.isAfter(oneYearAgo))
          .toList();

      // 古いデータが削除された場合は保存し直す
      if (validHistories.length != histories.length) {
        final historyJsonList = validHistories.map((h) => h.toJson()).toList();
        await prefs.setString(historyKey, json.encode(historyJsonList));
      }

      return validHistories;
    } catch (e) {
      return [];
    }
  }

  // 特定の日付の履歴を取得
  static Future<EmailHistory?> getHistoryByDate(DateTime date) async {
    final histories = await getHistories();

    for (final history in histories) {
      if (history.date.year == date.year &&
          history.date.month == date.month &&
          history.date.day == date.day) {
        return history;
      }
    }
    return null;
  }

  // 特定の履歴を削除
  static Future<void> deleteHistory(EmailHistory historyToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final histories = await getHistories();

    // 削除対象の履歴を除外
    histories.removeWhere(
      (history) =>
          history.date.isAtSameMomentAs(historyToDelete.date) &&
          history.time == historyToDelete.time &&
          history.chlorine == historyToDelete.chlorine,
    );

    // SharedPreferencesに保存
    final historyJsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(historyKey, json.encode(historyJsonList));
  }

  // 履歴をクリア（テスト用）
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
  }
}
