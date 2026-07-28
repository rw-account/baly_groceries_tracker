// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'items_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ItemsNotifier)
final itemsProvider = ItemsNotifierProvider._();

final class ItemsNotifierProvider
    extends $AsyncNotifierProvider<ItemsNotifier, List<ItemModel>> {
  ItemsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itemsNotifierHash();

  @$internal
  @override
  ItemsNotifier create() => ItemsNotifier();
}

String _$itemsNotifierHash() => r'0b85313247a068fbb61701856c5d7c74591d8080';

abstract class _$ItemsNotifier extends $AsyncNotifier<List<ItemModel>> {
  FutureOr<List<ItemModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ItemModel>>, List<ItemModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ItemModel>>, List<ItemModel>>,
        AsyncValue<List<ItemModel>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
