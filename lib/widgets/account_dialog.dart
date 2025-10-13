import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AccountDialog extends StatelessWidget {
  final bool isDebugMode;

  const AccountDialog({super.key, required this.isDebugMode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: AuthService.userPhotoUrl != null
                ? NetworkImage(AuthService.userPhotoUrl!)
                : null,
            backgroundColor: Colors.blue[100],
            child: AuthService.userPhotoUrl == null
                ? const Icon(Icons.person, color: Colors.blue)
                : null,
          ),
          const SizedBox(width: 12),
          const Text('アカウント情報'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDebugMode)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.bug_report, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'デバッグモード',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          _buildInfoRow(
            '名前',
            isDebugMode ? 'Demo User' : (AuthService.userName ?? 'ユーザー'),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'メールアドレス',
            isDebugMode ? 'demo@example.com' : AuthService.userEmail!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('閉じる'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            // contextを非同期処理前に保存
            final messenger = ScaffoldMessenger.of(context);

            try {
              await AuthService.signOut();
            } catch (e) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('サインアウトに失敗しました: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout, size: 18),
              SizedBox(width: 4),
              Text('サインアウト'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
