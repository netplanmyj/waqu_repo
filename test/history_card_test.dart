// HistoryCard ウィジェットのテスト
// 履歴カード表示の各種パターンをテスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../lib/services/history_service.dart';
import '../lib/widgets/history_card.dart';

void main() {
  group('HistoryCard ウィジェットテスト', () {
    // テスト用の日本語ロケール初期化
    setUpAll(() async {
      await initializeDateFormatting('ja_JP', null);
    });

    testWidgets('成功した履歴カードが正しく表示される', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime(2025, 10, 14, 9, 30),
        time: '0930',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(history: history, onLongPress: () {}),
          ),
        ),
      );

      // カードが表示される
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);

      // 成功アイコンが表示される
      expect(find.byIcon(Icons.check), findsOneWidget);

      // 測定データが表示される
      expect(find.textContaining('測定時刻: 0930'), findsOneWidget);
      expect(find.textContaining('残留塩素: 0.45 mg/L'), findsOneWidget);

      // 送信済みステータスが表示される
      expect(find.text('送信済み'), findsOneWidget);
    });

    testWidgets('失敗した履歴カードが正しく表示される', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime(2025, 10, 13, 14, 15),
        time: '1415',
        chlorine: 0.52,
        success: false,
        isDebugMode: false,
        errorMessage: 'ネットワークエラー',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(history: history, onLongPress: () {}),
          ),
        ),
      );

      // エラーアイコンが表示される
      expect(find.byIcon(Icons.error), findsOneWidget);

      // 送信失敗ステータスが表示される
      expect(find.text('送信失敗'), findsOneWidget);

      // エラー詳細アイコンが表示される
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('デバッグモードバッジが表示される', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime.now(),
        time: '1000',
        chlorine: 0.40,
        success: true,
        isDebugMode: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(history: history, onLongPress: () {}),
          ),
        ),
      );

      // デバッグバッジが表示される
      expect(find.text('デバッグ'), findsOneWidget);
    });

    testWidgets('タップとロングプレスのコールバックが動作する', (WidgetTester tester) async {
      bool tapped = false;
      bool longPressed = false;

      final history = EmailHistory(
        date: DateTime.now(),
        time: '1100',
        chlorine: 0.48,
        success: false,
        isDebugMode: false,
        errorMessage: 'テストエラー',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              history: history,
              onTap: () {
                tapped = true;
              },
              onLongPress: () {
                longPressed = true;
              },
            ),
          ),
        ),
      );

      // カードをタップ
      await tester.tap(find.byType(ListTile));
      await tester.pump();
      expect(tapped, isTrue);

      // カードを長押し
      await tester.longPress(find.byType(ListTile));
      await tester.pump();
      expect(longPressed, isTrue);
    });

    testWidgets('地点が表示される', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime(2025, 10, 14, 9, 30),
        time: '0930',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              history: history,
              onLongPress: () {},
              locationNumber: '01',
            ),
          ),
        ),
      );

      expect(find.text('地点: 01'), findsOneWidget);
    });

    testWidgets('地点が指定されない場合は表示されない', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime(2025, 10, 14, 9, 30),
        time: '0930',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              history: history,
              onLongPress: () {},
              locationNumber: null,
            ),
          ),
        ),
      );

      expect(find.textContaining('地点:'), findsNothing);
    });

    testWidgets('カスタムマージンがカードに適用される', (WidgetTester tester) async {
      final history = EmailHistory(
        date: DateTime(2025, 10, 14, 9, 30),
        time: '0930',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      const customMargin = EdgeInsets.all(4);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryCard(
              history: history,
              onLongPress: () {},
              margin: customMargin,
            ),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, customMargin);
    });
  });
}
