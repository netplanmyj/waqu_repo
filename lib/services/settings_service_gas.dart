import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppSettings {
  final String gasUrl;
  final String locationNumber;
  final String recipientEmail;
  final String testRecipientEmail;
  final bool isDebugMode;

  AppSettings({
    required this.gasUrl,
    required this.locationNumber,
    required this.recipientEmail,
    required this.testRecipientEmail,
    required this.isDebugMode,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      gasUrl: '',
      locationNumber: '01',
      recipientEmail: '',
      testRecipientEmail: '',
      isDebugMode: false,
    );
  }

  AppSettings copyWith({
    String? gasUrl,
    String? locationNumber,
    String? recipientEmail,
    String? testRecipientEmail,
    bool? isDebugMode,
  }) {
    return AppSettings(
      gasUrl: gasUrl ?? this.gasUrl,
      locationNumber: locationNumber ?? this.locationNumber,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      testRecipientEmail: testRecipientEmail ?? this.testRecipientEmail,
      isDebugMode: isDebugMode ?? this.isDebugMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gasUrl': gasUrl,
      'locationNumber': locationNumber,
      'recipientEmail': recipientEmail,
      'testRecipientEmail': testRecipientEmail,
      'isDebugMode': isDebugMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      gasUrl: json['gasUrl'] ?? '',
      locationNumber: json['locationNumber'] ?? '01',
      recipientEmail: json['recipientEmail'] ?? '',
      testRecipientEmail: json['testRecipientEmail'] ?? '',
      isDebugMode: json['isDebugMode'] ?? false,
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

  // 設定をリセット
  static Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(settingsKey);
  }
}
