import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';

/// 送信履歴の個別カードウィジェット
class HistoryCard extends StatelessWidget {
  final EmailHistory history;
  final VoidCallback? onTap;
  final VoidCallback onLongPress;

  const HistoryCard({
    required this.history,
    this.onTap,
    required this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('M月d日 (E) HH:mm', 'ja_JP');
    final isToday = _isToday(history.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
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
            Flexible(
              child: Text(
                dateFormat.format(history.date),
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday ? Colors.blue[700] : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (history.isDebugMode) _buildDebugBadge(),
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

  Widget _buildDebugBadge() {
    return Container(
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
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
