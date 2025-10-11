import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EmailHistory {
  final DateTime date;
  final String time;
  final double chlorine;
  final bool success;
  final bool isDebugMode;

  EmailHistory({
    required this.date,
    required this.time,
    required this.chlorine,
    required this.success,
    this.isDebugMode = false, // デフォルトはfalse（既存データとの互換性のため）
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'chlorine': chlorine,
      'success': success,
      'isDebugMode': isDebugMode,
    };
  }

  factory EmailHistory.fromJson(Map<String, dynamic> json) {
    return EmailHistory(
      date: DateTime.parse(json['date']),
      time: json['time'],
      chlorine: json['chlorine'],
      success: json['success'],
      isDebugMode: json['isDebugMode'] ?? false, // 既存データとの互換性のため
    );
  }
}

class HistoryService {
  static const String historyKey = 'email_history';
  static const int maxHistoryCount = 50; // 直近50件

  // 履歴を保存
  static Future<void> addHistory({
    required DateTime date,
    required String time,
    required double chlorine,
    required bool success,
    bool isDebugMode = false,
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
    );

    histories.add(newHistory);

    // 日付順でソート（新しい順）
    histories.sort((a, b) => b.date.compareTo(a.date));

    // 直近50件のみ保持（古いものを削除）
    if (histories.length > maxHistoryCount) {
      histories.removeRange(maxHistoryCount, histories.length);
    }

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
      return historyList.map((json) => EmailHistory.fromJson(json)).toList();
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

  // 履歴をクリア（テスト用）
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
  }
}
