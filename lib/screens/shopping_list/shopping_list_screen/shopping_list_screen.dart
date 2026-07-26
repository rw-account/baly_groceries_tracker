// lib/screens/shopping_list/shopping_list_screen/shopping_list_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/shopping_list_provider.dart';
import '../../../providers/shopping_selection_provider.dart';
import '../../../router/route_paths.dart';
import '../../../core/utils/context_extensions.dart';
import 'widgets/widgets.dart';
import 'package:intl/intl.dart';

const _kHasSeenSwipeHint = 'has_seen_swipe_hint';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  // Undo timer for single-item delete
  Timer? _snackBarTimer;

  bool _hasSeenSwipeHint = true;

  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSwipeHintFlag();
  }

  Future<void> _loadSwipeHintFlag() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hasSeenSwipeHint = prefs.getBool(_kHasSeenSwipeHint) ?? false;
    });
  }

  Future<void> _markSwipeHintSeen() async {
    if (_hasSeenSwipeHint) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHasSeenSwipeHint, true);
    if (!mounted) return;
    setState(() => _hasSeenSwipeHint = true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _snackBarTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: cs.onSurface)),
          backgroundColor: cs.surfaceContainerHighest,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shoppingAsync = ref.watch(shoppingListProvider);
    final selection = ref.watch(shoppingSelectionProvider);
    final isSelecting = selection.isSelecting;

    final showFab = !isSelecting &&
        !_isSearching &&
        shoppingAsync.maybeWhen(
          data: (items) => items.isNotEmpty,
          orElse: () => false,
        );

    return PopScope(
      canPop: !isSelecting && !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isSearching) {
          _toggleSearch();
        } else if (isSelecting) {
          ref.read(shoppingSelectionProvider.notifier).clearSelection();
        }
      },
      child: Scaffold(
        appBar: isSelecting
            ? _buildSelectionAppBar(context, selection)
            : _isSearching
                ? _buildSearchAppBar(context)
                : _buildNormalAppBar(context),
        body: shoppingAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ShoppingListEmptyState(
                onAddPressed: () => context.push(RoutePaths.addShoppingItemFull),
              );
            }

            if (_isSearching) {
              if (_searchQuery.isEmpty) {
                return const SizedBox.shrink();
              }

              final searchResults = items
                  .where((item) => item.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

              if (searchResults.isEmpty) {
                return _buildEmptySearchState(context);
              }

              return ShoppingListView(
                items: searchResults,
                onDelete: _deleteShoppingItem,
                isInSelectionMode: isSelecting,
                isSearching: _isSearching,
                selectedIds: selection.selectedIds,
                onItemLongPress: (id) {
                  if (_isSearching) _toggleSearch();
                  ref.read(shoppingSelectionProvider.notifier).enterSelectionMode(id);
                },
                onItemTap: (id) => ref.read(shoppingSelectionProvider.notifier).toggleSelection(id),
                showPeekAnimation: false, // Disable peek animation during search
                onSwipeCompleted: _markSwipeHintSeen,
              );
            }

            return ShoppingListView(
              items: items,
              onDelete: _deleteShoppingItem,
              isInSelectionMode: isSelecting,
              isSearching: _isSearching,
              selectedIds: selection.selectedIds,
              onItemLongPress: (id) => ref.read(shoppingSelectionProvider.notifier).enterSelectionMode(id),
              onItemTap: (id) => ref.read(shoppingSelectionProvider.notifier).toggleSelection(id),
              showPeekAnimation: !_hasSeenSwipeHint && items.isNotEmpty,
              onSwipeCompleted: _markSwipeHintSeen,
            );
          },
          loading: () => _buildLoadingState(context),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
        floatingActionButton: showFab
            ? Padding(
                padding: const EdgeInsets.only(right: 15, left: 15, bottom: 90),
                child: SizedBox(
                  height: 62,
                  width: 62,
                  child: FloatingActionButton(
                    onPressed: () {
                      context.push(RoutePaths.addShoppingItemFull);
                    },
                    child: const Icon(Icons.add_outlined, size: 31),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // ─── Search UI ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildSearchAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        onPressed: _toggleSearch,
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
        decoration: InputDecoration(
          hintText: context.loc.searchHint,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: cs.onSurfaceVariant, size: 24),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          filled: false,
          isDense: true,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
    );
  }

  Widget _buildEmptySearchState(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.loc.noResultsFound,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading & Error States ────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: 16),
          Text(
            context.loc.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: cs.error),
            const SizedBox(height: 16),
            Text(
              context.loc.errorOccurredFormat(error),
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Restart.restartApp(),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(context.loc.errorRetryLabel),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AppBars ───────────────────────────────────────────────────────────────

  AppBar _buildNormalAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(context.loc.shoppingListTitle),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      actions: [
        IconButton(
          icon: Icon(Icons.search_outlined, color: cs.onSurface),
          tooltip: context.loc.searchHint,
          onPressed: _toggleSearch,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_outlined),
          position: PopupMenuPosition.under,
          onSelected: (value) {
            switch (value) {
              case 'delete_all':
                _confirmDeleteAll();
                break;
              case 'share_list':
                _shareList();
                break;
              case 'settings':
                context.push(RoutePaths.settings);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete_all',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 20, color: cs.error),
                  const SizedBox(width: 12),
                  Text(context.loc.deleteAllItemsMenu),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share_list',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(context.loc.shareListMenu),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(context.loc.settings),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  AppBar _buildSelectionAppBar(
      BuildContext context, ShoppingSelectionState selection) {
    final cs = Theme.of(context).colorScheme;
    final count = selection.count;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surfaceContainerHighest,
      leading: IconButton(
        icon: const Icon(Icons.close_outlined),
        tooltip: context.loc.clearSelectionTooltip,
        onPressed: () =>
            ref.read(shoppingSelectionProvider.notifier).clearSelection(),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          context.loc.selectedCountFormat(count.toString()),
          key: ValueKey(count),
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: cs.error),
          tooltip: context.loc.deleteSelectedTooltip,
          onPressed: count == 0 ? null : () => _confirmBulkDelete(selection),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─── Single-item delete (swipe) ────────────────────────────────────────────
  //
  // NOTE: This non-standard approach was adopted after trying the usual
  // ways of showing a SnackBar with an "Undo" action. The issue was that
  // the SnackBar would remain visible and would not dismiss automatically
  // after the user tapped "Undo".
  //
  // This solution uses a Timer to take full control over dismissing the
  // SnackBar manually after 5 seconds, regardless of widget rebuilds.
  // A visible countdown was also added to improve the user experience by
  // showing how much time remains to undo the action.
  //
  // If the SnackBar behavior is improved in future Flutter releases,
  // this can be replaced with the standard approach (a regular SnackBar
  // using the action property).
  
  Future<void> _deleteShoppingItem(ShoppingItem item) async {
    final id = item.id;
    if (id == null) return;

    const int durationSeconds = 5;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    // Cancel any previous timer to prevent a stale timer from hiding the new SnackBar.
    _snackBarTimer?.cancel();

    try {
      await ref.read(shoppingListProvider.notifier).deleteShoppingItem(id);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(context.loc.failedToDeleteFormat(item.title));
      return;
    }

    if (!mounted) return;

    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: durationSeconds),
        content: Row(
          children: [
            Expanded(
              child: Text(
                context.loc.deletedFormat(item.title),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: durationSeconds.toDouble(), end: 0.0),
              duration: const Duration(seconds: durationSeconds),
              builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.ceil()}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        value: value / durationSeconds,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: context.loc.undoLabel,
          textColor: theme.colorScheme.onSurface,
          onPressed: () {
            _snackBarTimer?.cancel();// ❌ Cancel the sleep timer immediately because the user tapped Undo.
            _restoreShoppingItem(item);
          },
        ),
      ),
    );

    _snackBarTimer = Timer(const Duration(seconds: durationSeconds), () {
      if (mounted) scaffoldMessenger.hideCurrentSnackBar();// 👈 Called immediately after the timer expires.
    });
  }

  Future<void> _restoreShoppingItem(ShoppingItem item) async {
    try {
      await ref.read(shoppingListProvider.notifier).addShoppingItem(
            title: item.title,
            inventoryItemId: item.inventoryItemId,
            price: item.price,
            isChecked: item.isChecked,
            createdAt: item.createdAt,
          );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(context.loc.failedToRestoreFormat(item.title));
    }
  }

  // ─── Bulk delete (multi-select) ────────────────────────────────────────────

  Future<void> _confirmBulkDelete(ShoppingSelectionState selection) async {
    final count = selection.count;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(context.loc.deleteSelectedTitle),
        content: Text(
          context.loc.confirmDeleteSelectedFormat(count.toString()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.deleteButtonLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Capture the items BEFORE deletion so we can restore on undo.
    final allItems = ref.read(shoppingListProvider).value ?? [];
    final selectedIds = selection.selectedIds.toList();
    final deletedItems = allItems
        .where((item) => item.id != null && selectedIds.contains(item.id))
        .toList();

    // Exit selection mode immediately for snappy UX.
    ref.read(shoppingSelectionProvider.notifier).clearSelection();

    try {
      await ref
          .read(shoppingListProvider.notifier)
          .deleteMultiple(selectedIds);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(context.loc.failedToDeleteSelected);
      return;
    }

    if (!mounted) return;

    // Same Undo Logic as _deleteShoppingItem
    const int durationSeconds = 5;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    _snackBarTimer?.cancel();

    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: durationSeconds),
        content: Row(
          children: [
            Expanded(
              child: Text(
                context.loc.deletedSelectedFormat(count.toString()),
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                  begin: durationSeconds.toDouble(), end: 0.0),
              duration: const Duration(seconds: durationSeconds),
              builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.ceil()}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        value: value / durationSeconds,
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: context.loc.undoLabel,
          textColor: theme.colorScheme.onSurface,
          onPressed: () async {
            _snackBarTimer?.cancel();
            try {
              await ref
                  .read(shoppingListProvider.notifier)
                  .restoreMultiple(deletedItems);
            } catch (_) {
              if (!mounted) return;
              _showSnackBar(context.loc.failedToRestoreItems);
            }
          },
        ),
      ),
    );

    _snackBarTimer = Timer(const Duration(seconds: durationSeconds), () {
      if (mounted) scaffoldMessenger.hideCurrentSnackBar();
    });
  }

  // ─── Delete all ──────────────────────────────────────────────────────────────

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(context.loc.deleteAllTitle),
        content: Text(context.loc.confirmDeleteAllMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.deleteAllButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(shoppingListProvider.notifier).clearAll();
      if (!mounted) return;
      _showSnackBar(context.loc.deletedAllItems);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(context.loc.failedToDeleteAllItems);
    }
  }

  // ─── Share list ──────────────────────────────────────────────────────────────

  Future<void> _shareList() async {
    final items = ref.read(shoppingListProvider).value ?? [];
    if (items.isEmpty) {
      _showSnackBar(context.loc.listIsEmpty);
      return;
    }

    bool includePrice = true;
    bool includeChecked = true;

    final result = await showDialog<List<bool>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog.adaptive(
              title: Text(context.loc.shareOptionsTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: Text(context.loc.includePrice),
                    value: includePrice,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => includePrice = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: Text(context.loc.includePurchaseStatus),
                    value: includeChecked,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => includeChecked = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(context.loc.cancelLabel),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, [includePrice, includeChecked]),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(80, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(context.loc.shareLabel),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final shouldIncludePrice = result[0];
    final shouldIncludeChecked = result[1];

    final buffer = StringBuffer();
    if (!mounted) return;
    buffer.writeln(context.loc.shareListHeader);
    buffer.writeln('\n━━━━━━━━━━━━━━━━━━━━\n');

    for (final item in items) {
      buffer.writeln('• ${item.title}');

      if (shouldIncludePrice && item.price != null) {
        if (!mounted) return;
        buffer.writeln(
          context.loc.priceFormat(NumberFormat('#,##0.###').format(item.price).toString()),
        );
      }

      if (shouldIncludeChecked && item.isChecked) {
        if (!mounted) return;
        buffer.writeln(context.loc.completedFormat);
      } else if (shouldIncludeChecked && !item.isChecked) {
        if (!mounted) return;
        buffer.writeln(context.loc.notCompletedFormat);
      }

      buffer.writeln();
    }

    try {
      SharePlus.instance.share(ShareParams(text: buffer.toString()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.failedToShareList(e.toString()))),
      );
    }
  }
}