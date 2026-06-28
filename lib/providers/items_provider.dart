// lib/providers/items_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

part 'items_provider.g.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

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

  Future<void> _scheduleNotifications() async {
    final currentItems = state.value ?? [];
    await NotificationService.scheduleDailySummary(currentItems);
  }

  Future<void> _refreshStateAndNotifications(StorageService storage) async {
    state = AsyncData(await storage.getAllItems()); // Note: The state here is provided by the Riverpod package, not created by the user.
    await _scheduleNotifications();
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
    int safeThresholdDays = 20,
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
      safeThresholdDays: safeThresholdDays,
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
    await _refreshStateAndNotifications(storage);
  }

  Future<void> deleteItem(String id) async {
    final storage = ref.read(storageServiceProvider);
    await storage.deleteItem(id);
    await _refreshStateAndNotifications(storage);
  }

  /// Finds a single item by its [id].
  /// Returns the [ItemModel] if found, or `null` otherwise.
  ItemModel? getItemById(String id) {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id);
    return index == -1 ? null : items[index];
  }

  // ─── Refresh lastRefreshedAt ─────────────────────────────────────────────────

  /// Allows the user to renew an item without deleting and recreating it.
  ///
  /// Useful when the same product is purchased again, resetting the remaining
  /// days to today or a custom date.

  /// Sets [lastRefreshedAt] to a user-specified date chosen via the date picker.
  Future<void> updateLastRefreshedAt(String id, DateTime newDate) async {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id); // If the item is not found, it will return -1
    if (index == -1) return;

    final updated = items[index].copyWith(lastRefreshedAt: newDate);
    final storage = ref.read(storageServiceProvider);
    await storage.saveItem(updated);
    await _refreshStateAndNotifications(storage);
  }

  /// Quickly renews the item by setting [lastRefreshedAt] to today's date.
  Future<void> refreshItem(String id) async {
    final items = state.value ?? [];
    final index = items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final updated = items[index].copyWith(lastRefreshedAt: DateTime.now());
    final storage = ref.read(storageServiceProvider);
    await storage.saveItem(updated);
    await _refreshStateAndNotifications(storage);
  }
}
