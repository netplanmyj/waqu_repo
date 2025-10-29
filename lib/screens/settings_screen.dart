import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationNumberController;
  late TextEditingController _recipientEmailController;
  late TextEditingController _testRecipientEmailController;
  late TextEditingController _emailSubjectController; // 件名コントローラー
  bool _isDebugMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationNumberController = TextEditingController();
    _recipientEmailController = TextEditingController();
    _testRecipientEmailController = TextEditingController();
    _emailSubjectController = TextEditingController(); // 件名初期化
    _loadSettings();
  }

  @override
  void dispose() {
    _locationNumberController.dispose();
    _recipientEmailController.dispose();
    _testRecipientEmailController.dispose();
    _emailSubjectController.dispose(); // 件名破棄
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    final settings = await SettingsService.getSettings();
    setState(() {
      _locationNumberController.text = settings.locationNumber;
      _recipientEmailController.text = settings.recipientEmail;
      _testRecipientEmailController.text = settings.testRecipientEmail;
      _emailSubjectController.text = settings.emailSubject; // 件名ロード
      _isDebugMode = settings.isDebugMode;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final settings = AppSettings(
      locationNumber: _locationNumberController.text.trim(),
      recipientEmail: _recipientEmailController.text.trim(),
      testRecipientEmail: _testRecipientEmailController.text.trim(),
      emailSubject: _emailSubjectController.text.trim(), // 件名保存
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

            // メール件名
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'メール件名',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailSubjectController,
                      decoration: const InputDecoration(
                        hintText: '例: 毎日検査報告',
                        border: OutlineInputBorder(),
                        helperText: '送信するメールの件名を設定できます',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'メール件名を入力してください';
                        }
                        return null;
                      },
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
                        helperText: '実際の報告先メールアドレスを入力してください',
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
                        helperText: 'テスト送信時に使用するメールアドレスを入力してください',
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
                            ? 'メールはテスト用送信先に送信されます\n送信履歴の日次チェックも無効になります'
                            : 'メールは通常の送信先に送信されます\n1日1回の送信制限が有効です',
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
            const SizedBox(height: 32),

            // 認証状態表示
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.account_circle, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Google認証状態',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.blue[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✅ ${AuthService.userEmail ?? "不明"} でサインイン済み',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gmail送信権限: 有効',
                      style: TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Firebase Functions説明
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.green[600]),
                        const SizedBox(width: 8),
                        Text(
                          'メール送信方式',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.green[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ Firebase Functions + Gmail API',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'あなたのGoogleアカウントから直接メールを送信します\n'
                      '追加の設定や外部スクリプトは不要です',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
