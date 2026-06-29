// lib/screens/shopping_list/shopping_list_screen/shopping_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/shopping_list_provider.dart';
import 'widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_paths.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final shoppingAsync = ref.watch(shoppingListProvider);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('قائمة الشراء'),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        body: shoppingAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ShoppingListEmptyState(
                onAddPressed: () => _navigateToAddScreen(context),
              );
            }
            return ShoppingListView(
              items: items,
              onDelete: _deleteShoppingItem,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'حدث خطأ: $error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70, left: 3),
          child: FloatingActionButton(
            onPressed: () => _navigateToAddScreen(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    context.push(RoutePaths.addShoppingItemFull);
  }

  Future<void> _deleteShoppingItem(ShoppingItem item) async {
    final id = item.id;
    if (id == null) return;

    await ref.read(shoppingListProvider.notifier).deleteShoppingItem(id);
    if (!mounted) return;

    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تم حذف "${item.title}"'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () => _restoreShoppingItem(item),
          ),
        ),
      );
  }

  Future<void> _restoreShoppingItem(ShoppingItem item) async {
    await ref.read(shoppingListProvider.notifier).addShoppingItem(
          title: item.title,
          inventoryItemId: item.inventoryItemId,
          price: item.price,
          isChecked: item.isChecked,
          createdAt: item.createdAt,
        );
  }
}
