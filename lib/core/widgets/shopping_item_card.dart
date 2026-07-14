// lib/core/widgets/shopping_item_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shopping_item_model.dart';
import '../../providers/shopping_list_provider.dart';
import 'edit_price_dialog.dart';
import 'delete_background.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/context_extensions.dart';

class ShoppingItemCard extends ConsumerWidget {
  final ShoppingItem item;
  final ValueChanged<ShoppingItem> onDelete;
  final bool isInSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onSelectionTap;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.isInSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onSelectionTap,
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

    final accentColor = isLinked ? cs.primary : cs.tertiary;

    // Card background: highlight when selected in selection mode
    final cardColor = isSelected
        ? cs.primary.withValues(alpha: 0.18)
        : isChecked
            ? cs.surfaceContainerLow
            : cs.surface;

    final cardBorderColor = isSelected
        ? cs.primary.withValues(alpha: 0.7)
        : cs.outlineVariant.withValues(alpha: isChecked ? 0.3 : 0.6);

    // Build the visual card body
    final cardBody = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: isSelected ? 1.5 : 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isInSelectionMode ? onSelectionTap : null,
          onLongPress: isInSelectionMode ? null : onLongPress,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (!isInSelectionMode && isChecked) ? 0.5 : 1.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Leading: selection checkbox OR shopping-done checkbox
                  if (isInSelectionMode)
                    AnimatedScale(
                      scale: isInSelectionMode ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      child: Checkbox(
                        value: isSelected,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: const CircleBorder(),
                        activeColor: cs.primary,
                        side: BorderSide(color: cs.outline, width: 1.5),
                        onChanged: (_) => onSelectionTap?.call(),
                      ),
                    )
                  else
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
                  const SizedBox(width: 12),
                  // Icon bubble
                  Container(
                    width: 40,
                    height: 40,
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title + subtitle
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
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
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
                              ? context.loc.shoppingItemTrackedInApp
                              : context.loc.shoppingItemManualEntry,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.outline
                                .withValues(alpha: isChecked ? 0.5 : 1.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Price chip
                  _PriceChip(
                    text: priceText,
                    hasPrice: hasPrice,
                    isChecked: isChecked,
                    cs: cs,
                  ),
                  // Edit price button (hidden in selection mode)
                  if (!isInSelectionMode) ...[
                    const SizedBox(width: 8),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Wrap with Dismissible only when NOT in selection mode
    if (isInSelectionMode) {
      return cardBody;
    }

    return Dismissible(
      key: ValueKey(item.id ?? item.title),
      direction: DismissDirection.horizontal,
      onDismissed: (_) => onDelete(item),
      background: DeleteBackground(alignment: AlignmentDirectional.centerStart),
      secondaryBackground: DeleteBackground(alignment: AlignmentDirectional.centerEnd),
      child: cardBody,
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

// ─────────────────────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isChecked
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : (hasPrice ? cs.primaryContainer : cs.surfaceContainerHighest),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          decoration: isChecked ? TextDecoration.lineThrough : null,
          color: isChecked
              ? cs.outline.withValues(alpha: 0.5)
              : (hasPrice ? cs.onPrimaryContainer : cs.outline),
        ),
      ),
    );
  }
}