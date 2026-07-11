// lib/screens/expiry/expiry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utils/item_list_extensions.dart';
import '../../models/expiry_bucket.dart';
import '../../models/item_model.dart';
import '../../models/shopping_item_model.dart';
import '../../providers/items_provider.dart';
import '../../providers/shopping_list_provider.dart';
import 'utils/expiry_grouping.dart';
import 'widgets/expiry_bucket_section.dart';
import 'widgets/expiry_empty_state.dart';
import 'widgets/expiry_notice_card.dart';
import '../../core/utils/context_extensions.dart';

/// Displays inventory items that are about to run out (warning/urgent
/// status only), grouped into static remaining-days buckets.
class ExpiryScreen extends ConsumerStatefulWidget {
  const ExpiryScreen({super.key});

  @override
  ConsumerState<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends ConsumerState<ExpiryScreen> {
  final Set<String> _addingItemIds = {};
  bool _isAddingAll = false;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final shoppingAsync = ref.watch(shoppingListProvider);

    return Scaffold(
appBar: AppBar(
        title: Text(context.loc.expiryScreenTitle),
        actions: [_buildAppBarAction(itemsAsync)],
      ),
      body: itemsAsync.when(
        data: (items) {
          final attentionItems = items.needingAttention;

          if (attentionItems.isEmpty) {
            return const ExpiryEmptyState();
          }

          final buckets = groupItemsByExpiryBucket(attentionItems);
          final shoppingItems = shoppingAsync.value ?? const <ShoppingItem>[];
          final itemIdsInShoppingList = shoppingItems
              .map((s) => s.inventoryItemId)
              .whereType<String>()
              .toSet();

          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            children: [
              const ExpiryNoticeCard(),
              for (final bucket in ExpiryBucket.values)
                if (buckets[bucket]!.isNotEmpty)
                  ExpiryBucketSection(
                    bucket: bucket,
                    items: buckets[bucket]!,
                    addingItemIds: _addingItemIds,
                    itemIdsInShoppingList: itemIdsInShoppingList,
                    isAddingAll: _isAddingAll,
                    onAddToShoppingList: _addToShoppingList,
                  ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(context.loc.errorOccurredFormat(error.toString()))),
      ),
    );
  }

  Widget _buildAppBarAction(AsyncValue<List<ItemModel>> itemsAsync) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isAddingAll) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        if (value != 'add_all') return;
        final items = itemsAsync.value ?? const <ItemModel>[];
        _addAllToShoppingList(items.needingAttention);
      },
      itemBuilder: (context) => [
PopupMenuItem(
          value: 'add_all',
          child: Row(
            children: [
              Icon(Icons.add_shopping_cart, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(context.loc.addAllToShoppingListMenu),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addAllToShoppingList(List<ItemModel> items) async {
    final shoppingItems =
        ref.read(shoppingListProvider).value ?? const <ShoppingItem>[];
    final existingIds =
        shoppingItems.map((s) => s.inventoryItemId).whereType<String>().toSet();

    final itemsToAdd =
        items.where((item) => !existingIds.contains(item.id)).toList();

    if (itemsToAdd.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.allItemsAlreadyInShoppingList,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      }
      return;
    }

    setState(() => _isAddingAll = true);

    final itemsToInsert = itemsToAdd.map((item) => ShoppingItem(
          title: item.name,
          inventoryItemId: item.id,
          price: null,
        )).toList();

    try {
      await ref.read(shoppingListProvider.notifier).addMultipleShoppingItems(itemsToInsert);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.allItemsAddedToShoppingList,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.failedToAddAllItemsFormat(e.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingAll = false);
      }
    }
  }

  Future<void> _addToShoppingList(ItemModel item) async {
    setState(() => _addingItemIds.add(item.id));
    try {
      final wasAdded = await ref.read(shoppingListProvider.notifier).addShoppingItem(
            title: item.name,
            inventoryItemId: item.id,
            price: null,
          );
      if (mounted) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        
        if (wasAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.loc.itemAddedToShoppingListFormat(item.name),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              backgroundColor: colorScheme.surfaceContainerHighest,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.loc.itemAlreadyInShoppingListFormat(item.name),
                style: TextStyle(color: colorScheme.onTertiary),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: colorScheme.tertiary, 
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.loc.failedToAddItemFormat(e.toString()),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingItemIds.remove(item.id));
      }
    }
  }
}
