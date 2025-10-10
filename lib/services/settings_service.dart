import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final String locationNumber;
  final String recipientEmail;
  final String testRecipientEmail;
  final bool isDebugMode;

  AppSettings({
    required this.locationNumber,
    required this.recipientEmail,
    required this.testRecipientEmail,
    required this.isDebugMode,
  });

  factory AppSettings.defaultSettings() {
    return AppSettings(
      locationNumber: '01',
      recipientEmail: '',
      testRecipientEmail: '',
      isDebugMode: false,
    );
  }

  AppSettings copyWith({
    String? locationNumber,
    String? recipientEmail,
    String? testRecipientEmail,
    bool? isDebugMode,
  }) {
    return AppSettings(
      locationNumber: locationNumber ?? this.locationNumber,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      testRecipientEmail: testRecipientEmail ?? this.testRecipientEmail,
      isDebugMode: isDebugMode ?? this.isDebugMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationNumber': locationNumber,
      'recipientEmail': recipientEmail,
      'testRecipientEmail': testRecipientEmail,
      'isDebugMode': isDebugMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
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
      final Map<String, dynamic> json = {};
      // 簡易的なJSON解析（実際のアプリではjson.decodeを使用）
      final lines = settingsJson.split('\n');
      for (final line in lines) {
        if (line.contains(':')) {
          final parts = line.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim().replaceAll('"', '');
            final value = parts[1]
                .trim()
                .replaceAll('"', '')
                .replaceAll(',', '');

            if (key == 'isDebugMode') {
              json[key] = value == 'true';
            } else {
              json[key] = value;
            }
          }
        }
      }
      return AppSettings.fromJson(json);
    } catch (e) {
      return AppSettings.defaultSettings();
    }
  }

  // 設定を保存
  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString =
        '''
{
  "locationNumber": "${settings.locationNumber}",
  "recipientEmail": "${settings.recipientEmail}",
  "testRecipientEmail": "${settings.testRecipientEmail}",
  "isDebugMode": ${settings.isDebugMode}
}''';
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
