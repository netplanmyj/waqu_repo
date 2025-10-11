import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gasUrlController;
  late TextEditingController _locationNumberController;
  late TextEditingController _recipientEmailController;
  late TextEditingController _testRecipientEmailController;
  bool _isDebugMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _gasUrlController = TextEditingController();
    _locationNumberController = TextEditingController();
    _recipientEmailController = TextEditingController();
    _testRecipientEmailController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _gasUrlController.dispose();
    _locationNumberController.dispose();
    _recipientEmailController.dispose();
    _testRecipientEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final settings = await SettingsService.getSettings();
    setState(() {
      _gasUrlController.text = settings.gasUrl;
      _locationNumberController.text = settings.locationNumber;
      _recipientEmailController.text = settings.recipientEmail;
      _testRecipientEmailController.text = settings.testRecipientEmail;
      _isDebugMode = settings.isDebugMode;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = AppSettings(
      gasUrl: _gasUrlController.text,
      locationNumber: _locationNumberController.text,
      recipientEmail: _recipientEmailController.text,
      testRecipientEmail: _testRecipientEmailController.text,
      isDebugMode: _isDebugMode,
    );

    await SettingsService.saveSettings(settings);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
      Navigator.of(context).pop();
    }
  }

  String? _validateLocationNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '地点番号を入力してください';
    }
    if (value.length != 2) {
      return '地点番号は2桁で入力してください';
    }
    if (!RegExp(r'^\d{2}$').hasMatch(value)) {
      return '地点番号は数字2桁で入力してください';
    }
    return null;
  }

  String? _validateEmail(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldNameを入力してください';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
      return '正しいメールアドレスを入力してください';
    }
    return null;
  }

  String? _validateGasUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'GAS WebアプリURLを入力してください';
    }
    if (!value.startsWith('https://script.google.com/macros/s/')) {
      return '正しいGAS WebアプリURLを入力してください';
    }
    if (!value.endsWith('/exec')) {
      return 'URLの末尾が/execではありません';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
          backgroundColor: Colors.grey[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // GAS WebアプリURL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Apps Script設定',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _gasUrlController,
                      decoration: const InputDecoration(
                        labelText: 'GAS WebアプリURL',
                        hintText: 'https://script.google.com/macros/s/.../exec',
                        border: OutlineInputBorder(),
                        helperText: 'あなた専用のGoogle Apps Script WebアプリURLを入力',
                      ),
                      keyboardType: TextInputType.url,
                      validator: _validateGasUrl,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 地点番号
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '地点番号',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationNumberController,
                      decoration: const InputDecoration(
                        hintText: '例: 01',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: _validateLocationNumber,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 送信先メールアドレス
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '送信先メールアドレス',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _recipientEmailController,
                      decoration: const InputDecoration(
                        hintText: '例: report@example.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => _validateEmail(value, '送信先メールアドレス'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // テスト用送信先メールアドレス
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'テスト用送信先メールアドレス',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _testRecipientEmailController,
                      decoration: const InputDecoration(
                        hintText: '例: test@example.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          _validateEmail(value, 'テスト用送信先メールアドレス'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // デバッグモード
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'デバッグモード',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(
                        _isDebugMode ? 'ON (テスト用送信先に送信)' : 'OFF (通常の送信先に送信)',
                        style: TextStyle(
                          color: _isDebugMode ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _isDebugMode
                            ? 'メールはテスト用送信先に送信されます'
                            : 'メールは通常の送信先に送信されます',
                      ),
                      value: _isDebugMode,
                      onChanged: (value) {
                        setState(() {
                          _isDebugMode = value;
                        });
                      },
                      activeThumbColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 保存ボタン
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('設定を保存', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
