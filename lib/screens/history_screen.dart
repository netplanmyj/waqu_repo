import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/history_service.dart';
import '../services/settings_service.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<EmailHistory> histories = [];
  bool isLoading = true;
  String _locationNumber = '01';

  @override
  void initState() {
    super.initState();
    _initializeDateFormatting();
    _loadSettings();
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

  Future<void> _loadSettings() async {
    final settings = await SettingsService.getSettings();
    if (mounted) {
      setState(() {
        _locationNumber = settings.locationNumber;
      });
    }
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
                  '過去1年分の送信履歴を表示しています',
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
              return HistoryCard(
                history: history,
                onTap: !history.success && history.errorMessage != null
                    ? () => _showErrorDialog(history)
                    : null,
                onLongPress: () => _showDeleteConfirmDialog(history),
                locationNumber: _locationNumber,
              );
            },
          ),
        ),
      ],
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
            const Text('送信履歴の削除'),
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
}
