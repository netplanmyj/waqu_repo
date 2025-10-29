import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppSettings {
  final String locationNumber;
  final String recipientEmail;
  final String testRecipientEmail;
  final bool isDebugMode;
  final String emailSubject; // メール件名
  // GAS URLは非推奨だが後方互換性のために残す
  final String gasUrl;

  AppSettings({
    required this.locationNumber,
    required this.recipientEmail,
    required this.testRecipientEmail,
    required this.isDebugMode,
    this.emailSubject = '毎日検査報告', // デフォルト件名
    this.gasUrl = '',
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      locationNumber: '01',
      recipientEmail: '',
      testRecipientEmail: '',
      isDebugMode: false,
      emailSubject: '毎日検査報告',
      gasUrl: '',
    );
  }

  AppSettings copyWith({
    String? locationNumber,
    String? recipientEmail,
    String? testRecipientEmail,
    bool? isDebugMode,
    String? emailSubject,
    String? gasUrl,
  }) {
    return AppSettings(
      locationNumber: locationNumber ?? this.locationNumber,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      testRecipientEmail: testRecipientEmail ?? this.testRecipientEmail,
      isDebugMode: isDebugMode ?? this.isDebugMode,
      emailSubject: emailSubject ?? this.emailSubject,
      gasUrl: gasUrl ?? this.gasUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationNumber': locationNumber,
      'recipientEmail': recipientEmail,
      'testRecipientEmail': testRecipientEmail,
      'isDebugMode': isDebugMode,
      'emailSubject': emailSubject,
      'gasUrl': gasUrl, // 後方互換性
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locationNumber: json['locationNumber'] ?? '01',
      recipientEmail: json['recipientEmail'] ?? '',
      testRecipientEmail: json['testRecipientEmail'] ?? '',
      isDebugMode: json['isDebugMode'] ?? false,
      emailSubject: json['emailSubject'] ?? '毎日検査報告',
      gasUrl: json['gasUrl'] ?? '', // 後方互換性
    );
  }
}

class SettingsService {
  static const String settingsKey = 'app_settings';

  // 設定を取得
  static Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(settingsKey);

    if (settingsJson == null) {
      return AppSettings.defaultSettings();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(settingsJson);
      return AppSettings.fromJson(json);
    } catch (e) {
      return AppSettings.defaultSettings();
    }
  }

  // 設定を保存
  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(settingsKey, jsonString);
  }

  // 送信先メールアドレスを取得（デバッグモードを考慮）
  static Future<String> getActiveRecipientEmail() async {
    final settings = await getSettings();
    return settings.isDebugMode
        ? settings.testRecipientEmail
        : settings.recipientEmail;
  }

  // 設定の妥当性チェック
  static Future<List<String>> validateSettings() async {
    final settings = await getSettings();
    final errors = <String>[];

    if (settings.recipientEmail.isEmpty) {
      errors.add('送信先メールアドレスが設定されていません');
    }

    if (settings.testRecipientEmail.isEmpty) {
      errors.add('テスト用送信先メールアドレスが設定されていません');
    }

    if (settings.locationNumber.isEmpty ||
        !RegExp(r'^\d{2}$').hasMatch(settings.locationNumber)) {
      errors.add('地点番号が正しく設定されていません（2桁の数字で入力してください）');
    }

    return errors;
  }
}
