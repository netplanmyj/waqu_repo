// デバッグテスト - 設定画面の表示内容を確認
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wq_report/screens/settings_screen.dart';

void main() {
  testWidgets('設定画面デバッグ - 何が表示されるかチェック', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(MaterialApp(home: const SettingsScreen()));
    await tester.pumpAndSettle();

    // 少し待機
    await tester.pump(const Duration(milliseconds: 500));

    // 表示されているすべてのテキストを出力
    final textWidgets = find.byType(Text);
    debugPrint('Found ${textWidgets.evaluate().length} Text widgets:');

    for (final element in textWidgets.evaluate()) {
      final textWidget = element.widget as Text;
      debugPrint('Text: "${textWidget.data}"');
    }

    // CircularProgressIndicatorが表示されているかチェック
    final progressIndicator = find.byType(CircularProgressIndicator);
    debugPrint(
      'CircularProgressIndicator found: ${progressIndicator.evaluate().isNotEmpty}',
    );

    // ElevatedButtonが表示されているかチェック
    final elevatedButton = find.byType(ElevatedButton);
    debugPrint('ElevatedButton found: ${elevatedButton.evaluate().isNotEmpty}');

    // TextFormFieldが表示されているかチェック
    final textFormField = find.byType(TextFormField);
    debugPrint('TextFormField count: ${textFormField.evaluate().length}');
  });
}
