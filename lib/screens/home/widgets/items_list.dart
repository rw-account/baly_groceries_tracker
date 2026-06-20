// lib/screens/home/widgets/items_list.dart
import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../core/widgets/item_card.dart';
import '../../add_edit_item/add_edit_item_screen.dart';

class ItemsList extends StatelessWidget {
  final List<ItemModel> items;

  const ItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditItemScreen(item: item),
            ),
          ),
        );
      },
    );
  }
}