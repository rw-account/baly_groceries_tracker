// lib/providers/items_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final itemsProvider =
    StateNotifierProvider<ItemsNotifier, List<ItemModel>>((ref) {
  return ItemsNotifier(ref.read(storageServiceProvider));
});

class ItemsNotifier extends StateNotifier<List<ItemModel>> {
  final StorageService _storage;
  final _uuid = const Uuid();

  ItemsNotifier(this._storage) : super([]) {
    _load();
  }

  // ─── Internal helpers ────────────────────────────────────────────────────────

  Future<void> _load() async {
    state = await _storage.getAllItems();
    await _scheduleNotifications();
  }

  Future<void> _scheduleNotifications() async {
    await NotificationService.scheduleDailySummary(state);
  }

  // ─── Duplicate check ─────────────────────────────────────────────────────────

  /// Returns true if another item already has the same name (case-insensitive,
  /// trimmed). Pass [excludeId] when editing to skip the item itself.
  bool isNameDuplicate(String name, {String? excludeId}) {
    final normalized = name.trim().toLowerCase();
    return state.any((item) {
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
  }) async {
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
      lastRefreshedAt: now,
      notes: notes,
    );
    await _storage.saveItem(item);
    await _load();
  }

  Future<void> updateItem(ItemModel updated) async {
    await _storage.saveItem(updated);
    await _load();
  }

  Future<void> deleteItem(String id) async {
    await _storage.deleteItem(id);
    await _load();
  }

  /// Refreshes [lastRefreshedAt] to right now.
  Future<void> refreshItem(String id) async {
    final index = state.indexWhere((item) => item.id == id); // إذا لم تجد العنصر ترجع سالب واحد
    if (index == -1) return;
    final updated = state[index].copyWith(lastRefreshedAt: DateTime.now());
    await _storage.saveItem(updated);
    await _load();
  }

  /// Sets a custom [lastRefreshedAt] date chosen by the user.
  Future<void> updateLastRefreshedAt(String id, DateTime newDate) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;
    final updated = state[index].copyWith(lastRefreshedAt: newDate);
    await _storage.saveItem(updated);
    await _load();
  }
}
