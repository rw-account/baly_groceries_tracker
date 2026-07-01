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
  // ✅ دالة مساعدة لتوحيد طريقة عرض الـ SnackBar وتنظيف الكود
  void _showSnackBar(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), action: action),
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
                    Text('حذف الكل'),
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
  Future<void> _deleteShoppingItem(ShoppingItem item) async {
    final id = item.id;
    if (id == null) return;

    try {
      await ref.read(shoppingListProvider.notifier).deleteShoppingItem(id);
    } catch (e) {
      _showSnackBar('تعذر حذف "${item.title}"');
      return;
    }

    _showSnackBar(
      'تم حذف "${item.title}"',
      action: SnackBarAction(
        label: 'تراجع',
        onPressed: () => _restoreShoppingItem(item),
      ),
    );
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
      // ملاحظه مهمه: عند تحويل لغة التطبيق الى الانجليزي يجب انك تغير اتجاه ايموجي اليد وتجيب ايموجي يشير للجهه الاخرى
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