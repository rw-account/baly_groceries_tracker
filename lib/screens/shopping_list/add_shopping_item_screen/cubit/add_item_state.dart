// lib/screens/shopping_list/add_shopping_item_screen/cubit/add_item_state.dart

import 'package:equatable/equatable.dart';

import '../../../../models/item_model.dart';
import '../../../../models/shopping_item_model.dart';

/// Which UI mode the Add Item screen is currently displaying.
enum AddItemMode { search, manual }

/// Lifecycle status of the current add/select operation.
enum AddItemStatus { idle, submitting, success, error }

/// Immutable state for [AddItemCubit].
///
/// Holds everything the UI needs to render: the current mode, search
/// results, manual-entry validation, and the status of any in-flight
/// submission. All derived data (filtered lists, validation flags) is
/// computed once in the Cubit and stored here, so widgets never need to
/// recompute anything themselves.
class AddItemState extends Equatable {
  const AddItemState({
    this.mode = AddItemMode.search,
    this.status = AddItemStatus.idle,
    this.errorMessage,
    this.eventId = 0,
    this.query = '',
    this.matchingInventoryItems = const [],
    this.matchingManualShoppingItems = const [],
    this.shoppingItems = const [],
    this.manualName = '',
    this.manualPrice = '',
    this.manualNameDuplicate = false,
    this.manualPriceError,
    this.canSubmitManual = false,
  });

  final AddItemMode mode;
  final AddItemStatus status;
  final String? errorMessage;

  /// Incremented every time a transient (success/error) event is emitted.
  /// A [BlocListener] should key off this rather than [status] alone, since
  /// two consecutive failures with the same message would otherwise be
  /// value-equal and only fire once.
  final int eventId;

  // ─── Search mode ────────────────────────────────────────────────────────
  final String query;
  final List<ItemModel> matchingInventoryItems;
  final List<ShoppingItem> matchingManualShoppingItems;
  final List<ShoppingItem> shoppingItems;

  // ─── Manual entry mode ──────────────────────────────────────────────────
  final String manualName;
  final String manualPrice;
  final bool manualNameDuplicate;
  final String? manualPriceError;
  final bool canSubmitManual;

  bool get isSubmitting => status == AddItemStatus.submitting;

  bool get hasSearchResults =>
      matchingInventoryItems.isNotEmpty || matchingManualShoppingItems.isNotEmpty;

  /// Sentinel used to distinguish "leave this field unchanged" from
  /// "explicitly set this nullable field to null" in [copyWith].
  static const _unset = Object();

  AddItemState copyWith({
    AddItemMode? mode,
    AddItemStatus? status,
    Object? errorMessage = _unset,
    int? eventId,
    String? query,
    List<ItemModel>? matchingInventoryItems,
    List<ShoppingItem>? matchingManualShoppingItems,
    List<ShoppingItem>? shoppingItems,
    String? manualName,
    String? manualPrice,
    bool? manualNameDuplicate,
    Object? manualPriceError = _unset,
    bool? canSubmitManual,
  }) {
    return AddItemState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      eventId: eventId ?? this.eventId,
      query: query ?? this.query,
      matchingInventoryItems:
          matchingInventoryItems ?? this.matchingInventoryItems,
      matchingManualShoppingItems:
          matchingManualShoppingItems ?? this.matchingManualShoppingItems,
      shoppingItems: shoppingItems ?? this.shoppingItems,
      manualName: manualName ?? this.manualName,
      manualPrice: manualPrice ?? this.manualPrice,
      manualNameDuplicate: manualNameDuplicate ?? this.manualNameDuplicate,
      manualPriceError: manualPriceError == _unset
          ? this.manualPriceError
          : manualPriceError as String?,
      canSubmitManual: canSubmitManual ?? this.canSubmitManual,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        status,
        errorMessage,
        eventId,
        query,
        matchingInventoryItems,
        matchingManualShoppingItems,
        shoppingItems,
        manualName,
        manualPrice,
        manualNameDuplicate,
        manualPriceError,
        canSubmitManual,
      ];
}
