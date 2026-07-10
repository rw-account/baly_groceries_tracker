// lib/screens/shopping_list/shopping_list_screen/shopping_list_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/shopping_list_provider.dart';
import '../../../providers/shopping_selection_provider.dart';
import '../../../router/route_paths.dart';
import 'widgets/widgets.dart';

// SharedPreferences key for the swipe-hint flag.
const _kHasSeenSwipeHint = 'has_seen_swipe_hint';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  // ── Undo timer for single-item delete ──────────────────────────────────────
  Timer? _snackBarTimer;

  // ── Swipe-hint flag ────────────────────────────────────────────────────────
  bool _hasSeenSwipeHint = true; // default to true → no flicker on load

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
    _snackBarTimer?.cancel();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final shoppingAsync = ref.watch(shoppingListProvider);
    final selection = ref.watch(shoppingSelectionProvider);
    final isSelecting = selection.isSelecting;

    final showFab = !isSelecting &&
        shoppingAsync.maybeWhen(
          data: (items) => items.isNotEmpty,
          orElse: () => false,
        );

    return PopScope(
      // Intercept the back gesture while in selection mode.
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isSelecting) {
          ref.read(shoppingSelectionProvider.notifier).clearSelection();
        }
      },
      child: Scaffold(
        appBar: isSelecting
            ? _buildSelectionAppBar(context, selection)
            : _buildNormalAppBar(context),
        body: shoppingAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return ShoppingListEmptyState(
                onAddPressed: () =>
                    context.push(RoutePaths.addShoppingItemFull),
              );
            }
            return ShoppingListView(
              items: items,
              onDelete: _deleteShoppingItem,
              isInSelectionMode: isSelecting,
              selectedIds: selection.selectedIds,
              onItemLongPress: (id) => ref
                  .read(shoppingSelectionProvider.notifier)
                  .enterSelectionMode(id),
              onItemTap: (id) => ref
                  .read(shoppingSelectionProvider.notifier)
                  .toggleSelection(id),
              showPeekAnimation: !_hasSeenSwipeHint && items.isNotEmpty,
              onSwipeCompleted: _markSwipeHintSeen,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'حدث خطأ: $error',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ),
        floatingActionButton: showFab
            ? Padding(
                padding: const EdgeInsets.only(bottom: 70, left: 3),
                child: FloatingActionButton(
                  onPressed: () =>
                      context.push(RoutePaths.addShoppingItemFull),
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }

  // ─── AppBars ───────────────────────────────────────────────────────────────

  AppBar _buildNormalAppBar(BuildContext context) {
    return AppBar(
      title: const Text('قائمة الشراء'),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          position: PopupMenuPosition.under,
          onSelected: (value) {
            switch (value) {
              case 'delete_all':
                _confirmDeleteAll();
                break;
              case 'share_list':
                _shareList();
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete_all',
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  const Text('حذف كل العناصر'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share_list',
              child: Row(
                children: [
                  Icon(Icons.share_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  const Text('مشاركة القائمة'),
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
      scrolledUnderElevation: 1,
      backgroundColor: cs.surfaceContainerHighest,
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'إلغاء التحديد',
        onPressed: () =>
            ref.read(shoppingSelectionProvider.notifier).clearSelection(),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          'تم تحديد $count عنصر',
          key: ValueKey(count),
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: cs.error),
          tooltip: 'حذف المحدد',
          onPressed:
              count == 0 ? null : () => _confirmBulkDelete(selection),
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
      _showSnackBar('تعذر حذف "${item.title}"');
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
                'تم حذف "${item.title}"',
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
        action: SnackBarAction(
          label: 'تراجع',
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
      _showSnackBar('تعذر استعادة "${item.title}"');
    }
  }

  // ─── Bulk delete (multi-select) ────────────────────────────────────────────

  Future<void> _confirmBulkDelete(ShoppingSelectionState selection) async {
    final count = selection.count;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف العناصر المحددة'),
        content: Text(
          'هل تريد حذف ($count) عنصر؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('حذف'),
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
      _showSnackBar('تعذر حذف العناصر المحددة');
      return;
    }

    if (!mounted) return;

    // ── Same Undo Logic as _deleteShoppingItem ──────────────────────────────
    const int durationSeconds = 5;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    // Cancel any previous timer to prevent a stale timer from hiding the new SnackBar.
    _snackBarTimer?.cancel();

    scaffoldMessenger.hideCurrentSnackBar();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: durationSeconds),
        content: Row(
          children: [
            Expanded(
              child: Text(
                'تم حذف ($count) عنصر',
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
        action: SnackBarAction(
          label: 'تراجع',
          textColor: theme.colorScheme.onSurface,
          onPressed: () async {
            _snackBarTimer?.cancel(); // ❌ Cancel the sleep timer immediately because the user tapped Undo.
            try {
              await ref
                  .read(shoppingListProvider.notifier)
                  .restoreMultiple(deletedItems);
            } catch (_) {
              _showSnackBar('تعذر استعادة العناصر');
            }
          },
        ),
      ),
    );

    _snackBarTimer = Timer(const Duration(seconds: durationSeconds), () {
      if (mounted) scaffoldMessenger.hideCurrentSnackBar(); // 👈 Called immediately after the timer expires.
    });
  }

  // ─── Delete all ────────────────────────────────────────────────────────────

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف جميع العناصر'),
        content: const Text(
            'هل أنت متأكد من حذف كل عناصر قائمة الشراء؟ لا يمكن التراجع.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ref.read(shoppingListProvider.notifier).clearAll();
      _showSnackBar('تم حذف جميع عناصر قائمة الشراء');
    } catch (_) {
      _showSnackBar('تعذر حذف جميع عناصر قائمة الشراء');
    }
  }

  // ─── Share list ────────────────────────────────────────────────────────────

  Future<void> _shareList() async {
    final items = ref.read(shoppingListProvider).value ?? [];
    if (items.isEmpty) {
      _showSnackBar('القائمة فارغة');
      return;
    }

    bool includePrice = true;
    bool includeChecked = true;

    final result = await showDialog<List<bool>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('خيارات المشاركة'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('تضمين السعر'),
                    value: includePrice,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => includePrice = val);
                      }
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('تضمين حالة الشراء'),
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
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(ctx, [includePrice, includeChecked]),
                  child: const Text('مشاركة'),
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
    buffer.writeln('🛒 قائمة الشراء:');

    for (final item in items) {
      //TODO: ملاحظه مهمه لا تحذفها: عند تحويل لغة التطبيق الى الانجليزي يجب انك تغير اتجاه ايموجي اليد وتجيب ايموجي يشير للجهه الاخرى
      String line = '• ${item.title}';

      if (shouldIncludePrice && item.price != null) {
        line += ' 👈 (السعر: ${item.price})';
      }

      if (shouldIncludeChecked && item.isChecked) {
        line += ' [مكتمل ✓]';
      }

      buffer.writeln(line);
    }

    try {
      SharePlus.instance.share(
        ShareParams(text: buffer.toString()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر مشاركة القائمة: $e')),
      );
    }
  }
}