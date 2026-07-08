// lib/screens/expiry/widgets/expiry_item_tile.dart

import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import 'expiry_remaining_label.dart';

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
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            Container(width: _stripeWidth, height: _stripeHeight, color: color),
            Expanded(
              child: ListTile(
                title: Text(
                  item.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
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
    final colorScheme = Theme.of(context).colorScheme;

    if (isAdding) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      );
    }

    if (isInShoppingList) {
      return Chip(
        label: const Text('في القائمة'),
        avatar: Icon(Icons.check, size: 18, color: colorScheme.onSecondaryContainer),
        backgroundColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
      );
    }

    return IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      tooltip: 'إضافة إلى قائمة الشراء',
      color: colorScheme.primary,
      onPressed: isAddingAll ? null : onAddToShoppingList, 
    );
  }
}