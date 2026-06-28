// lib/screens/shopping_list/shopping_list_screen/widgets/shopping_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/shopping_item_model.dart';
import '../../../../providers/shopping_list_provider.dart';
import '../../../../core/widgets/shopping_item_card.dart';
import 'shopping_list_total_bar.dart';

/// Renders the list of shopping items plus the running total bar.
/// Used for the "data" case of [shoppingListProvider] once the list
/// is known to be non-empty.
class ShoppingListView extends ConsumerWidget {
  const ShoppingListView({
    super.key,
    required this.items,
  });

  final List<ShoppingItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ShoppingItemCard(
                  item: item,
                  onDelete: () {
                    if (item.id != null) {
                      ref
                          .read(shoppingListProvider.notifier)
                          .deleteShoppingItem(item.id!);
                    }
                  },
                  onUndo: (deletedItem) {
                    // إعادة إضافة العنصر المحذوف
                    ref.read(shoppingListProvider.notifier).addShoppingItem(
                      title: deletedItem.title,
                      inventoryItemId: deletedItem.inventoryItemId,
                      price: deletedItem.price,
                      isChecked: deletedItem.isChecked,
                    );
                  },
                ),
              );
            },
          ),
        ),
        ShoppingListTotalBar(total: total),
      ],
    );
  }
}
