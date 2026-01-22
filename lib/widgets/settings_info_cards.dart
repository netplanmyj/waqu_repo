import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthStatusCard extends StatelessWidget {
  const AuthStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
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
            const Text('Gmail送信権限: 有効', style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class EmailMethodCard extends StatelessWidget {
  const EmailMethodCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
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
    );
  }
}

class DeleteAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DeleteAccountButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'アカウント削除',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'アカウントを削除すると、以下のデータが完全に削除されます:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 認証情報（Google/Apple Sign-In）\n'
              '• アプリ内の設定データ\n'
              '• 送信履歴\n\n'
              'この操作は取り消せません。',
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.delete_forever),
                label: const Text('アカウントを削除'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
