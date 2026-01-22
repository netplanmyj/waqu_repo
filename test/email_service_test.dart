// メール送信サービスのテスト（簡素化版）
// Firebase Functionsに移行後のため、基本的な設定テストのみ

import 'package:flutter_test/flutter_test.dart';
import '../lib/services/settings_service.dart';

void main() {
  group('メール送信関連設定テスト', () {
    test('設定データの基本構造が正しい', () {
      final settings = AppSettings(
        gasUrl: 'https://example.com',
        locationNumber: '01',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'debug@example.com',
        isDebugMode: false,
      );

      expect(settings.gasUrl, 'https://example.com');
      expect(settings.locationNumber, '01');
      expect(settings.recipientEmail, 'test@example.com');
      expect(settings.testRecipientEmail, 'debug@example.com');
      expect(settings.isDebugMode, false);
    });

    test('デバッグモードの切り替えが正しく動作する', () {
      final debugSettings = AppSettings(
        gasUrl: 'https://example.com',
        locationNumber: '01',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'debug@example.com',
        isDebugMode: true,
      );

      expect(debugSettings.isDebugMode, true);
    });
  });
}
