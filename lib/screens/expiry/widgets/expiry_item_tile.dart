// lib/screens/expiry/widgets/expiry_item_tile.dart

import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import 'expiry_remaining_label.dart';
import '../../../core/utils/context_extensions.dart';

class ExpiryItemTile extends StatelessWidget {
  const ExpiryItemTile({
    super.key,
    required this.item,
    required this.color,
    required this.isInShoppingList,
    required this.isAdding,
    required this.isAddingAll,
    required this.onAddToShoppingList,
  });

  final ItemModel item;
  final Color color;
  final bool isInShoppingList;
  final bool isAdding;
  final bool isAddingAll;
  final VoidCallback onAddToShoppingList;

  static const double _stripeWidth = 5;
  static const double _stripeHeight = 66;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 6),
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(width: _stripeWidth, height: _stripeHeight, color: color),
            Expanded(
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                title: Text(
                  item.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: ExpiryRemainingLabel(item: item),
                trailing: _buildTrailing(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (isAdding) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
      );
    }

    if (isInShoppingList) {
      return Chip(
        label: Text(context.loc.inShoppingListChipLabel),
        avatar: Icon(Icons.check, size: 18, color: cs.onSecondaryContainer),
        backgroundColor: cs.secondaryContainer,
        labelStyle: TextStyle(color: cs.onSecondaryContainer),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      );
    }

    return IconButton(
      icon: const Icon(Icons.add_shopping_cart_outlined),
      tooltip: context.loc.addToShoppingListTitle,
      color: cs.primary,
      onPressed: isAddingAll ? null : onAddToShoppingList,
    );
  }
}