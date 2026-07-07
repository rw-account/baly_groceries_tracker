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
    final days = item.remainingDays;

    if (days < 0) {
      return Text(
        expiredSinceLabel(-days),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      );
    }

    if (days == 0) {
      return const Text(
        'ينفد اليوم',
        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
      );
    }

    return Text('سينفد ${formatRelativeDate(item.expectedExpiryDate)}');
  }
}
