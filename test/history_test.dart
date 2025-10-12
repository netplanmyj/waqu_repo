// 履歴画面と履歴サービスのテスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:waqu_repo/screens/history_screen.dart';
import 'package:waqu_repo/services/history_service.dart';

void main() {
  group('履歴サービステスト', () {
    setUp(() {
      // 各テスト前にSharedPreferencesをクリア
      SharedPreferences.setMockInitialValues({});
    });

    test('空の履歴が正しく返される', () async {
      final histories = await HistoryService.getHistories();
      expect(histories, isEmpty);
    });

    test('履歴が正しく追加される', () async {
      // 現在の日付を使用してカットオフロジックを回避
      final testDate = DateTime.now().subtract(const Duration(days: 1));

      // 履歴追加前の確認
      final beforeHistories = await HistoryService.getHistories();
      expect(beforeHistories, isEmpty, reason: '初期状態では履歴は空であるべき');

      await HistoryService.addHistory(
        date: testDate,
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      final histories = await HistoryService.getHistories();
      expect(histories, hasLength(1), reason: '履歴追加後は1つの履歴があるべき');

      final history = histories.first;
      expect(history.date.year, testDate.year);
      expect(history.date.month, testDate.month);
      expect(history.date.day, testDate.day);
      expect(history.time, '0950');
      expect(history.chlorine, 0.45);
      expect(history.success, true);
      expect(history.isDebugMode, false);
    });

    test('複数の履歴が正しく管理される', () async {
      // 現在の日付から1日と2日前を使用
      final testDate1 = DateTime.now().subtract(const Duration(days: 2));
      final testDate2 = DateTime.now().subtract(const Duration(days: 1));

      // 2つの履歴を追加
      await HistoryService.addHistory(
        date: testDate1,
        time: '1030',
        chlorine: 0.40,
        success: true,
        isDebugMode: false,
      );

      await HistoryService.addHistory(
        date: testDate2,
        time: '0950',
        chlorine: 0.45,
        success: false,
        isDebugMode: true,
      );

      final histories = await HistoryService.getHistories();
      expect(histories, hasLength(2));

      // 新しい順でソートされていることを確認（日付の比較を年月日レベルで行う）
      expect(histories[0].date.day, testDate2.day);
      expect(histories[0].date.month, testDate2.month);
      expect(histories[0].date.year, testDate2.year);
      expect(histories[1].date.day, testDate1.day);
      expect(histories[1].date.month, testDate1.month);
      expect(histories[1].date.year, testDate1.year);
    });

    test('デバッグモードの履歴が正しく保存される', () async {
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true,
      );

      final histories = await HistoryService.getHistories();
      expect(histories.first.isDebugMode, true);
    });

    test('直近50件のみ保持される', () async {
      // 51件の履歴を追加
      for (int i = 0; i < 51; i++) {
        await HistoryService.addHistory(
          date: DateTime.now().subtract(Duration(days: i)),
          time: '1000',
          chlorine: 0.30 + (i * 0.01),
          success: true,
          isDebugMode: false,
        );
      }

      final histories = await HistoryService.getHistories();

      // 直近50件のみ保持されることを確認
      expect(histories, hasLength(50));

      // 最新のデータが残っていることを確認
      expect(histories.first.chlorine, 0.30);

      // 最も古いデータは49日前のもの（0日目から数えて50件目）
      expect(histories.last.chlorine, closeTo(0.79, 0.01));
    });

    test('JSON serialization/deserializationが正しく動作する', () {
      final originalHistory = EmailHistory(
        date: DateTime(2024, 10, 10, 9, 50),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true,
      );

      final json = originalHistory.toJson();
      final deserializedHistory = EmailHistory.fromJson(json);

      expect(deserializedHistory.date, originalHistory.date);
      expect(deserializedHistory.time, originalHistory.time);
      expect(deserializedHistory.chlorine, originalHistory.chlorine);
      expect(deserializedHistory.success, originalHistory.success);
      expect(deserializedHistory.isDebugMode, originalHistory.isDebugMode);
    });

    test('既存データ（isDebugModeなし）との互換性が保たれる', () {
      // 古いデータ形式（isDebugModeフィールドなし）
      final oldFormatJson = {
        'date': DateTime(2024, 10, 10, 9, 50).toIso8601String(),
        'time': '0950',
        'chlorine': 0.45,
        'success': true,
        // isDebugModeフィールドなし
      };

      final history = EmailHistory.fromJson(oldFormatJson);
      expect(history.isDebugMode, false); // デフォルト値
    });
  });

  group('履歴画面UIテスト', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // 日本語の日付フォーマット初期化
      await initializeDateFormatting('ja_JP', null);
    });

    testWidgets('履歴画面が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // AppBarが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('送信履歴'), findsOneWidget);
    });

    testWidgets('空の履歴状態が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 空状態のメッセージが表示されることを確認
      expect(find.text('送信履歴がありません'), findsOneWidget);
      expect(find.text('メールを送信すると履歴が表示されます'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('履歴データが正しく表示される', (WidgetTester tester) async {
      // テスト用の履歴データを追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 履歴カードが表示されることを確認
      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));

      // 時刻と塩素濃度が表示されることを確認
      expect(find.textContaining('0950'), findsOneWidget);
      expect(find.textContaining('0.45'), findsOneWidget);
    });

    testWidgets('デバッグモードの履歴にデバッグラベルが表示される', (WidgetTester tester) async {
      // デバッグモードの履歴データを追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '1030',
        chlorine: 0.40,
        success: true,
        isDebugMode: true,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // デバッグラベルが表示されることを確認
      expect(find.text('デバッグ'), findsOneWidget);
    });

    testWidgets('成功と失敗の履歴が正しく表示される', (WidgetTester tester) async {
      // 成功の履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      // 失敗の履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now().subtract(const Duration(hours: 1)),
        time: '0850',
        chlorine: 0.30,
        success: false,
        isDebugMode: false,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 成功と失敗のアイコンが表示されることを確認
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);

      // 両方の履歴データが表示されることを確認
      expect(find.textContaining('0950'), findsOneWidget);
      expect(find.textContaining('0850'), findsOneWidget);
    });

    testWidgets('今日の履歴に「今日」ラベルが表示される', (WidgetTester tester) async {
      // 今日の履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 「今日」ラベルが表示されることを確認
      expect(find.text('今日'), findsOneWidget);
    });

    testWidgets('複数の履歴が日付順で表示される', (WidgetTester tester) async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // 昨日の履歴を追加
      await HistoryService.addHistory(
        date: yesterday,
        time: '1030',
        chlorine: 0.40,
        success: true,
        isDebugMode: false,
      );

      // 今日の履歴を追加
      await HistoryService.addHistory(
        date: today,
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 複数の履歴カードが表示されることを確認
      expect(find.byType(Card), findsAtLeastNWidgets(2));

      // 両方の時刻が表示されることを確認
      expect(find.textContaining('0950'), findsOneWidget);
      expect(find.textContaining('1030'), findsOneWidget);
    });

    testWidgets('デバッグ履歴を長押しすると削除ダイアログが表示される', (WidgetTester tester) async {
      // デバッグモードの履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // デバッグラベルが表示されることを確認
      expect(find.text('デバッグ'), findsOneWidget);

      // ListTileを長押し
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 削除ダイアログが表示されることを確認
      expect(find.text('デバッグ履歴の削除'), findsOneWidget);
      expect(find.text('この送信履歴を削除しますか？'), findsOneWidget);
      expect(find.text('キャンセル'), findsOneWidget);
      expect(find.text('削除'), findsOneWidget);
    });

    testWidgets('通常の送信履歴を長押ししても削除ダイアログが表示されない', (WidgetTester tester) async {
      // 通常モードの履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: false,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // デバッグラベルが表示されないことを確認
      expect(find.text('デバッグ'), findsNothing);

      // ListTileを長押し
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 削除ダイアログが表示されないことを確認
      expect(find.text('デバッグ履歴の削除'), findsNothing);
      expect(find.text('この送信履歴を削除しますか？'), findsNothing);
    });

    testWidgets('削除ボタンをタップすると履歴が削除される', (WidgetTester tester) async {
      // デバッグモードの履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 履歴が1件表示されることを確認
      expect(find.byType(Card), findsOneWidget);

      // ListTileを長押し
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // 削除ボタンをタップ
      await tester.tap(find.text('削除'));
      await tester.pumpAndSettle();

      // 削除完了のSnackBarが表示されることを確認
      expect(find.text('履歴を削除しました'), findsOneWidget);

      // 履歴が削除されて空状態になることを確認
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('送信履歴がありません'), findsOneWidget);
    });

    testWidgets('キャンセルボタンをタップすると履歴が削除されない', (WidgetTester tester) async {
      // デバッグモードの履歴を追加
      await HistoryService.addHistory(
        date: DateTime.now(),
        time: '0950',
        chlorine: 0.45,
        success: true,
        isDebugMode: true,
      );

      await tester.pumpWidget(MaterialApp(home: const HistoryScreen()));
      await tester.pumpAndSettle();

      // 履歴が1件表示されることを確認
      expect(find.byType(Card), findsOneWidget);

      // ListTileを長押し
      await tester.longPress(find.byType(ListTile));
      await tester.pumpAndSettle();

      // キャンセルボタンをタップ
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      // ダイアログが閉じることを確認
      expect(find.text('デバッグ履歴の削除'), findsNothing);

      // 履歴が残っていることを確認（Cardが存在）
      expect(find.byType(Card), findsOneWidget);
      // 測定時刻が含まれるテキストが表示されていることを確認
      expect(find.textContaining('0950'), findsOneWidget);
    });
  });
}
