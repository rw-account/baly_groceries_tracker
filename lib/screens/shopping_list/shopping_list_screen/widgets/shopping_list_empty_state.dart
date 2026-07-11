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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.loc.shoppingEmptyStateTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.loc.shoppingEmptyStateSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.add),
              label: Text(context.loc.addItemButton),
            ),
          ],
        ),
      ),
    );
  }
}
