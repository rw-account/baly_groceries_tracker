// lib/screens/shopping_list/shopping_list_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/shopping_list_provider.dart';
import '../../../router/route_paths.dart';
import 'widgets/widgets.dart';

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  
  // 🔴 Local timer for _deleteShoppingItem() undo SnackBar
  // ⏱️ Used to auto-hide the SnackBar after the undo window expires.
  Timer? snackBarTimer;

  @override
  void dispose() {
    snackBarTimer?.cancel();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message), 
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingAsync = ref.watch(shoppingListProvider);

    final showFab = shoppingAsync.maybeWhen(
      data: (items) => items.isNotEmpty,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
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
                    Icon(Icons.delete_outline, size: 20, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('حذف كل العناصر'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share_list',
                child: Row(
                  children: [
                    Icon(Icons.share_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('مشاركة القائمة'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: shoppingAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return ShoppingListEmptyState(
              onAddPressed: () => context.push(RoutePaths.addShoppingItemFull),
            );
          }
          return ShoppingListView(
            items: items,
            onDelete: _deleteShoppingItem,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'حدث خطأ: $error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ),
      floatingActionButton: showFab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70, left: 3),
              child: FloatingActionButton(
                onPressed: () => context.push(RoutePaths.addShoppingItemFull),
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }

  // ─── حذف عنصر واحد ─────────────────────────────────────────────────
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

    const int durationSeconds = 5; // How long the Undo action remains available.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    // Immediately cancel any previous timer when a new delete operation starts
    // to ensure that an old timer does not "wake up" later and incorrectly dismiss the new SnackBar.
    snackBarTimer?.cancel();

    try {
      await ref.read(shoppingListProvider.notifier).deleteShoppingItem(id);
    } catch (e) {
      _showSnackBar('تعذر حذف "${item.title}"');
      return;
    }

    if (!mounted) return;

    // Hide any existing SnackBar to prevent overlap.
    scaffoldMessenger.hideCurrentSnackBar();

    // Show the enhanced SnackBar with a countdown timer.
    scaffoldMessenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: durationSeconds),
        content: Row(
          children: [
            Expanded(
              child: Text('تم حذف "${item.title}"'),
            ),
            // Circular and numeric countdown timer.
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: durationSeconds.toDouble(), end: 0.0),
              duration: const Duration(seconds: durationSeconds),
              builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${value.ceil()}',
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
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
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.tertiary),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: theme.colorScheme.tertiary,
          onPressed: () {
            snackBarTimer?.cancel();// ❌ Cancel the sleep timer immediately because the user tapped Undo.
            _restoreShoppingItem(item);
          },
        ),
      ),
    );

    // ⏳ Sleep function (5-second timer).
    snackBarTimer = Timer(const Duration(seconds: durationSeconds), () {
      if (mounted) {
        scaffoldMessenger.hideCurrentSnackBar(); // 👈 Called immediately after the timer expires.
      }
    });
  }

  Future<void> _restoreShoppingItem(ShoppingItem item) async {
    await ref.read(shoppingListProvider.notifier).addShoppingItem(
          title: item.title,
          inventoryItemId: item.inventoryItemId,
          price: item.price,
          isChecked: item.isChecked,
          createdAt: item.createdAt,
        );
  }

  // ─── حذف الكل ──────────────────────────────────────────────────────
  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف جميع العناصر'),
        content: const Text('هل أنت متأكد من حذف كل عناصر قائمة الشراء؟ لا يمكن التراجع.'),
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

  // ─── مشاركة القائمة ──────────────────────────────────────────────
  Future<void> _shareList() async {
    final items = ref.read(shoppingListProvider).value ?? [];
    if (items.isEmpty) {
      _showSnackBar('القائمة فارغة');
      return;
    }

    // القيم الافتراضية (كل شيء محدد)
    bool includePrice = true;
    bool includeChecked = true;

    // إظهار نافذة خيارات المشاركة
    // بارامتر barrierDismissible: true (افتراضي) يسمح بالإغلاق عند الضغط خارج النافذة
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
                  // إرجاع null عند الإلغاء
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  // إرجاع القيم المحددة عند الموافقة
                  onPressed: () => Navigator.pop(ctx, [includePrice, includeChecked]),
                  child: const Text('مشاركة'),
                ),
              ],
            );
          },
        );
      },
    );

    // إذا أغلق المستخدم النافذة (بالضغط خارجها أو زر الإلغاء)، لا تفعل شيئاً
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

    // مشاركة النص المجمّع
    SharePlus.instance.share(
      ShareParams(text: buffer.toString()),
    );
  }
}