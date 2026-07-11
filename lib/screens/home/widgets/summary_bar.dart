// lib/screens/home/widgets/summary_bar.dart
import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';

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
    final theme = Theme.of(context);
    final safeColor = Color(0xFF00A884);
    final warningColor = Color(0xFFF57F17);
    final urgentColor = Color(0xFFC62828);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusItem(context, context.loc.statusSafe, safeCount, safeColor),
          _divider(theme),
          _buildStatusItem(context, context.loc.statusWarning, warningCount, warningColor),
          _divider(theme),
          _buildStatusItem(context, context.loc.statusUrgent, urgentCount, urgentColor),
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

  Widget _divider(ThemeData theme) {
    return Container(
      height: 30,
      width: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}