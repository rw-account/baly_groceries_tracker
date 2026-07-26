// lib/screens/expiry/utils/expiry_grouping.dart

import '../../../models/expiry_bucket.dart';
import '../../../models/item_model.dart';

/// Groups items into a map by [ExpiryBucket].
/// All buckets are included as keys in the resulting map, even if they
/// contain no items, while preserving the order in which they are defined in the enum.
Map<ExpiryBucket, List<ItemModel>> groupItemsByExpiryBucket(
  List<ItemModel> items,
) {
  final buckets = <ExpiryBucket, List<ItemModel>>{
    for (final bucket in ExpiryBucket.values) bucket: <ItemModel>[],
  };

  for (final item in items) {
    buckets[ExpiryBucket.fromRemainingDays(item.remainingDays)]!.add(item);
  }

  return buckets;
}
