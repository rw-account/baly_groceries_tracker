// lib/core/widgets/item_card.dart

import 'package:flutter/material.dart';
import 'package:baly_groceries_tracker/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import '../utils/relative_date_utils.dart';
import '../../../core/utils/context_extensions.dart';

class ItemCard extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final status = item.statusAt(now);

    final statusColor = switch (status) {
      ItemStatus.safe => theme.extension<CustomColors>()?.safe ?? const Color(0xFF34D399),
      ItemStatus.warning => cs.tertiary,
      ItemStatus.urgent => cs.error,
    };

    final statusBgColor = statusColor.withValues(alpha: 0.12);

    final statusIcon = switch (status) {
      ItemStatus.safe => Icons.check_circle_outline_rounded,
      ItemStatus.warning => Icons.warning_amber_rounded,
      ItemStatus.urgent => Icons.error_outline_rounded,
    };

    final statusLabel = switch (status) {
      ItemStatus.safe => context.loc.statusSafe,
      ItemStatus.warning => context.loc.statusWarning,
      ItemStatus.urgent => context.loc.statusUrgent,
    };

    final remainingDays = item.remainingDaysAt(now);
    final remainingText = remainingDays > 0
        ? context.loc.itemRemainingDaysPositiveFormat(remainingDays)
        : remainingDays == 0
            ? context.loc.itemRemainingDaysZero
            : context.loc.itemRemainingDaysNegativeFormat(-remainingDays);
    final expiryText = _dateFormat.format(item.expectedExpiryDate);

    final dateToShow = item.lastRefreshedAt ?? item.createdAt;
    final relativeText = formatRelativeDate(dateToShow);

    return Card(
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.loc.itemCardRefreshedText(relativeText),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.outline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.quantityDescription.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.quantityDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.outline,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Status badge
                  _StatusBadge(
                    icon: statusIcon,
                    label: statusLabel,
                    color: statusColor,
                    backgroundColor: statusBgColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(
                height: 1,
                thickness: 1,
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              // Expiry info
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 18, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    context.loc.expectedExpiryLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$remainingText • $expiryText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              // Bottom row: notification status
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _buildAlertText(context, item, theme, remainingDays, status),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;

  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildAlertText(BuildContext context, ItemModel item, ThemeData theme, int remainingDays, ItemStatus status) {
  final cs = theme.colorScheme;
  final Color safeColor = theme.extension<CustomColors>()?.safe ?? const Color(0xFF34D399);

  if (!item.notificationsEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Text(
            context.loc.notificationsStopped,
            style: TextStyle(fontSize: 12, color: cs.error, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  final daysUntilWarning = remainingDays - item.warningThresholdDays;

  if (status == ItemStatus.safe && daysUntilWarning > 0) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: safeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: safeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_active_outlined, size: 14, color: safeColor),
          const SizedBox(width: 6),
          Text(
            context.loc.notificationStartsInFormat(daysUntilWarning.toString()),
            style: TextStyle(fontSize: 12, color: safeColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  } else {
    final bool isUrgent = status == ItemStatus.urgent;
    final Color alertColor = isUrgent ? cs.error : cs.tertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: alertColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 14,
            color: alertColor,
          ),
          const SizedBox(width: 6),
          Text(
            context.loc.notificationActiveNow,
            style: TextStyle(
              fontSize: 12,
              color: alertColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}