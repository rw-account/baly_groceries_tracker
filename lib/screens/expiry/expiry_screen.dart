// lib/screens/expiry/expiry_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';

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
import '../../router/route_paths.dart';

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
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
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
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 16),
          Text(
            context.loc.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: cs.error,
            ),
            const SizedBox(height: 16),
            Text(
              context.loc.errorOccurredFormat(error),
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Restart.restartApp(),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(context.loc.errorRetryLabel),
            ),
          ],
        ),
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
      icon: const Icon(Icons.more_vert_outlined),
      position: PopupMenuPosition.under,
      onSelected: (value) {
        switch (value) {
          case 'add_all':
            final items = itemsAsync.value ?? const <ItemModel>[];
            _addAllToShoppingList(items.needingAttention);
            break;
          case 'settings':
            context.push(RoutePaths.settings);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'add_all',
          child: Row(
            children: [
              Icon(Icons.add_shopping_cart_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(context.loc.addAllToShoppingListMenu),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(context.loc.settings),
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