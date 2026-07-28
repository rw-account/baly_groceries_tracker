// lib/providers/item_history_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_change_log_model.dart';
import 'storage_service_provider.dart';

final itemHistoryProvider =
    FutureProvider.family<List<ItemChangeLogModel>, String>((ref, itemId) async {
  final storage = ref.watch(storageServiceProvider);
  return await storage.getItemChangeLogs(itemId);
});
