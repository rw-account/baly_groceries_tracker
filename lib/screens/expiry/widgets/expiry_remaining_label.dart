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

    if (days < 0) {
      return Text(
        _expiredText(locale),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    if (days == 0) {
      return Text(
        locale == 'en' ? 'Expires today' : 'ينفد اليوم',
        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    }

    return Text(
      locale == 'en'
          ? 'Expires ${formatRelativeDate(item.expectedExpiryDate, locale: locale)}'
          : 'سينفد ${formatRelativeDate(item.expectedExpiryDate, locale: locale)}',
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