// lib/core/widgets/shopping_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_item_model.dart';
import '../../providers/shopping_list_provider.dart';
import 'edit_price_dialog.dart';
import 'package:intl/intl.dart';

class ShoppingItemCard extends ConsumerWidget {
  final ShoppingItem item;
  final ValueChanged<ShoppingItem> onDelete;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat('#,##0.###');
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isLinked = item.inventoryItemId != null;
    final hasPrice = item.price != null;
    final priceText = hasPrice ? formatter.format(item.price) : '—';
    final isChecked = item.isChecked;

    final accentColor =
        isLinked ? cs.primary : cs.tertiary;

    return Dismissible(
      key: ValueKey(item.id ?? item.title),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDelete(item),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.delete_outline,
          color: cs.error,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          Icons.delete_outline,
          color: cs.error,
        ),
      ),
      // 💡 قمنا بتغليف الكرت بـ AnimatedOpacity لجعله باهتاً ومريحاً للعين عند الاختيار
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isChecked ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isChecked
                ? cs.surfaceContainerLow
                : cs.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: isChecked ? 0.3 : 0.6),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isChecked ? 0.05 : 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      shape: const CircleBorder(),
                      activeColor: cs.primary,
                      onChanged: item.id == null
                          ? null
                          : (_) => ref
                              .read(shoppingListProvider.notifier)
                              .toggleChecked(item.id!),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(
                          alpha: isChecked ? 0.04 : 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLinked ? Icons.inventory_2_outlined : Icons.edit_note,
                        color: isChecked
                            ? cs.outline.withValues(alpha: 0.4)
                            : accentColor,
                        size: 18,
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
                              fontWeight: isChecked
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              decoration:
                                  isChecked ? TextDecoration.lineThrough : null,
                              color: isChecked
                                  ? cs.outline.withValues(alpha: 0.7)
                                  : cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isLinked
                                ? 'مُتابع في التطبيق'
                                : 'عنصر مُضاف يدوياً',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.outline.withValues(alpha: isChecked ? 0.5 : 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PriceChip(
                      text: priceText,
                      hasPrice: hasPrice,
                      isChecked: isChecked,
                      cs: cs,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: isChecked
                            ? cs.outline.withValues(alpha: 0.4)
                            : cs.primary,
                        size: 20,
                      ),
                      onPressed: isChecked
                          ? null
                          : () => _showEditPriceDialog(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showEditPriceDialog(BuildContext context, WidgetRef ref) async {
    final PriceDialogResult result = await showEditPriceDialog(
      context,
      initialPrice: item.price,
      itemName: item.title,
    );

    if (!result.confirmed) return;
    if (item.id == null) return;
    await ref
        .read(shoppingListProvider.notifier)
        .updatePrice(item.id!, result.price);
  }
}

class _PriceChip extends StatelessWidget {
  final String text;
  final bool hasPrice;
  final bool isChecked;
  final ColorScheme cs;

  const _PriceChip({
    required this.text,
    required this.hasPrice,
    required this.isChecked,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isChecked
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : (hasPrice
                ? cs.primaryContainer
                : cs.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked
              ? cs.outline.withValues(alpha: 0.5)
              : (hasPrice
                  ? cs.onPrimaryContainer
                  : cs.outline),
        ),
      ),
    );
  }
}