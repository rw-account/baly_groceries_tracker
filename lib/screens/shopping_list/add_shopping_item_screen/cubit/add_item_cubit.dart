// lib/screens/shopping_list/add_shopping_item_screen/cubit/add_item_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/item_model.dart';
import '../../../../models/shopping_item_model.dart';
import '../../../../providers/items_provider.dart';
import '../../../../providers/shopping_list_provider.dart';
import 'add_item_state.dart';

/// Owns every piece of logic for the Add Item screen: search debouncing,
/// inventory/manual-item filtering, manual-entry validation, mode
/// switching, and talking to the Riverpod providers to read or persist
/// data. The UI layer (screen + widgets) only ever calls methods on this
/// Cubit and renders [AddItemState] — it holds no business logic itself.
///
/// Note: [TextEditingController]s deliberately do NOT live here. They stay
/// in the widget tree so typing never waits on a Cubit emit; only the
/// resulting text is forwarded to this Cubit.
class AddItemCubit extends Cubit<AddItemState> {
  AddItemCubit(this._ref) : super(const AddItemState()) {
    // Keep local caches of the Riverpod-backed lists in sync, and recompute
    // search results whenever either source list changes.
    _ref.listen<AsyncValue<List<ItemModel>>>(
      itemsProvider,
      (previous, next) {
        _allItems = next.value ?? const [];
        _recomputeSearchResults();
        if (state.mode == AddItemMode.manual) _validateManualEntry();
      },
      fireImmediately: true,
    );
    _ref.listen<AsyncValue<List<ShoppingItem>>>(
      shoppingListProvider,
      (previous, next) {
        _allShoppingItems = next.value ?? const [];
        _recomputeSearchResults();
        if (state.mode == AddItemMode.manual) _validateManualEntry();
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  Timer? _debounce;

  List<ItemModel> _allItems = const [];
  List<ShoppingItem> _allShoppingItems = const [];

  static const _debounceDuration = Duration(milliseconds: 200);

  // ─── Search mode ──────────────────────────────────────────────────────

  /// Called on every keystroke in the search field. Debounced so fast
  /// typing doesn't trigger a filtering pass on every single character.
  void onSearchChanged(String rawQuery) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      emit(state.copyWith(query: rawQuery.trim()));
      _recomputeSearchResults();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    emit(state.copyWith(query: ''));
    _recomputeSearchResults();
  }

  void _recomputeSearchResults() {
    final lowerQuery = state.query.toLowerCase();

    final matchingInventoryItems = lowerQuery.isEmpty
        ? const <ItemModel>[]
        : _allItems
            .where((i) => i.name.toLowerCase().contains(lowerQuery))
            .toList();

    final matchingManualShoppingItems = lowerQuery.isEmpty
        ? const <ShoppingItem>[]
        : _allShoppingItems
            .where((s) =>
                s.inventoryItemId == null &&
                s.title.toLowerCase().contains(lowerQuery))
            .toList();

    emit(state.copyWith(
      shoppingItems: _allShoppingItems,
      matchingInventoryItems: matchingInventoryItems,
      matchingManualShoppingItems: matchingManualShoppingItems,
    ));
  }

  void enterManualMode(String prefillName) {
    emit(state.copyWith(
      mode: AddItemMode.manual,
      manualName: prefillName.trim(),
      manualPrice: '',
    ));
    _validateManualEntry();
  }

  void exitManualMode() {
    if (state.isSubmitting) return;
    emit(state.copyWith(mode: AddItemMode.search));
  }

  Future<void> addInventoryItem(ItemModel item,
      {required double? price}) async {
    if (state.isSubmitting) return;

    emit(state.copyWith(status: AddItemStatus.submitting, errorMessage: null));
    try {
      final added =
          await _ref.read(shoppingListProvider.notifier).addShoppingItem(
                title: item.name,
                inventoryItemId: item.id,
                price: price,
              );
      if (isClosed) return;
      _emitResult(added);
    } catch (_) {
      if (isClosed) return;
      _emitFailure('حدث خطأ أثناء الإضافة، حاول مرة أخرى');
    }
  }

  // ─── Manual entry mode ────────────────────────────────────────────────

  void onManualNameChanged(String name) {
    emit(state.copyWith(manualName: name));
    _validateManualEntry();
  }

  void onManualPriceChanged(String price) {
    emit(state.copyWith(manualPrice: price));
    _validateManualEntry();
  }

  /// Validates the manual-entry fields and updates duplicate/price-error
  /// flags. Price is optional: an empty field is treated as valid.
  void _validateManualEntry() {
    final name = state.manualName.trim();
    final normalizedName = name.toLowerCase();
    final isDuplicate = name.isNotEmpty &&
        (_allItems.any(
                (item) => item.name.trim().toLowerCase() == normalizedName) ||
            _allShoppingItems.any(
              (item) => item.title.trim().toLowerCase() == normalizedName,
            ));

    final priceText = state.manualPrice.trim();
    String? priceError;
    if (priceText.isNotEmpty) {
      final value = double.tryParse(priceText);
      if (value == null) {
        priceError = 'صيغة السعر غير صحيحة';
      } else if (value < 0) {
        priceError = 'السعر لا يمكن أن يكون سالبًا';
      }
    }

    final canSubmit = !state.isSubmitting &&
        name.isNotEmpty &&
        !isDuplicate &&
        priceError == null;

    emit(state.copyWith(
      manualNameDuplicate: isDuplicate,
      manualPriceError: priceError,
      canSubmitManual: canSubmit,
    ));
  }

  Future<void> submitManualItem() async {
    if (!state.canSubmitManual) return;

    final name = state.manualName.trim();
    final priceText = state.manualPrice.trim();
    final price = priceText.isEmpty ? null : double.parse(priceText);

    emit(state.copyWith(status: AddItemStatus.submitting, errorMessage: null));
    try {
      final added =
          await _ref.read(shoppingListProvider.notifier).addShoppingItem(
                title: name,
                inventoryItemId: null,
                price: price,
              );
      if (isClosed) return;
      _emitResult(added);
    } catch (_) {
      if (isClosed) return;
      _emitFailure('حدث خطأ أثناء الإضافة، حاول مرة أخرى');
    }
  }

  // ─── Shared helpers ───────────────────────────────────────────────────

  void _emitResult(bool added) {
    if (added) {
      emit(state.copyWith(
        status: AddItemStatus.success,
        eventId: state.eventId + 1,
      ));
    } else {
      _emitFailure('لم تتم إضافة العنصر، حاول مرة أخرى');
    }
  }

  void _emitFailure(String message) {
    emit(state.copyWith(
      status: AddItemStatus.error,
      errorMessage: message,
      eventId: state.eventId + 1,
    ));
    // Refresh manual-entry validation now that isSubmitting is false again,
    // so the submit button re-enables after a failed attempt.
    if (state.mode == AddItemMode.manual) _validateManualEntry();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

/// Bridges Riverpod and Bloc: this Cubit needs a [Ref] to read/listen to
/// the existing Riverpod providers, so it's constructed inside a Riverpod
/// provider (giving it that `ref`) and then exposed to the widget tree via
/// `BlocProvider.value` at the screen root.
final addItemCubitProvider = Provider.autoDispose<AddItemCubit>((ref) {
  final cubit = AddItemCubit(ref);
  ref.onDispose(cubit.close);
  return cubit;
});
