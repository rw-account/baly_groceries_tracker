import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/shopping_item_model.dart';
import '../../../providers/shopping_list_provider.dart';
import '../../../router/route_paths.dart';
import 'widgets/widgets.dart';

import 'dart:async'; // 👈 تأكد من وجود هذا الاستيراد في أعلى الملف لـ Timer

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  // ✅ دالة مساعدة لتوحيد طريقة عرض الـ SnackBar وتنظيف الكود
  void _showSnackBar(String message,) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message), 
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('حذف كل العناصر'),
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
    Timer? snackBarTimer; // ⏱️ Holds the sleep Timer.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
                      style: const TextStyle(
                        color: Colors.amber,
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
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
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
          textColor: Colors.amber,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(shoppingListProvider.notifier).clearAll();
      _showSnackBar('تم حذف جميع العناصر');
    } catch (_) {
      _showSnackBar('تعذر حذف جميع العناصر');
    }
  }

  // ─── مشاركة القائمة ──────────────────────────────────────────────
  void _shareList() {
    final items = ref.read(shoppingListProvider).value ?? [];
    if (items.isEmpty) {
      _showSnackBar('القائمة فارغة');
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🛒 قائمة الشراء:');
    
    for (final item in items) {
      //TODO: ملاحظه مهمه لا تحذفها: عند تحويل لغة التطبيق الى الانجليزي يجب انك تغير اتجاه ايموجي اليد وتجيب ايموجي يشير للجهه الاخرى
      final price = item.price != null ? ' 👈 (السعر: ${item.price})' : ''; 
      
      final checked = item.isChecked ? ' [مكتمل ✓]' : '';
      
      buffer.writeln('• ${item.title}$price$checked');
    }

    // ✅ الكود الصحيح والآمن للإصدارات الجديدة
    SharePlus.instance.share(
      ShareParams(text: buffer.toString()),
    );
  }
}