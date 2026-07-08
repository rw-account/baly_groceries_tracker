// lib/widgets/item_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import '../utils/relative_date_utils.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final status = item.status;

    final statusColor = switch (status) {
      ItemStatus.safe => const Color(0xFF00A884),
      ItemStatus.warning => const Color(0xFFF57F17),
      ItemStatus.urgent => const Color(0xFFC62828),
    };

    final statusBgColor = statusColor.withValues(alpha: 0.12);

    final statusIcon = switch (status) {
      ItemStatus.safe => '🟢',
      ItemStatus.warning => '🟡',
      ItemStatus.urgent => '🔴',
    };

    final statusLabel = switch (status) {
      ItemStatus.safe => 'آمن',
      ItemStatus.warning => 'انتبه',
      ItemStatus.urgent => 'عاجل',
    };

    final remainingText = item.remainingDaysText;
    final expiryText = DateFormat('yyyy-MM-dd').format(item.expectedExpiryDate);

    final dateToShow = item.lastRefreshedAt ?? item.createdAt;
    final relativeText = formatRelativeDate(dateToShow, locale: 'ar');

    // ─── Build ──────────────────────────────────────────────────────────────────

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ────────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تم التجديد $relativeText',
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
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$statusIcon $statusLabel',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Divider ───────────────────────────────────────────────────────
              Container(
                height: 1,
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              // ── Expiry info ───────────────────────────────────────────────────
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 16, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    'النفاد المتوقع',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$remainingText • $expiryText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              // ── Bottom row: thresholds + notifications ────────────────────────
              Row(
                children: [
                  const Spacer(),
                  _buildAlertText(item, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAlertText(ItemModel item, ThemeData theme) {
  final cs = theme.colorScheme;

  if (!item.notificationsEnabled) {
    // الإشعارات متوقفة
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: cs.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 12, color: cs.error),
          const SizedBox(width: 4),
          Text(
            'الإشعارات متوقفة',
            style: TextStyle(fontSize: 11, color: cs.error),
          ),
        ],
      ),
    );
  }

  // الإشعارات مفعلة – حساب متى يبدأ التنبيه
  final daysUntilWarning = item.remainingDays - item.warningThresholdDays;

  if (item.status == ItemStatus.safe && daysUntilWarning > 0) {
    // المادة آمنة وسيبدأ التنبيه بعد X أيام
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined, size: 12, color: Colors.green),
          const SizedBox(width: 4),
          Text(
            'سيبدأ التنبيه بعد $daysUntilWarning يوم',
            style: const TextStyle(fontSize: 11, color: Colors.green),
          ),
        ],
      ),
    );
  } else {
    // المادة في حالة انتباه أو عاجل – التنبيه نشط
    final bool isUrgent = item.status == ItemStatus.urgent;
    final Color alertColor = isUrgent ? cs.error : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: alertColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: alertColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: alertColor,
          ),
          const SizedBox(width: 4),
          Text(
            'التنبيه نشط الآن',
            style: TextStyle(
              fontSize: 11,
              color: alertColor,
            ),
          ),
        ],
      ),
    );
  }
}