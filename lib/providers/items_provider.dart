// lib/providers/items_provider.dart

import 'package:home_orders_tracker/providers/shopping_list_provider.dart';
import 'package:home_orders_tracker/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

part 'items_provider.g.dart';

@riverpod
class ItemsNotifier extends _$ItemsNotifier {
  final _uuid = const Uuid();

  @override
  Future<List<ItemModel>> build() async {
    final storage = ref.watch(storageServiceProvider); // ✅ مسموح داخل build
    final items = await storage.getAllItems();
    return items; // الحالة الأولية جاهزة
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _refreshStateAndNotifications(StorageService storage) async {
    final latestItems = await storage.getAllItems();
    state = AsyncData(latestItems); 
    await NotificationService.scheduleDailySummary(latestItems);
  }

  bool isNameDuplicate(String name, {String? excludeId}) {
    final items = state.value ?? [];
    final normalized = name.trim().toLowerCase();
    return items.any((item) {
      if (excludeId != null && item.id == excludeId) return false;
      return item.name.trim().toLowerCase() == normalized;
    });
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────

  Future<void> addItem({
    required String name,
    required String quantityDescription,
    required int expectedDays,
    String? notes,
    int warningThresholdDays = 10,
    int urgentThresholdDays = 3,
    bool notificationsEnabled = true,
    DateTime? lastRefreshedAt,
  }) async {
    final storage = ref.read(storageServiceProvider);
    final now = DateTime.now();
    final item = ItemModel(
      id: _uuid.v4(),
      name: name,
      quantityDescription: quantityDescription,
      expectedDays: expectedDays,
      createdAt: now,
      warningThresholdDays: warningThresholdDays,
      urgentThresholdDays: urgentThresholdDays,
      notificationsEnabled: notificationsEnabled,
      lastRefreshedAt: lastRefreshedAt ?? now,
      notes: notes,
    );
    await storage.saveItem(item);
    await _refreshStateAndNotifications(storage);
  }

  Future<void> updateItem(ItemModel updated) async {
    final storage = ref.read(storageServiceProvider);
    await storage.saveItem(updated);

    // Update the title of all shopping items associated with this inventory item
    await storage.updateShoppingItemTitleForInventoryItem(
        updated.id, updated.name);

    // Invalidate the shopping list provider to trigger a UI update
    ref.invalidate(shoppingListProvider);

    await _refreshStateAndNotifications(storage);
  }

  Future<void> deleteItem(String id) async {
    final storage = ref.read(storageServiceProvider);

    // Delete all shopping items associated with this inventory item
    await storage.deleteShoppingItemsForInventoryItem(id);

    await storage.deleteItem(id);

    // Invalidate the shopping list provider to trigger a UI update
    ref.invalidate(shoppingListProvider);

    await _refreshStateAndNotifications(storage);
  }

  /// Finds a single item by its [id].
  /// Returns the [ItemModel] if found, or `null` otherwise.
  ItemModel? getItemById(String id) {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id);
    return index == -1 ? null : items[index];
  }

}
