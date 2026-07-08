// lib/screens/expiry/widgets/expiry_remaining_label.dart

import 'package:flutter/material.dart';

import '../../../core/utils/relative_date_utils.dart';
import '../../../models/item_model.dart';

/// نص فرعي يوضّح الوقت المتبقي على نفاد عنصر واحد، أو منذ متى نفد إن
/// كان قد تجاوز تاريخ انتهائه بالفعل.
class ExpiryRemainingLabel extends StatelessWidget {
  const ExpiryRemainingLabel({super.key, required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final days = item.remainingDays;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (days < 0) {
      return Text(
        _expiredText(locale),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.error, 
          fontWeight: FontWeight.bold
        ),
      );
    }

    if (days == 0) {
      return Text(
        locale == 'en' ? 'Expires today' : 'ينفد اليوم',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.tertiary, 
          fontWeight: FontWeight.bold
        ),
      );
    }

    return Text(
      locale == 'en'
          ? 'Expires ${formatRelativeDate(item.expectedExpiryDate, locale: locale)}'
          : 'سينفد ${formatRelativeDate(item.expectedExpiryDate, locale: locale)}',
      style: theme.textTheme.bodyMedium,
    );
  }

  String _expiredText(String locale) {
    final relative = formatRelativeDate(
      item.expectedExpiryDate,
      locale: locale,
    );

    return locale == 'en' ? 'Expired $relative' : 'نفد $relative';
  }
}