import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _addTestData() async {
    // テスト用のダミーデータを追加
    final baseDate = DateTime.now();
    final testData = [
      (0, '0950', 0.42, true),
      (1, '0955', 0.38, true),
      (2, '1005', 0.45, false),
      (3, '0945', 0.40, true),
      (4, '0950', 0.43, true),
      (7, '0955', 0.39, true),
      (8, '1000', 0.41, true),
      (9, '0945', 0.44, false),
      (10, '0950', 0.40, true),
      (14, '0955', 0.42, true),
    ];

    for (final (dayOffset, time, chlorine, success) in testData) {
      final date = baseDate.subtract(Duration(days: dayOffset));
      await HistoryService.addHistory(
        date: date,
        time: time,
        chlorine: chlorine,
        success: success,
      );
    }

    // データ追加後に再読み込み
    _loadHistories();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('テストデータを追加しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('送信履歴'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addTestData,
            tooltip: 'テストデータ追加',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistories,
          ),
        ],
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
                  '過去5週間分の送信履歴を表示しています',
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
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
