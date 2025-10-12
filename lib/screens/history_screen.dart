import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<EmailHistory> histories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
  }

  Future<void> _initializeDateFormatting() async {
    await initializeDateFormatting('ja_JP', null);
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() {
      isLoading = true;
    });

    final loadedHistories = await HistoryService.getHistories();
    setState(() {
      histories = loadedHistories;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('送信履歴'),
        backgroundColor: Colors.grey[600],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : histories.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '送信履歴がありません',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'メールを送信すると履歴が表示されます',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '直近50件の送信履歴を表示しています',
                  style: TextStyle(color: Colors.blue[700], fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              return _buildHistoryCard(history);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(EmailHistory history) {
    final dateFormat = DateFormat('M月d日 (E)', 'ja_JP');
    final isToday = _isToday(history.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: !history.success && history.errorMessage != null
            ? () => _showErrorDialog(history)
            : null,
        onLongPress: history.isDebugMode
            ? () => _showDeleteConfirmDialog(history)
            : null,
        leading: CircleAvatar(
          backgroundColor: history.success
              ? Colors.green[100]
              : Colors.red[100],
          child: Icon(
            history.success ? Icons.check : Icons.error,
            color: history.success ? Colors.green[700] : Colors.red[700],
          ),
        ),
        title: Row(
          children: [
            Text(
              dateFormat.format(history.date),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.blue[700] : null,
              ),
            ),
            if (isToday)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '今日',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (history.isDebugMode)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'デバッグ',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('測定時刻: ${history.time}'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.science, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('残留塩素: ${history.chlorine.toStringAsFixed(2)} mg/L'),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              history.success ? '送信済み' : '送信失敗',
              style: TextStyle(
                color: history.success ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (!history.success && history.errorMessage != null)
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(EmailHistory history) {
    final dateFormat = DateFormat('M月d日 (E) HH:mm', 'ja_JP');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('送信エラー詳細'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateFormat.format(history.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('測定時刻', history.time),
              const SizedBox(height: 8),
              _buildInfoRow(
                '残留塩素',
                '${history.chlorine.toStringAsFixed(2)} mg/L',
              ),
              const Divider(height: 24),
              Text(
                'エラー内容',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                history.errorMessage ?? '不明なエラー',
                style: TextStyle(color: Colors.grey[800]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
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
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmDialog(EmailHistory history) {
    final dateFormat = DateFormat('M月d日 (E) HH:mm', 'ja_JP');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text('デバッグ履歴の削除'),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('この送信履歴を削除しますか？'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormat.format(history.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('測定時刻: ${history.time}'),
                  Text('残留塩素: ${history.chlorine.toStringAsFixed(2)} mg/L'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteHistory(history);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteHistory(EmailHistory history) async {
    await HistoryService.deleteHistory(history);

    // 履歴を再読み込み
    final updatedHistories = await HistoryService.getHistories();
    setState(() {
      histories = updatedHistories;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('履歴を削除しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
