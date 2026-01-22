// 履歴サービスのテスト（最小限版）

import 'package:flutter_test/flutter_test.dart';
import '../lib/services/history_service.dart';

void main() {
  group('履歴サービス基本テスト', () {
    test('基本的なデータ構造のテスト', () {
      // シンプルなマップデータのテスト
      final entry = {
        'time': '0950',
        'chlorine': 0.45,
        'location': '01',
        'recipient': 'test@example.com',
      };

      expect(entry['time'], '0950');
      expect(entry['chlorine'], 0.45);
      expect(entry['location'], '01');
      expect(entry['recipient'], 'test@example.com');
    });

    test('EmailHistory のデータ構造テスト', () {
      final now = DateTime.now();
      final history = EmailHistory(
        date: now,
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      expect(history.date, now);
      expect(history.time, '0950');
      expect(history.chlorine, 0.45);
      expect(history.success, true);
      expect(history.isDebugMode, false);
      expect(history.errorMessage, null);
    });

    test('EmailHistory の JSON 変換テスト', () {
      final testDate = DateTime(2025, 11, 3, 9, 50);
      final history = EmailHistory(
        date: testDate,
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
        errorMessage: null,
      );

      // JSON に変換
      final json = history.toJson();
      expect(json['date'], testDate.toIso8601String());
      expect(json['time'], '0950');
      expect(json['chlorine'], 0.45);
      expect(json['success'], true);
      expect(json['isDebugMode'], false);

      // JSON から復元
      final restored = EmailHistory.fromJson(json);
      expect(restored.date, testDate);
      expect(restored.time, '0950');
      expect(restored.chlorine, 0.45);
      expect(restored.success, true);
      expect(restored.isDebugMode, false);
    });

    test('1年間の保存期間の計算テスト', () {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      // 1年前の日付が正しく計算されているか
      expect(oneYearAgo.year, now.year - 1);
      expect(oneYearAgo.month, now.month);
      expect(oneYearAgo.day, now.day);

      // 1年前より新しいデータは保持される
      final recentHistory = EmailHistory(
        date: now.subtract(Duration(days: 300)),
        time: '0950',
        chlorine: 0.45,
        success: true,
      );
      expect(recentHistory.date.isAfter(oneYearAgo), true);

      // 1年以上前のデータは削除対象
      final oldHistory = EmailHistory(
        date: now.subtract(Duration(days: 400)),
        time: '0950',
        chlorine: 0.45,
        success: true,
      );
      expect(oldHistory.date.isBefore(oneYearAgo), true);
    });

    test('閏年を考慮した1年前の日付計算テスト', () {
      // 閏年のテスト（2024年2月29日）
      final leapDay2024 = DateTime(2024, 2, 29);
      final oneYearBeforeLeapDay = DateTime(
        leapDay2024.year - 1,
        leapDay2024.month,
        leapDay2024.day,
      );
      // 2023年2月29日は存在しないため、3月1日にオーバーフローする
      expect(oneYearBeforeLeapDay.year, 2023);
      expect(oneYearBeforeLeapDay.month, 3);
      expect(oneYearBeforeLeapDay.day, 1);

      // 通常の年から閏年へ
      final normalDay = DateTime(2025, 11, 3);
      final oneYearBefore = DateTime(
        normalDay.year - 1,
        normalDay.month,
        normalDay.day,
      );
      expect(oneYearBefore, DateTime(2024, 11, 3));
    });

    test('履歴データのフィルタリングロジックテスト', () {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final histories = [
        // 保持されるべきデータ（1年以内）
        EmailHistory(
          date: now.subtract(Duration(days: 1)),
          time: '0950',
          chlorine: 0.45,
          success: true,
        ),
        EmailHistory(
          date: now.subtract(Duration(days: 180)),
          time: '0950',
          chlorine: 0.45,
          success: true,
        ),
        EmailHistory(
          date: now.subtract(Duration(days: 364)),
          time: '0950',
          chlorine: 0.45,
          success: true,
        ),
        // 削除されるべきデータ（1年以上前）
        EmailHistory(
          date: now.subtract(Duration(days: 366)),
          time: '0950',
          chlorine: 0.45,
          success: true,
        ),
        EmailHistory(
          date: now.subtract(Duration(days: 500)),
          time: '0950',
          chlorine: 0.45,
          success: true,
        ),
      ];

      // フィルタリング（1年以内のデータのみ保持）
      final validHistories = histories
          .where((history) => history.date.isAfter(oneYearAgo))
          .toList();

      // 3件が保持され、2件が削除される
      expect(validHistories.length, 3);
      expect(histories.length - validHistories.length, 2);
    });

    test('デバッグモードのデータも1年間保存されるテスト', () {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final debugHistory = EmailHistory(
        date: now.subtract(Duration(days: 100)),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true, // デバッグモード
      );

      final productionHistory = EmailHistory(
        date: now.subtract(Duration(days: 100)),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false, // 本番モード
      );

      // 両方とも1年以内なので保持される
      expect(debugHistory.date.isAfter(oneYearAgo), true);
      expect(productionHistory.date.isAfter(oneYearAgo), true);
    });
  });
}
