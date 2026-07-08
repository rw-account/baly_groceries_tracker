// lib/screens/expiry/widgets/expiry_bucket_section.dart

import 'package:flutter/material.dart';

import '../../../models/expiry_bucket.dart';
import '../../../models/item_model.dart';
import 'expiry_item_tile.dart';

class ExpiryBucketSection extends StatelessWidget {
  const ExpiryBucketSection({
    super.key,
    required this.bucket,
    required this.items,
    required this.addingItemIds,
    required this.itemIdsInShoppingList,
    required this.isAddingAll, // <-- أضف هذا
    required this.onAddToShoppingList,
  });

  final ExpiryBucket bucket;
  final List<ItemModel> items;
  final Set<String> addingItemIds;
  final Set<String> itemIdsInShoppingList;
  final bool isAddingAll; // <-- أضف هذا
  final ValueChanged<ItemModel> onAddToShoppingList;

  @override
  Widget build(BuildContext context) {
    final color = bucket.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(color),
        for (final item in items)
          ExpiryItemTile(
            key: ValueKey(item.id),
            item: item,
            color: color,
            isInShoppingList: itemIdsInShoppingList.contains(item.id),
            isAdding: addingItemIds.contains(item.id),
            isAddingAll: isAddingAll, // <-- تمريره هنا
            onAddToShoppingList: () => onAddToShoppingList(item),
          ),
      ],
    );
  }

  Widget _buildHeader(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        children: [
          Icon(bucket.icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            bucket.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${items.length}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
