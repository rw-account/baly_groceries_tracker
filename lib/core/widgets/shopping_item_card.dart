// lib/core/widgets/shopping_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_item_model.dart';
import '../../providers/shopping_list_provider.dart';
import 'edit_price_dialog.dart';
import 'package:intl/intl.dart';

class ShoppingItemCard extends ConsumerWidget {
  final ShoppingItem item;
  final VoidCallback onDelete;

  final ValueChanged<ShoppingItem>? onUndo;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat('#,##0.###');
    final theme = Theme.of(context);
    final isLinked = item.inventoryItemId != null;
    final hasPrice = item.price != null;
    final priceText = hasPrice ? formatter.format(item.price) : '—';
    final isChecked = item.isChecked;

    final accentColor =
        isLinked ? theme.colorScheme.primary : theme.colorScheme.tertiary;

    return Dismissible(
      key: ValueKey(item.id ?? item.title),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => _handleDismissed(context),
      background: const SizedBox.shrink(),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showEditPriceDialog(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  // Leading checkbox ("تم شراؤه") — first in the children
                  // list, so it renders at the start edge (right side in
                  // RTL) automatically.
                  Checkbox(
                    value: isChecked,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: const CircleBorder(),
                    activeColor: theme.colorScheme.primary,
                    onChanged: item.id == null
                        ? null
                        : (_) => ref
                            .read(shoppingListProvider.notifier)
                            .toggleChecked(item.id!),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(
                        alpha: isChecked ? 0.06 : 0.12,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLinked ? Icons.inventory_2_outlined : Icons.edit_note,
                      color: isChecked
                          ? accentColor.withValues(alpha: 0.5)
                          : accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: isChecked
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLinked ? 'مرتبط بعنصر مخزون' : 'عنصر مُضاف يدوياً',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PriceChip(
                    text: priceText,
                    hasPrice: hasPrice,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Deletes the item immediately, then offers a few seconds to undo
  /// via a SnackBar instead of blocking with a confirmation dialog.
  void _handleDismissed(BuildContext context) {
    onDelete();

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('تم حذف "${item.title}"'),
        duration: const Duration(seconds: 5),
        action: onUndo == null
            ? null
            : SnackBarAction(
                label: 'تراجع',
                onPressed: () => onUndo!(item),
              ),
      ),
    );
  }

  Future<void> _showEditPriceDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({bool confirmed, double? price})>(
      context: context,
      builder: (_) => EditPriceDialog(initialPrice: item.price),
    );

    if (result == null || !result.confirmed) return;
    if (item.id == null) return;
    await ref
        .read(shoppingListProvider.notifier)
        .updatePrice(item.id!, result.price);
  }
}

/// Small tappable-looking price badge with an edit affordance, so it's
/// clear at a glance that the price can be changed (not just displayed).
class _PriceChip extends StatelessWidget {
  final String text;
  final bool hasPrice;
  final ThemeData theme;

  const _PriceChip({
    required this.text,
    required this.hasPrice,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasPrice
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: hasPrice
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.edit_outlined,
            size: 14,
            color: hasPrice
                ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}