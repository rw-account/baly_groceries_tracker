// lib/screens/home/widgets/summary_bar.dart
import 'package:flutter/material.dart';

class SummaryBar extends StatelessWidget {
  final int safeCount;
  final int warningCount;
  final int urgentCount;

  const SummaryBar({
    super.key,
    required this.safeCount,
    required this.warningCount,
    required this.urgentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusItem(context, 'آمن', safeCount, Colors.green),
          _divider(),
          _buildStatusItem(context, 'انتبه', warningCount, Colors.orange),
          _divider(),
          _buildStatusItem(context, 'عاجل', urgentCount, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}