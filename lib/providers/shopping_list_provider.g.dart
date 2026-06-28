// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ShoppingListNotifier)
final shoppingListProvider = ShoppingListNotifierProvider._();

final class ShoppingListNotifierProvider
    extends $AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingItem>> {
  ShoppingListNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shoppingListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shoppingListNotifierHash();

  @$internal
  @override
  ShoppingListNotifier create() => ShoppingListNotifier();
}

String _$shoppingListNotifierHash() =>
    r'3169cadff4b8a4cb69f4cdb14599c65c93dfb5e8';

abstract class _$ShoppingListNotifier
    extends $AsyncNotifier<List<ShoppingItem>> {
  FutureOr<List<ShoppingItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<ShoppingItem>>, List<ShoppingItem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ShoppingItem>>, List<ShoppingItem>>,
        AsyncValue<List<ShoppingItem>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
