import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/home_screen_message.dart';

void main() {
  group('HomeScreenMessage Widget Tests', () {
    testWidgets('メッセージが正しく表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreenMessage(message: 'テストメッセージ', isSentToday: false),
          ),
        ),
      );

      expect(find.text('テストメッセージ'), findsOneWidget);
    });

    testWidgets('未送信時のメッセージが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreenMessage(message: 'まだ送信していません', isSentToday: false),
          ),
        ),
      );

      expect(find.text('まだ送信していません'), findsOneWidget);
    });

    testWidgets('送信済み時のメッセージが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeScreenMessage(message: '本日は送信済みです', isSentToday: true),
          ),
        ),
      );

      expect(find.text('本日は送信済みです'), findsOneWidget);
    });
  });
}
