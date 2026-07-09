// lib/providers/shopping_selection_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingSelectionState {
  const ShoppingSelectionState({
    this.isSelecting = false,
    this.selectedIds = const {},
  });

  final bool isSelecting;
  final Set<int> selectedIds;

  int get count => selectedIds.length;

  ShoppingSelectionState copyWith({
    bool? isSelecting,
    Set<int>? selectedIds,
  }) {
    return ShoppingSelectionState(
      isSelecting: isSelecting ?? this.isSelecting,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingSelectionNotifier extends Notifier<ShoppingSelectionState> {
  @override
  ShoppingSelectionState build() => const ShoppingSelectionState();

  /// Long-press on an item — enters selection mode and selects that item.
  void enterSelectionMode(int id) {
    state = ShoppingSelectionState(
      isSelecting: true,
      selectedIds: {id},
    );
  }

  /// Tap on an item while in selection mode — toggles its selected state.
  void toggleSelection(int id) {
    if (!state.isSelecting) return;
    final next = Set<int>.from(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    // Auto-exit if the last item was deselected.
    state = next.isEmpty
        ? const ShoppingSelectionState()
        : state.copyWith(selectedIds: next);
  }

  /// Cancel button or system back button — exits selection mode.
  void clearSelection() {
    state = const ShoppingSelectionState();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Manages the multi-select state for the shopping list.
/// Using the manual [NotifierProvider] API so no build_runner re-run is needed.
final shoppingSelectionProvider =
    NotifierProvider<ShoppingSelectionNotifier, ShoppingSelectionState>(
  ShoppingSelectionNotifier.new,
);
