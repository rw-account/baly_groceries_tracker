// lib/screens/shopping_list/add_shopping_item_screen/widgets/search_view.dart

import 'package:flutter/material.dart';

import '../../../../models/item_model.dart';
import '../../../../models/shopping_item_model.dart';
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
            decoration: InputDecoration(
              hintText: 'ابحث أو أنشئ عنصرًا...',
              prefixIcon: const Icon(Icons.add_circle_outline),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      tooltip: 'مسح البحث',
                      icon: const Icon(Icons.clear),
                      onPressed: onClearSearch,
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: query.isEmpty
                ? _buildHint(theme, 'ابدأ بكتابة اسم العنصر للاضافة')
                : !_hasResults
                    ? _buildNoResultsView(theme)
                    : ListView(
                        key: const ValueKey('results'),
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                        children: [
                          for (final item in matchingInventoryItems)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildInventoryResultTile(theme, item),
                            ),
                          for (final shoppingItem in matchingManualShoppingItems)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildManualResultTile(theme, shoppingItem),
                            ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildHint(ThemeData theme, String text) {
    return Center(
      key: const ValueKey('hint'),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildNoResultsView(ThemeData theme) {
    return Center(
      key: const ValueKey('no_results'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج مطابقة',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'استخدم الزر أعلاه لإضافته كعنصر جديد',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryResultTile(ThemeData theme, ItemModel item) {
    final alreadyInList =
        shoppingItems.any((s) => s.inventoryItemId == item.id);
    final enabled = !alreadyInList && !isSubmitting;
    final color = !alreadyInList
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // أيقونة المخزون
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, color: color, size: 20),
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
                      color: enabled
                          ? null
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (alreadyInList)
                    Text(
                      'موجود في قائمة الشراء',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // زر الإضافة أو علامة الوجود
            if (alreadyInList)
              Icon(Icons.check_circle,
                  size: 18, color: theme.colorScheme.onSurfaceVariant)
            else
              IconButton(
                icon: const Icon(Icons.add_shopping_cart),
                color: theme.colorScheme.primary,
                onPressed: enabled ? () => onSelectInventoryItem(item) : null,
                tooltip: 'إضافة إلى قائمة الشراء',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualResultTile(ThemeData theme, ShoppingItem item) {
    return ResultTile(
      icon: Icons.edit_note,
      color: theme.colorScheme.onSurfaceVariant,
      title: item.title,
      subtitle: 'موجود في قائمة الشراء',
      enabled: false,
      onTap: null,
    );
  }
}
