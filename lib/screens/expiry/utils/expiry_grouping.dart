// lib/screens/expiry/utils/expiry_grouping.dart

import '../../../models/expiry_bucket.dart';
import '../../../models/item_model.dart';

/// يجمع العناصر في خريطة حسب فئة [ExpiryBucket].
/// جميع الفئات تكون موجودة كمفاتيح في الخريطة الناتجة، حتى إذا لم
/// تحتوي على أي عناصر، مع الحفاظ على ترتيب تعريفها في الـ enum.
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
