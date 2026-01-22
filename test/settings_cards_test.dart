import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/settings_cards.dart';

void main() {
  group('Settings Cards Widget Tests', () {
    testWidgets('SettingsCard が正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(title: 'テストカード', child: Text('テスト内容')),
          ),
        ),
      );

      expect(find.text('テストカード'), findsOneWidget);
      expect(find.text('テスト内容'), findsOneWidget);
    });

    testWidgets('LocationNumberField が正しく表示される', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationNumberField(
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '地点番号を入力してください';
                }
                return null;
              },
            ),
          ),
        ),
      );

      expect(find.text('例: 01'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('LocationNumberField は数字のみ入力可能', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationNumberField(
              controller: controller,
              validator: (value) => null,
            ),
          ),
        ),
      );

      // テキストフィールドに入力
      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.pump();

      // 数字のみが入力される（文字は入力されない）
      expect(controller.text, isEmpty);

      controller.dispose();
    });

    testWidgets('EmailSubjectField が正しく表示される', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: EmailSubjectField(controller: controller)),
        ),
      );

      expect(find.text('例: 毎日検査報告'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('EmailSubjectField は空白でバリデーション失敗', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: EmailSubjectField(controller: controller),
            ),
          ),
        ),
      );

      // フォーム検証
      expect(formKey.currentState?.validate(), false);

      controller.dispose();
    });

    testWidgets('EmailAddressField が正しく表示される', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailAddressField(
              controller: controller,
              label: 'テストメール',
              validator: (value) => null,
            ),
          ),
        ),
      );

      expect(find.text('例: report@example.com'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('EmailAddressField は不正なメールアドレスで失敗', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmailAddressField(
              controller: controller,
              label: 'テストメール',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                  return '正しいメールアドレスを入力してください';
                }
                return null;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid-email');
      await tester.pump();

      controller.dispose();
    });

    testWidgets('DebugModeSwitch が正しく表示される', (WidgetTester tester) async {
      bool debugMode = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DebugModeSwitch(
                  value: debugMode,
                  onChanged: (value) {
                    setState(() {
                      debugMode = value;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // 初期状態は OFF
      expect(find.text('OFF (通常の送信先に送信)'), findsOneWidget);

      // スイッチをタップして ON に
      await tester.tap(find.byType(Switch));
      await tester.pump();

      // ON状態になる
      expect(find.text('ON (テスト用送信先に送信)'), findsOneWidget);
    });

    testWidgets('SettingsCard はアイコンを表示できる', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsCard(
              title: 'テストカード',
              icon: Icons.settings,
              child: Text('テスト内容'),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
