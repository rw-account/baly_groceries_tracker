// lib/screens/shopping_list/add_shopping_item_screen/widgets/search_view.dart

import 'package:flutter/material.dart';

import '../../../../models/item_model.dart';
import '../../../../models/shopping_item_model.dart';
import '../../../../core/utils/context_extensions.dart';
import 'result_tile.dart';

/// Search mode UI: a search field plus matching inventory/manual results.
///
/// Purely presentational — every list, flag, and piece of derived data is
/// computed by [AddItemCubit] and passed in ready to render. This widget
/// owns only the [TextEditingController] (kept here so typing is instant)
/// and forwards the resulting text via [onSearchChanged].
class SearchView extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final String query;
  final List<ItemModel> matchingInventoryItems;
  final List<ShoppingItem> matchingManualShoppingItems;
  final List<ShoppingItem> shoppingItems;
  final bool isSubmitting;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<ItemModel> onSelectInventoryItem;
  final VoidCallback onEnterManualMode;

  const SearchView({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.query,
    required this.matchingInventoryItems,
    required this.matchingManualShoppingItems,
    required this.shoppingItems,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onSelectInventoryItem,
    required this.onEnterManualMode,
    this.isSubmitting = false,
  });

  bool get _hasResults =>
      matchingInventoryItems.isNotEmpty || matchingManualShoppingItems.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onChanged: onSearchChanged,
            style: const TextStyle(color: Color(0xFFC7D5E0)),
            cursorColor: cs.primary,
            decoration: InputDecoration(
              hintText: context.loc.shoppingSearchHint,
              hintStyle: TextStyle(color: cs.outline),
              prefixIcon: Icon(Icons.add_circle_outline, color: cs.outline),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      tooltip: context.loc.clearSearchTooltip,
                      icon: Icon(Icons.clear, color: cs.outline),
                      onPressed: onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: cs.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: cs.outlineVariant, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: cs.primary, width: 1.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: query.isEmpty
                ? _buildHint(context, context.loc.startTypingHint)
                : ListView(
                    key: const ValueKey('results'),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    children: [
                      // ── زر الإضافة السريع كأول عنصر في القائمة ──
                      _buildQuickAddTile(context),

                      // ── فصل النتائج إذا وجدت ──
                      if (_hasResults) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 6, right: 4),
                          child: Text(
                            context.loc.searchResultsSection,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: cs.outline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        for (final item in matchingInventoryItems)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildInventoryResultTile(context, item),
                          ),
                        for (final shoppingItem in matchingManualShoppingItems)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildManualResultTile(context, shoppingItem),
                          ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHint(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Center(
      key: const ValueKey('hint'),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
    );
  }

  // ─── بطاقة الإضافة السريعة (التصميم المدمج) ───────────────────────────
  Widget _buildQuickAddTile(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: isSubmitting ? null : onEnterManualMode,
        splashColor: cs.primary.withValues(alpha: 0.12),
        highlightColor: cs.primary.withValues(alpha: 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: cs.primary.withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.add_circle_outline,
                color: cs.onPrimaryContainer,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.loc.addAsNewItemFormat(query),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.adaptive.arrow_forward,
                size: 20,
                color: cs.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryResultTile(BuildContext context, ItemModel item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final alreadyInList =
        shoppingItems.any((s) => s.inventoryItemId == item.id);
    final enabled = !alreadyInList && !isSubmitting;
    final color = !alreadyInList ? cs.primary : cs.outline;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // أيقونة المخزون
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            // اسم العنصر وحالته
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? cs.onSurface : cs.outline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (alreadyInList)
                    Text(
                      context.loc.alreadyInShoppingList,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                    ),
                ],
              ),
            ),
            // زر الإضافة أو علامة الوجود
            if (alreadyInList)
              Icon(Icons.check_circle, size: 18, color: cs.outline)
            else
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  color: cs.primary,
                  onPressed: enabled ? () => onSelectInventoryItem(item) : null,
                  tooltip: context.loc.addToShoppingListTitle,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualResultTile(BuildContext context, ShoppingItem item) {
    final theme = Theme.of(context);
    return ResultTile(
      icon: Icons.edit_note,
      color: theme.colorScheme.outline,
      title: item.title,
      subtitle: context.loc.alreadyInShoppingList,
      enabled: false,
      onTap: null,
    );
  }
}
