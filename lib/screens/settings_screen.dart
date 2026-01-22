import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/auth_service.dart';
import '../widgets/settings_cards.dart';
import '../widgets/settings_info_cards.dart';

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
  late TextEditingController _emailSubjectController;
  bool _isDebugMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locationNumberController = TextEditingController();
    _recipientEmailController = TextEditingController();
    _testRecipientEmailController = TextEditingController();
    _emailSubjectController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _locationNumberController.dispose();
    _recipientEmailController.dispose();
    _testRecipientEmailController.dispose();
    _emailSubjectController.dispose();
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
      _emailSubjectController.text = settings.emailSubject;
      _isDebugMode = settings.isDebugMode;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = AppSettings(
      locationNumber: _locationNumberController.text.trim(),
      recipientEmail: _recipientEmailController.text.trim(),
      testRecipientEmail: _testRecipientEmailController.text.trim(),
      emailSubject: _emailSubjectController.text.trim(),
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
            SettingsCard(
              title: '地点番号',
              child: LocationNumberField(
                controller: _locationNumberController,
                validator: _validateLocationNumber,
              ),
            ),
            const SizedBox(height: 16),
            SettingsCard(
              title: 'メール件名',
              child: EmailSubjectField(controller: _emailSubjectController),
            ),
            const SizedBox(height: 16),
            SettingsCard(
              title: '送信先メールアドレス',
              child: EmailAddressField(
                controller: _recipientEmailController,
                label: '送信先メールアドレス',
                validator: (value) => _validateEmail(value, '送信先メールアドレス'),
              ),
            ),
            const SizedBox(height: 16),
            SettingsCard(
              title: 'テスト用送信先メールアドレス',
              child: EmailAddressField(
                controller: _testRecipientEmailController,
                label: 'テスト用送信先メールアドレス',
                validator: (value) => _validateEmail(value, 'テスト用送信先メールアドレス'),
              ),
            ),
            const SizedBox(height: 16),
            SettingsCard(
              title: 'デバッグモード',
              child: DebugModeSwitch(
                value: _isDebugMode,
                onChanged: (value) {
                  setState(() {
                    _isDebugMode = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 32),
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
            const AuthStatusCard(),
            const SizedBox(height: 16),
            const EmailMethodCard(),
            const SizedBox(height: 32),
            DeleteAccountButton(onPressed: _showDeleteAccountDialog),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('アカウント削除の確認'),
            ],
          ),
          content: const Text(
            'アカウントを削除してもよろしいですか？\n\n'
            'この操作により、以下が完全に削除されます:\n'
            '• 認証情報\n'
            '• アプリ内の設定\n'
            '• 送信履歴\n\n'
            'この操作は取り消せません。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await AuthService.deleteAccount();

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アカウントを削除しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('アカウント削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
