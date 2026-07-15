// lib/screens/shopping_list/shopping_list_screen/widgets/shopping_list_empty_state.dart

import 'package:flutter/material.dart';
import '../../../../core/utils/context_extensions.dart';

class ShoppingListEmptyState extends StatelessWidget {
  const ShoppingListEmptyState({
    super.key,
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
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
                Icons.shopping_cart_outlined,
                size: 56,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.loc.shoppingEmptyStateTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.loc.shoppingEmptyStateSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add_outlined),
              label: Text(context.loc.addItemButton),
            ),
          ],
        ),
      ),
    );
  }
}