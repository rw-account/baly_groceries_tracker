// lib/screens/home/widgets/items_list.dart
import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../core/widgets/item_card.dart';
import 'package:go_router/go_router.dart';
import '../../../router/route_paths.dart';

class ItemsList extends StatelessWidget {
  final List<ItemModel> items;

  const ItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 172),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(
          item: item,
          onTap: () => context.push(RoutePaths.editItemPath(item.id), extra: item),
        );
      },
    );
  }
}