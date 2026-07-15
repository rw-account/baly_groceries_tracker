// lib/screens/home/widgets/summary_bar.dart
import 'package:flutter/material.dart';
import 'package:home_orders_tracker/core/theme/app_theme.dart';
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
    final cs = theme.colorScheme;
    final safeColor = theme.extension<CustomColors>()?.safe ?? const Color(0xFF34D399);
    final warningColor = cs.tertiary;
    final urgentColor = cs.error;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 0,
        color: cs.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusItem(context, context.loc.statusSafe, safeCount, safeColor),
              _divider(context),
              _buildStatusItem(context, context.loc.statusWarning, warningCount, warningColor),
              _divider(context),
              _buildStatusItem(context, context.loc.statusUrgent, urgentCount, urgentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, int count, Color color) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 32,
      width: 1,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }
}