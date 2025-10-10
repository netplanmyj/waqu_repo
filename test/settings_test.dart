import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wq_report/screens/settings_screen.dart';
import 'package:wq_report/services/settings_service.dart';

void main() {
  group('SettingsServiceテスト', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('デフォルト設定の取得', () async {
      final settings = await SettingsService.getSettings();
      expect(settings.gasUrl, '');
      expect(settings.locationNumber, '01');
      expect(settings.recipientEmail, '');
      expect(settings.testRecipientEmail, '');
      expect(settings.isDebugMode, false);
    });

    test('設定の保存と読み込み', () async {
      final testSettings = AppSettings(
        gasUrl: 'https://script.google.com/macros/s/test123/exec',
        locationNumber: '05',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'debug@example.com',
        isDebugMode: true,
      );

      await SettingsService.saveSettings(testSettings);
      final loadedSettings = await SettingsService.getSettings();

      expect(loadedSettings.gasUrl, testSettings.gasUrl);
      expect(loadedSettings.locationNumber, testSettings.locationNumber);
      expect(loadedSettings.recipientEmail, testSettings.recipientEmail);
      expect(
        loadedSettings.testRecipientEmail,
        testSettings.testRecipientEmail,
      );
      expect(loadedSettings.isDebugMode, testSettings.isDebugMode);
    });
  });

  group('設定画面UIテスト', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('SettingsScreen displays UI elements correctly', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // TextFormFieldsをチェック
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(4));

      // 画面の最下部まで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      // ElevatedButtonとSwitchListTileをチェック
      final buttons = find.byType(ElevatedButton);
      final switches = find.byType(SwitchListTile);

      expect(buttons, findsOneWidget);
      expect(switches, findsOneWidget);
    });

    testWidgets('GAS URL入力フィールドが正しく動作する', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      final gasUrlField = find.byType(TextFormField).first;
      await tester.enterText(gasUrlField, 'https://script.google.com/test');
      expect(find.text('https://script.google.com/test'), findsOneWidget);
    });

    testWidgets('地点番号入力フィールドが正しく動作する', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      final locationField = find.byType(TextFormField).at(1);
      await tester.enterText(locationField, '05');
      expect(find.text('05'), findsOneWidget);
    });

    testWidgets('デバッグモードトグルが正しく動作する', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // SwitchListTileまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      final debugSwitch = find.byType(SwitchListTile);
      expect(debugSwitch, findsOneWidget);

      // デバッグモードをONにする
      await tester.tap(debugSwitch);
      await tester.pump();

      // テキストが変更されたかチェック
      expect(find.text('ON (テスト用送信先に送信)'), findsOneWidget);
    });

    testWidgets('バリデーションエラーが正しく表示される', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // 保存ボタンまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      // 何も入力せずに保存ボタンをタップ
      final saveButton = find.byType(ElevatedButton);
      expect(saveButton, findsOneWidget);

      await tester.ensureVisible(saveButton);
      await tester.pump();

      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // GAS URLエラーを見つけるために上にスクロール
      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pump();

      // バリデーションエラーが表示されることを確認
      expect(find.text('GAS WebアプリURLを入力してください'), findsOneWidget);

      // 再度下にスクロールして他のエラーもチェック
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pump();

      expect(find.text('送信先メールアドレスを入力してください'), findsOneWidget);
      expect(find.text('テスト用送信先メールアドレスを入力してください'), findsOneWidget);
    });
    testWidgets('不正なGAS URLのバリデーション', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // 不正なGAS URLを入力
      final gasUrlField = find.byType(TextFormField).first;
      await tester.enterText(gasUrlField, 'https://example.com/invalid');

      // 他の必須フィールドも埋める
      final recipientEmailField = find.byType(TextFormField).at(2);
      await tester.enterText(recipientEmailField, 'test@example.com');

      final testRecipientEmailField = find.byType(TextFormField).at(3);
      await tester.enterText(testRecipientEmailField, 'debug@example.com');

      // 保存ボタンまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      // 保存ボタンをタップ
      final saveButton = find.byType(ElevatedButton);
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // エラーメッセージを見つけるために上にスクロール
      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pump();

      // バリデーションエラーが表示されることを確認
      expect(find.text('正しいGAS WebアプリURLを入力してください'), findsOneWidget);
    });

    testWidgets('不正なメールアドレスのバリデーション', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // 有効なGAS URLを入力
      final gasUrlField = find.byType(TextFormField).first;
      await tester.enterText(
        gasUrlField,
        'https://script.google.com/macros/s/test123/exec',
      );

      // 不正なメールアドレスを入力
      final recipientEmailField = find.byType(TextFormField).at(2);
      await tester.enterText(recipientEmailField, 'invalid-email');

      // テスト用メールアドレスは有効なものを入力
      final testRecipientEmailField = find.byType(TextFormField).at(3);
      await tester.enterText(testRecipientEmailField, 'debug@example.com');

      // 保存ボタンまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      // 保存ボタンをタップ
      final saveButton = find.byType(ElevatedButton);
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // エラーメッセージは中間位置にあるのでそこまでスクロール
      await tester.drag(find.byType(ListView), const Offset(0, 1000));
      await tester.pump();

      // バリデーションエラーが表示されることを確認
      expect(find.text('正しいメールアドレスを入力してください'), findsOneWidget);
    });

    testWidgets('不正なテスト用メールアドレスのバリデーション', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 100));

      // 有効なGAS URLを入力
      final gasUrlField = find.byType(TextFormField).first;
      await tester.enterText(
        gasUrlField,
        'https://script.google.com/macros/s/test123/exec',
      );

      // 有効なメールアドレスを入力
      final recipientEmailField = find.byType(TextFormField).at(2);
      await tester.enterText(recipientEmailField, 'user@example.com');

      // 不正なテスト用メールアドレスを入力
      final testRecipientEmailField = find.byType(TextFormField).at(3);
      await tester.enterText(testRecipientEmailField, 'invalid-test-email');

      // 保存ボタンまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -3000));
      await tester.pump();

      // 保存ボタンをタップ
      final saveButton = find.byType(ElevatedButton);
      await tester.ensureVisible(saveButton);
      await tester.pump();
      await tester.tap(saveButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // エラーメッセージは中間位置にあるのでそこまでスクロール
      await tester.drag(find.byType(ListView), const Offset(0, 1000));
      await tester.pump();

      // バリデーションエラーが表示されることを確認
      expect(find.text('正しいメールアドレスを入力してください'), findsOneWidget);
    });
  });

  group('設定画面統合テスト', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('設定の保存と読み込みが正しく動作する', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
      await tester.pumpAndSettle();

      // 各フィールドに値を入力
      final textFields = find.byType(TextFormField);

      await tester.enterText(
        textFields.at(0),
        'https://script.google.com/macros/s/test123/exec',
      ); // GAS URL
      await tester.enterText(textFields.at(1), '05'); // 地点番号
      await tester.enterText(
        textFields.at(2),
        'production@example.com',
      ); // 送信先メールアドレス
      await tester.enterText(
        textFields.at(3),
        'debug@example.com',
      ); // テスト用送信先メールアドレス

      // SwitchListTileまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pump();

      // デバッグモードを ON にする
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      // 保存ボタンまで手動でスクロール
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pump();

      // 保存ボタンをタップ
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pumpAndSettle();

      // 設定が保存されたことを確認
      final savedSettings = await SettingsService.getSettings();
      expect(
        savedSettings.gasUrl,
        'https://script.google.com/macros/s/test123/exec',
      );
      expect(savedSettings.locationNumber, '05');
      expect(savedSettings.recipientEmail, 'production@example.com');
      expect(savedSettings.testRecipientEmail, 'debug@example.com');
      expect(savedSettings.isDebugMode, true);
    });
  });
}
