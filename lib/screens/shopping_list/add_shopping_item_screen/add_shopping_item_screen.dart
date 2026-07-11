// lib/screens/shopping_list/add_shopping_item_screen/add_shopping_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/edit_price_dialog.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../models/item_model.dart';
import 'cubit/add_item_cubit.dart';
import 'cubit/add_item_state.dart';
import 'widgets/manual_entry_form.dart';
import 'widgets/search_view.dart';

/// Screen for adding a new entry to the shopping list, either by selecting
/// an existing inventory item or by entering a manual (free-text) item.
///
/// This widget is purely structural: it creates the [AddItemCubit] (via a
/// Riverpod provider so the Cubit can talk to the existing data providers)
/// and exposes it to the tree. All business logic lives in the Cubit; all
/// presentation lives in [SearchView] and [ManualEntryForm].
class AddShoppingItemScreen extends ConsumerWidget {
  const AddShoppingItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cubit = ref.watch(addItemCubitProvider);

    return BlocProvider<AddItemCubit>.value(
      value: cubit,
      child: const _AddShoppingItemView(),
    );
  }
}

class _AddShoppingItemView extends StatefulWidget {
  const _AddShoppingItemView();

  @override
  State<_AddShoppingItemView> createState() => _AddShoppingItemViewState();
}

class _AddShoppingItemViewState extends State<_AddShoppingItemView> {
  // Controllers stay in the widget tree (never inside the Cubit) so typing
  // is always instant and never waits on a Bloc emit.
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _manualNameController = TextEditingController();
  final _manualPriceController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _manualNameController.dispose();
    _manualPriceController.dispose();
    super.dispose();
  }

  Future<void> _addInventoryItem(BuildContext context, ItemModel item) async {
    final cubit = context.read<AddItemCubit>();
    if (cubit.state.isSubmitting) return;

    final result = await showEditPriceDialog(context, itemName: item.name);
    if (!result.confirmed || !context.mounted) return;

    cubit.addInventoryItem(item, price: result.price);
  }

  String _localizedError(BuildContext context, String errorCode) {
    switch (errorCode) {
      case 'addErrorRetry':
        return context.loc.addErrorRetry;
      case 'itemNotAddedRetry':
        return context.loc.itemNotAddedRetry;
      default:
        return errorCode;
    }
  }

  void _enterManualMode(BuildContext context) {
    _manualNameController.text = _searchController.text.trim();
    // Avoid leaking a price typed during a previous, unrelated attempt.
    _manualPriceController.clear();
    context.read<AddItemCubit>().enterManualMode(_manualNameController.text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AddItemCubit, AddItemState>(
      listenWhen: (previous, current) => previous.eventId != current.eventId,
      listener: (context, state) {
        if (state.status == AddItemStatus.success) {
          context.pop();
        } else if (state.status == AddItemStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(_localizedError(context, state.errorMessage!)),
                backgroundColor: cs.error,
              ),
            );
        }
      },
      child: BlocBuilder<AddItemCubit, AddItemState>(
        builder: (context, state) {
          final isManual = state.mode == AddItemMode.manual;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                isManual ? context.loc.addNewItemTitle : context.loc.addToShoppingListTitle,
              ),
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: isManual
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: state.isSubmitting
                          ? null
                          : () => context.read<AddItemCubit>().exitManualMode(),
                    )
                  : null,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(3),
                child: AnimatedOpacity(
                  opacity: state.isSubmitting ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: cs.primary,
                    backgroundColor: cs.surfaceContainerHighest,
                  ),
                ),
              ),
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: isManual
                  ? _buildManualEntryForm(state)
                  : _buildSearchView(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchView(BuildContext context, AddItemState state) {
    return SearchView(
      key: const ValueKey('search'),
      searchController: _searchController,
      searchFocusNode: _searchFocusNode,
      query: state.query,
      matchingInventoryItems: state.matchingInventoryItems,
      matchingManualShoppingItems: state.matchingManualShoppingItems,
      shoppingItems: state.shoppingItems,
      isSubmitting: state.isSubmitting,
      onSearchChanged: (text) => context.read<AddItemCubit>().onSearchChanged(text),
      onClearSearch: () {
        _searchController.clear();
        context.read<AddItemCubit>().clearSearch();
      },
      onSelectInventoryItem: (item) => _addInventoryItem(context, item),
      onEnterManualMode: () => _enterManualMode(context),
    );
  }

  Widget _buildManualEntryForm(AddItemState state) {
    return ManualEntryForm(
      key: const ValueKey('manual'),
      nameController: _manualNameController,
      priceController: _manualPriceController,
      isDuplicate: state.manualNameDuplicate,
      duplicateMessage: state.manualDuplicateMessage,
      priceError: state.manualPriceError,
      canSubmit: state.canSubmitManual,
      isSubmitting: state.isSubmitting,
      onNameChanged: (text) => context.read<AddItemCubit>().onManualNameChanged(text),
      onPriceChanged: (text) => context.read<AddItemCubit>().onManualPriceChanged(text),
      onSubmit: () => context.read<AddItemCubit>().submitManualItem(),
    );
  }
}
