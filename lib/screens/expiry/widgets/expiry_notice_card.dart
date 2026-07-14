// lib/screens/expiry/widgets/expiry_notice_card.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';

/// بطاقة ملاحظة أعلى شاشة العناصر على وشك النفاد، توضّح للمستخدم أن
/// العناصر ذات الحالة الآمنة لا تظهر في هذه القائمة.
class ExpiryNoticeCard extends StatelessWidget {
  const ExpiryNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
      elevation: 0,
      color: cs.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, color: cs.onSecondaryContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.loc.expiryNoticeText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSecondaryContainer,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
