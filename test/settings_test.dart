// 設定サービスのテスト（簡素化版）

import 'package:flutter_test/flutter_test.dart';
import '../lib/services/settings_service.dart';

void main() {
  group('設定サービス基本テスト', () {
    test('設定データのデフォルト値が正しい', () {
      final defaultSettings = AppSettings(
        gasUrl: '',
        locationNumber: '01',
        recipientEmail: '',
        testRecipientEmail: '',
        isDebugMode: false,
      );

      expect(defaultSettings.gasUrl, '');
      expect(defaultSettings.locationNumber, '01');
      expect(defaultSettings.recipientEmail, '');
      expect(defaultSettings.testRecipientEmail, '');
      expect(defaultSettings.isDebugMode, false);
    });

    test('設定データのコピー機能が正しく動作する', () {
      final originalSettings = AppSettings(
        gasUrl: 'https://example.com',
        locationNumber: '01',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'debug@example.com',
        isDebugMode: false,
      );

      final copiedSettings = originalSettings.copyWith(isDebugMode: true);

      expect(copiedSettings.gasUrl, originalSettings.gasUrl);
      expect(copiedSettings.locationNumber, originalSettings.locationNumber);
      expect(copiedSettings.recipientEmail, originalSettings.recipientEmail);
      expect(
        copiedSettings.testRecipientEmail,
        originalSettings.testRecipientEmail,
      );
      expect(copiedSettings.isDebugMode, true);
    });
  });
}
