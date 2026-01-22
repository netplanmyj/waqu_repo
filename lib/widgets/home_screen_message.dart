import 'package:flutter/material.dart';
import '../services/history_service.dart';
import 'history_card.dart';

class HomeScreenMessage extends StatelessWidget {
  final String message;
  final bool isSentToday;

  const HomeScreenMessage({
    super.key,
    required this.message,
    required this.isSentToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSentToday ? Colors.green[700] : Colors.blue[700],
          fontSize: 14,
        ),
      ),
    );
  }
}

class HomeScreenHistory extends StatelessWidget {
  final EmailHistory? lastHistory;
  final bool isLoading;
  final String locationNumber;

  const HomeScreenHistory({
    super.key,
    required this.lastHistory,
    required this.isLoading,
    required this.locationNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '前回の送信',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        _buildHistoryContent(),
      ],
    );
  }

  Widget _buildHistoryContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (lastHistory != null) {
      return HistoryCard(
        history: lastHistory!,
        onTap: null,
        onLongPress: null,
        locationNumber: locationNumber,
        margin: const EdgeInsets.symmetric(vertical: 4),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('まだ送信履歴がありません', style: TextStyle(color: Colors.grey[600])),
    );
  }
}
