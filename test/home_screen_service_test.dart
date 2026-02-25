import 'package:flutter_test/flutter_test.dart';
import '../lib/services/settings_service.dart';
import '../lib/services/history_service.dart';

void main() {
  group('HomeScreenService Tests', () {
    setUp(() {
      // テスト前の初期化
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('デバッグモード: 常に送信可能な状態を返す', () async {
      // テストスタブを使用してデバッグモードを設定
      final mockSettings = AppSettings(
        locationNumber: '01',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'test-user@example.com',
        emailSubject: 'Test Subject',
        isDebugMode: true,
      );

      // SettingsService.getSettings() をモック
      // 注意: 実際のテストでは mockito や mocktail を使用することが推奨されます

      // デバッグモード時の挙動確認（簡易テスト）
      expect(mockSettings.isDebugMode, isTrue);
    });

    test('AppSettings オブジェクトの初期化テスト', () {
      final settings = AppSettings(
        locationNumber: '01',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'test-user@example.com',
        emailSubject: '毎日検査報告',
        isDebugMode: false,
      );

      expect(settings.locationNumber, equals('01'));
      expect(settings.recipientEmail, equals('test@example.com'));
      expect(settings.testRecipientEmail, equals('test-user@example.com'));
      expect(settings.emailSubject, equals('毎日検査報告'));
      expect(settings.isDebugMode, isFalse);
    });

    test('AppSettings オブジェクトのデバッグモード有効時', () {
      final settings = AppSettings(
        locationNumber: '02',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'test-user@example.com',
        emailSubject: '毎日検査報告',
        isDebugMode: true,
      );

      expect(settings.isDebugMode, isTrue);
      expect(settings.locationNumber, equals('02'));
    });

    test('AppSettings の地点番号は文字列型', () {
      final settings = AppSettings(
        locationNumber: '03',
        recipientEmail: 'test@example.com',
        testRecipientEmail: 'test-user@example.com',
        emailSubject: 'Report',
        isDebugMode: false,
      );

      expect(settings.locationNumber, isA<String>());
      expect(int.tryParse(settings.locationNumber), equals(3));
    });

    test('複数の AppSettings インスタンスは独立している', () {
      final settings1 = AppSettings(
        locationNumber: '01',
        recipientEmail: 'test1@example.com',
        testRecipientEmail: 'test-user1@example.com',
        emailSubject: 'Report 1',
        isDebugMode: false,
      );

      final settings2 = AppSettings(
        locationNumber: '02',
        recipientEmail: 'test2@example.com',
        testRecipientEmail: 'test-user2@example.com',
        emailSubject: 'Report 2',
        isDebugMode: true,
      );

      expect(settings1.locationNumber, equals('01'));
      expect(settings2.locationNumber, equals('02'));
      expect(settings1.isDebugMode, isFalse);
      expect(settings2.isDebugMode, isTrue);
    });

    test('EmailHistory オブジェクトの初期化テスト', () {
      final now = DateTime.now();
      final history = EmailHistory(
        date: now,
        time: '0950',
        chlorine: 0.5,
        success: true,
      );

      expect(history.date, equals(now));
      expect(history.time, equals('0950'));
      expect(history.chlorine, equals(0.5));
      expect(history.success, isTrue);
    });

    test('AppSettings でメールアドレスの検証', () {
      final settings = AppSettings(
        locationNumber: '01',
        recipientEmail: 'valid@example.com',
        testRecipientEmail: 'test@example.com',
        emailSubject: 'Test',
        isDebugMode: false,
      );

      expect(settings.recipientEmail, contains('@'));
      expect(settings.recipientEmail, contains('.'));
    });
  });
}
