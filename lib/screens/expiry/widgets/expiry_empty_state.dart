// lib/screens/expiry/widgets/expiry_empty_state.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';

/// حالة الشاشة الفارغة عندما لا توجد أي عناصر تحتاج انتباه حالياً.
class ExpiryEmptyState extends StatelessWidget {
  const ExpiryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.loc.expiryEmptyStateTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.loc.expiryEmptyStateSubtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}