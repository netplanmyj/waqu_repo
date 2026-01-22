import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/screens/history_screen.dart';
import '../lib/services/history_service.dart';
import '../lib/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ja_JP', null);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('履歴カードに地点が表示される', (WidgetTester tester) async {
    // 事前に履歴と設定（地点番号）を保存
    final historyJson = json.encode([
      {
        'date': DateTime(2025, 10, 14, 9, 30).toIso8601String(),
        'time': '0930',
        'chlorine': 0.45,
        'success': true,
        'isDebugMode': false,
        'errorMessage': null,
      },
    ]);

    final settingsJson = json.encode({
      'locationNumber': '99',
      'recipientEmail': 'to@example.com',
      'testRecipientEmail': 'test@example.com',
      'isDebugMode': false,
      'emailSubject': '毎日検査報告',
      'gasUrl': '',
    });

    SharedPreferences.setMockInitialValues({
      HistoryService.historyKey: historyJson,
      SettingsService.settingsKey: settingsJson,
    });

    await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('地点: 99'), findsOneWidget);
  });
}
