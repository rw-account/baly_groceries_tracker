// lib/screens/expiry/widgets/expiry_notice_card.dart

import 'package:flutter/material.dart';

/// بطاقة ملاحظة أعلى شاشة العناصر على وشك النفاد، توضّح للمستخدم أن
/// العناصر ذات الحالة الآمنة لا تظهر في هذه القائمة.
class ExpiryNoticeCard extends StatelessWidget {
  const ExpiryNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'ملاحظة: تُعرض فقط المواد ذات الحالة (انتباه) أو (عاجل). المواد الآمنة لا تظهر هنا.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
