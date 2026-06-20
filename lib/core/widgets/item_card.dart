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
    final safeDifference = item.remainingDays - item.safeThresholdDays;
    final safeDifferenceText = safeDifference > 0
        ? 'زائد عن الحد الآمن بـ $safeDifference يوم'
        : safeDifference < 0
            ? 'ناقص عن الحد الآمن بـ ${safeDifference.abs()} يوم'
            : 'عند الحد الآمن';
    final safeDifferenceColor = safeDifference > 0
        ? const Color(0xFF2E7D32)
        : safeDifference < 0
            ? const Color(0xFFC62828)
            : const Color(0xFFF57F17);

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
                          'تاريخ التجديد: $refreshedText',
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
                    'النفاذ المتوقع',
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
              Row(
                children: [
                  Icon(Icons.compare_arrows_outlined,
                      size: 14, color: safeDifferenceColor),
                  const SizedBox(width: 4),
                  Text(
                    safeDifferenceText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: safeDifferenceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // ── Bottom row: thresholds + notifications ────────────────────────
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    'الحد الآمن: ${item.safeThresholdDays} يوم',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (!item.notificationsEnabled)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 12, color: Colors.red.shade500),
                          const SizedBox(width: 3),
                          Text(
                            'الإشعارات: متوقفة',
                            style: TextStyle(
                                fontSize: 11, color: Colors.red.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.notifications_active_outlined,
                            size: 13, color: Colors.green.shade400),
                        const SizedBox(width: 3),
                        Text(
                          'الإشعارات: مفعلة',
                          style: TextStyle(
                              fontSize: 11, color: Colors.green.shade400),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
