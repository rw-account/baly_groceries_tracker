// lib/core/widgets/shopping_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_item_model.dart';
import '../../providers/shopping_list_provider.dart';
import 'edit_price_dialog.dart';
import 'package:intl/intl.dart';

/// A single card representing one [ShoppingItem] in the shopping list.
class ShoppingItemCard extends ConsumerWidget {
  final ShoppingItem item;
  final VoidCallback onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat('#,##0.###');
    final theme = Theme.of(context);
    final isLinked = item.inventoryItemId != null;
    final hasPrice = item.price != null;
    final priceText = hasPrice ? formatter.format(item.price) : '—';

    final accentColor =
        isLinked ? theme.colorScheme.primary : theme.colorScheme.tertiary;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEditPriceDialog(context, ref),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLinked ? Icons.inventory_2_outlined : Icons.edit_note,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: hasPrice
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  priceText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: hasPrice
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              IconButton(
                icon:
                    Icon(Icons.delete_outline, color: theme.colorScheme.error),
                tooltip: 'حذف',
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${item.title}" من قائمة الشراء؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onDelete();
    }
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