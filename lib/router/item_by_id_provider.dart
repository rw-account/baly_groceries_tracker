// lib/router/item_by_id_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baly_groceries_tracker/providers/items_provider.dart';
import '../models/item_model.dart';

final itemByIdProvider =
    FutureProvider.autoDispose.family<ItemModel?, String>((ref, itemId) async {
  final notifier = ref.watch(itemsProvider.notifier);
  return notifier.getItemById(itemId);
});

