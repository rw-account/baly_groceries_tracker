// lib/screens/expiry/widgets/expiry_remaining_label.dart

import 'package:flutter/material.dart';

import '../../../core/utils/relative_date_utils.dart';
import '../../../models/item_model.dart';
import '../../../core/utils/context_extensions.dart';

/// نص فرعي يوضّح الوقت المتبقي على نفاد عنصر واحد، أو منذ متى نفد إن
/// كان قد تجاوز تاريخ انتهائه بالفعل.
class ExpiryRemainingLabel extends StatelessWidget {
  const ExpiryRemainingLabel({super.key, required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final days = item.remainingDays;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (days < 0) {
      final relative = formatRelativeDate(item.expectedExpiryDate);
      return Text(
        context.loc.expiredFormat(relative),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.error, 
          fontWeight: FontWeight.bold
        ),
      );
    }

    if (days == 0) {
      return Text(
        context.loc.expiresToday,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.tertiary, 
          fontWeight: FontWeight.bold
        ),
      );
    }

    final relative = formatRelativeDate(item.expectedExpiryDate);
    return Text(
      context.loc.expiresInFormat(relative),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: cs.onSurfaceVariant,
      ),
    );
  }
}