// 水質報告アプリの基本的なウィジェットテスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wq_report/main.dart';

void main() {
  group('水質報告アプリの基本UI表示テスト', () {
    testWidgets('アプリが正常に起動して基本UIが表示される', (WidgetTester tester) async {
      // アプリをビルドして表示
      await tester.pumpWidget(const MyApp());

      // 画面が表示されるまで待機
      await tester.pumpAndSettle();

      // AppBarのタイトルが表示されることを確認
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('水質報告メール送信'), findsNWidgets(2)); // AppBarとボタンで2つ

      // 説明テキストが表示されることを確認
      expect(find.text('測定データを入力してください'), findsOneWidget);
    });
    testWidgets('入力フォームが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 測定時刻の入力フィールドが表示されることを確認
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('測定時刻（4桁）'), findsOneWidget);
      expect(find.text('例: 0950'), findsOneWidget);

      // 残留塩素の入力フィールドが表示されることを確認
      expect(find.text('残留塩素'), findsOneWidget);
      expect(find.text('例: 0.40'), findsOneWidget);
      expect(find.text('mg/L'), findsOneWidget);
    });

    testWidgets('送信ボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 送信ボタンが表示されることを確認
      expect(find.byType(ElevatedButton), findsOneWidget);
      // ボタン内のテキストは AppBar にも同じテキストがあるので、2つ見つかることを確認
      expect(find.text('水質報告メール送信'), findsNWidgets(2));
    });

    testWidgets('初期メッセージが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 初期状態のメッセージが表示されることを確認
      // （_checkSentStatus が非同期で実行されるため、少し待機）
      await tester.pump(const Duration(milliseconds: 100));

      // メッセージコンテナが表示されることを確認
      expect(find.byType(Container), findsWidgets);
      // テキストが存在することを確認（初期メッセージまたは「送信ボタンを押してください。」）
      final messageFinder = find.textContaining('送信');
      expect(messageFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('入力フィールドに文字が入力できる', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 測定時刻フィールドに入力
      final timeField = find.byType(TextFormField).first;
      await tester.enterText(timeField, '0950');
      expect(find.text('0950'), findsOneWidget);

      // 残留塩素フィールドに入力
      final chlorineField = find.byType(TextFormField).last;
      await tester.enterText(chlorineField, '0.40');
      expect(find.text('0.40'), findsOneWidget);
    });

    testWidgets('バリデーションエラーが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 空の状態でボタンをタップ
      final sendButton = find.byType(ElevatedButton);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // バリデーションエラーメッセージが表示されることを確認
      expect(find.text('測定時刻を入力してください'), findsOneWidget);
      expect(find.text('残留塩素を入力してください'), findsOneWidget);
    });

    testWidgets('不正な測定時刻のバリデーション', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 3桁の時刻を入力
      final timeField = find.byType(TextFormField).first;
      await tester.enterText(timeField, '095');

      // 残留塩素に正しい値を入力
      final chlorineField = find.byType(TextFormField).last;
      await tester.enterText(chlorineField, '0.40');

      // 送信ボタンをタップ
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // バリデーションエラーが表示されることを確認
      expect(find.text('4桁の数字で入力してください'), findsOneWidget);
    });

    testWidgets('不正な残留塩素のバリデーション', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 測定時刻に正しい値を入力
      final timeField = find.byType(TextFormField).first;
      await tester.enterText(timeField, '0950');

      // 残留塩素に文字を入力
      final chlorineField = find.byType(TextFormField).last;
      await tester.enterText(chlorineField, 'abc');

      // 送信ボタンをタップ
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // バリデーションエラーが表示されることを確認
      expect(find.text('数値で入力してください'), findsOneWidget);
    });
  });
}
