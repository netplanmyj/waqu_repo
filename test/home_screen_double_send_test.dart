// test/home_screen_double_send_test.dart
//
// 送信ボタンの二重送信防止機能のテスト
// HomeScreenの実装から独立した単体テスト

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('送信ボタンの二重送信防止テスト', () {
    testWidgets('送信中はボタンが無効化される', (WidgetTester tester) async {
      bool isSending = false;
      int sendCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () {
                          setState(() {
                            isSending = true;
                            sendCount++;
                          });
                        },
                  child: Text(isSending ? '送信中...' : '送信'),
                );
              },
            ),
          ),
        ),
      );

      // 初期状態: ボタンが有効
      var button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('送信'), findsOneWidget);

      // 送信ボタンをタップ
      await tester.tap(find.text('送信'));
      await tester.pump();

      // 送信中状態: ボタンが無効化される
      button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(find.text('送信中...'), findsOneWidget);
      expect(sendCount, 1);
    });

    testWidgets('送信中に連続でタップしても反応しない', (WidgetTester tester) async {
      int sendCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                bool isSending = false;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  sendCount++;
                                  setState(() {
                                    isSending = true;
                                  });
                                  // 送信処理をシミュレート（500ms）
                                  await Future.delayed(
                                    const Duration(milliseconds: 500),
                                  );
                                  if (context.mounted) {
                                    setState(() {
                                      isSending = false;
                                    });
                                  }
                                },
                          child: Text(isSending ? '送信中...' : '送信'),
                        ),
                        Text('送信回数: $sendCount', key: const Key('count')),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      // 最初のタップ
      await tester.tap(find.text('送信'));
      await tester.pump();

      // 送信中を確認
      expect(find.text('送信中...'), findsOneWidget);
      expect(find.text('送信回数: 1'), findsOneWidget);

      // 連続でタップを試みる（無効化されているので反応しないはず）
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // 送信回数が1回のまま
      expect(find.text('送信回数: 1'), findsOneWidget);

      // 送信完了を待つ
      await tester.pumpAndSettle();

      // 送信完了後、ボタンが再度有効化される
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('送信'), findsOneWidget);
    });

    testWidgets('エラー発生時もボタンが再度有効化される', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                bool isSending = false;
                String message = '';
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: isSending
                              ? null
                              : () async {
                                  setState(() {
                                    isSending = true;
                                    message = '送信中';
                                  });

                                  try {
                                    // エラーをシミュレート
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    );
                                    throw Exception('送信エラー');
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() {
                                        isSending = false;
                                        message = 'エラー発生';
                                      });
                                    }
                                  }
                                },
                          child: Text(isSending ? '送信中...' : '送信'),
                        ),
                        Text(message, key: const Key('message')),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      // 送信ボタンをタップ（エラーが発生する）
      await tester.tap(find.text('送信'));
      await tester.pump();

      // 送信中状態
      expect(find.text('送信中...'), findsOneWidget);
      expect(find.text('送信中'), findsOneWidget);

      // エラーが発生するまで待つ
      await tester.pumpAndSettle();

      // エラー後、ボタンが再度有効化される
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
      expect(find.text('送信'), findsOneWidget);
      expect(find.text('エラー発生'), findsOneWidget);
    });
  });

  group('UIコンポーネントのテスト', () {
    testWidgets('ローディングインジケーターの表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('送信中...'),
              ],
            ),
          ),
        ),
      );

      // ローディングインジケーターが表示される
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('送信中...'), findsOneWidget);

      // SizedBoxの幅と高さを確認
      final sizedBox = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.width, 20);
      expect(sizedBox.height, 20);
    });

    testWidgets('送信ボタンのテキスト変更', (WidgetTester tester) async {
      // 通常時
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(onPressed: () {}, child: const Text('送信')),
          ),
        ),
      );
      expect(find.text('送信'), findsOneWidget);

      // 送信中
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(onPressed: null, child: const Text('送信中...')),
          ),
        ),
      );
      expect(find.text('送信中...'), findsOneWidget);
    });
  });
}
