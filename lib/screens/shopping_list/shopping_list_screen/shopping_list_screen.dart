// lib/screens/shopping_list/shopping_list_screen/shopping_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/shopping_list_provider.dart';
import 'widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_paths.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingAsync = ref.watch(shoppingListProvider);

    return Scaffold(
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
          return ShoppingListView(items: items);
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
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    context.push(RoutePaths.addShoppingItemFull);
  }
}
