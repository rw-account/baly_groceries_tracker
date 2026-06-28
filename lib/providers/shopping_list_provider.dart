// lib/providers/shopping_list_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/shopping_item_model.dart';
import '../services/storage_service.dart';
import 'items_provider.dart' show storageServiceProvider;

part 'shopping_list_provider.g.dart';

@riverpod
class ShoppingListNotifier extends _$ShoppingListNotifier {
  @override
  Future<List<ShoppingItem>> build() async {
    final storage = ref.watch(storageServiceProvider);
    final items = await storage.getAllShoppingItems();
    return items; // الحالة الأولية جاهزة
  }

  Future<void> _refreshState(StorageService storage) async {
    state = AsyncData(await storage.getAllShoppingItems());
  }

  bool isDuplicate({String? inventoryItemId, required String title}) {
    final items = state.value ?? [];
    if (inventoryItemId != null) {
      return items.any((item) => item.inventoryItemId == inventoryItemId);
    }
    final normalized = title.trim().toLowerCase();
    return items.any((item) =>
        item.title.trim().toLowerCase() == normalized);
  }

  /// Adds a new shopping item unless an equivalent one already exists.
  /// Returns true if the item was added, false if it was a duplicate.
  Future<bool> addShoppingItem({
    required String title,
    String? inventoryItemId,
    double? price,
    bool isChecked = false,
  }) async {
    if (isDuplicate(inventoryItemId: inventoryItemId, title: title)) {
      return false;
    }
    final storage = ref.read(storageServiceProvider);
    final newItem = ShoppingItem(
      title: title,
      inventoryItemId: inventoryItemId,
      price: price,
      isChecked: isChecked,
    );
    await storage.addShoppingItem(newItem);
    await _refreshState(storage);
    return true;
  }

  Future<void> deleteShoppingItem(int id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteShoppingItem(id);
    await _refreshState(storage);
  }

  Future<void> setChecked(int id, bool isChecked) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setShoppingItemChecked(id, isChecked);
    await _refreshState(storage);
  }

  /// Updates the price of the shopping item with the given [id].
  /// Persists the change via [StorageService.updateShoppingItem] and
  /// refreshes the in-memory state afterwards. Does nothing if no item
  /// with the given [id] is found in the current state.
  Future<void> updatePrice(int id, double? newPrice) async {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final storage = ref.read(storageServiceProvider);
    final updatedItem = items[index].copyWith(price: newPrice);
    await storage.updateShoppingItem(updatedItem);
    await _refreshState(storage);
  }

  Future<void> toggleChecked(int id) async {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final updated = items[index].copyWith(isChecked: !items[index].isChecked);
    final storage = ref.read(storageServiceProvider);
    await storage.updateShoppingItem(updated);
    await _refreshState(storage);
}
}