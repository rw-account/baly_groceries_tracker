// lib/screens/expiry/widgets/expiry_bucket_section.dart

import 'package:flutter/material.dart';

import '../../../models/expiry_bucket.dart';
import '../../../models/item_model.dart';
import 'expiry_item_tile.dart';
import '../../../core/utils/context_extensions.dart';

class ExpiryBucketSection extends StatelessWidget {
  const ExpiryBucketSection({
    super.key,
    required this.bucket,
    required this.items,
    required this.addingItemIds,
    required this.itemIdsInShoppingList,
    required this.isAddingAll,
    required this.onAddToShoppingList,
  });

  final ExpiryBucket bucket;
  final List<ItemModel> items;
  final Set<String> addingItemIds;
  final Set<String> itemIdsInShoppingList;
  final bool isAddingAll;
  final ValueChanged<ItemModel> onAddToShoppingList;

  @override
  Widget build(BuildContext context) {
    final color = bucket.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, color),
        for (final item in items)
          ExpiryItemTile(
            key: ValueKey(item.id),
            item: item,
            color: color,
            isInShoppingList: itemIdsInShoppingList.contains(item.id),
            isAdding: addingItemIds.contains(item.id),
            isAddingAll: isAddingAll,
            onAddToShoppingList: () => onAddToShoppingList(item),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Row(
        children: [
          Icon(bucket.icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            _getBucketLabel(context),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '${items.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBucketLabel(BuildContext context) {
    switch (bucket) {
      case ExpiryBucket.expired:
        return context.loc.expiryBucketExpiredLabel;
      case ExpiryBucket.threeDays:
        return context.loc.expiryBucketThreeDaysLabel;
      case ExpiryBucket.week:
        return context.loc.expiryBucketWeekLabel;
      case ExpiryBucket.twoWeeks:
        return context.loc.expiryBucketTwoWeeksLabel;
      case ExpiryBucket.month:
        return context.loc.expiryBucketMonthLabel;
      case ExpiryBucket.moreThanMonth:
        return context.loc.expiryBucketMoreThanMonthLabel;
    }
  }
}
