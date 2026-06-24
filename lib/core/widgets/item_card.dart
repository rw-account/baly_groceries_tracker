// lib/widgets/item_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = item.status;

    final statusColor = switch (status) {
      ItemStatus.safe => const Color(0xFF2E7D32),
      ItemStatus.warning => const Color(0xFFF57F17),
      ItemStatus.urgent => const Color(0xFFC62828),
    };

    final statusBgColor = switch (status) {
      ItemStatus.safe => const Color(0xFFE8F5E9),
      ItemStatus.warning => const Color(0xFFFFFDE7),
      ItemStatus.urgent => const Color(0xFFFFEBEE),
    };

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
    final refreshedText =
        DateFormat('yyyy-MM-dd').format(item.lastRefreshedAt ?? item.createdAt);

    // ─── Build ──────────────────────────────────────────────────────────────────

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'تم التجديد في: $refreshedText',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.quantityDescription.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.quantityDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$statusIcon $statusLabel',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // ── Divider ───────────────────────────────────────────────────────
              Container(
                height: 1,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                      color: theme.colorScheme.onSurfaceVariant,
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
                  // بناء النص المناسب
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
  if (!item.notificationsEnabled) {
    // الإشعارات متوقفة
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 12, color: Colors.red.shade500),
          const SizedBox(width: 4),
          Text(
            'الإشعارات متوقفة',
            style: TextStyle(fontSize: 11, color: Colors.red.shade600),
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
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.notifications_active_outlined, size: 12, color: Colors.green.shade600),
          const SizedBox(width: 4),
          Text(
            'سيبدأ التنبيه بعد $daysUntilWarning يوم',
            style: TextStyle(fontSize: 11, color: Colors.green.shade700),
          ),
        ],
      ),
    );
  } else {
    // المادة في حالة انتباه أو عاجل – التنبيه نشط
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: item.status == ItemStatus.urgent
            ? Colors.red.shade50
            : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.status == ItemStatus.urgent
              ? Colors.red.shade200
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 12,
            color: item.status == ItemStatus.urgent
                ? Colors.red.shade600
                : Colors.orange.shade600,
          ),
          const SizedBox(width: 4),
          Text(
            'التنبيه نشط الآن',
            style: TextStyle(
              fontSize: 11,
              color: item.status == ItemStatus.urgent
                  ? Colors.red.shade700
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}