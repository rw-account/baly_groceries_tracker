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
        title: const Text('عناصر على وشك النفاد'),
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
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
      ),
    );
  }

  /// The options icon (⋮) in the AppBar turns into a loading indicator
  /// during the "Add All" operation to prevent repeated taps.
  Widget _buildAppBarAction(AsyncValue<List<ItemModel>> itemsAsync) {
    if (_isAddingAll) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
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
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'add_all',
          child: Row(
            children: [
              Icon(Icons.add_shopping_cart, size: 20),
              SizedBox(width: 8),
              Text('إضافة كل المواد إلى قائمة الشراء'),
            ],
          ),
        ),
      ],
    );
  }

  /// إضافة كل العناصر (غير الآمنة) غير الموجودة مسبقاً في قائمة الشراء，
  /// مع تجاهل ما هو موجود بالفعل.
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
          const SnackBar(
            content: Text('جميع العناصر موجودة بالفعل في قائمة الشراء'),
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
      
      // If the code reaches this point, it means the operation succeeded without errors.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة جميع العناصر الى قائمة الشراء.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء إضافة العناصر إلى قائمة الشراء: $e'),
            backgroundColor: Colors.red,
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
        if (wasAdded){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة "${item.name}" إلى قائمة الشراء'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${item.name}" موجود بالفعل في قائمة الشراء'),
            duration: const Duration(seconds: 2),
            // يمكنك تغيير اللون ليدل على التحذير أو التجاهل
            backgroundColor: Colors.orange, 
          ),
        );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إضافة العنصر: $e'),
            backgroundColor: Colors.red,
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
