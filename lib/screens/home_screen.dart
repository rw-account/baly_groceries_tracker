// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../providers/items_provider.dart';
import '../widgets/item_card.dart';
import 'add_edit_item_screen.dart';
import '../main.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) requestBatteryOptimizationExemption(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(itemsProvider);
    final theme = Theme.of(context);

    final urgentCount =
        items.where((i) => i.status == ItemStatus.urgent).length;
    final warningCount =
        items.where((i) => i.status == ItemStatus.warning).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('متابعة طلبات البيت'),
        centerTitle: false,
        actions: [
          if (urgentCount > 0 || warningCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: _SummaryBadge(
                urgentCount: urgentCount,
                warningCount: warningCount,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'settings':
                    // افتح صفحة الإعدادات
                    break;

                  case 'about':
                    // افتح صفحة حول التطبيق
                    break;

                  case 'delete_all':
                    // حذف جميع العناصر
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'settings',
                  child: Text('الإعدادات'),
                ),
                const PopupMenuItem(
                  value: 'about',
                  child: Text('حول التطبيق'),
                ),
                const PopupMenuItem(
                  value: 'delete_all',
                  child: Text('حذف الكل'),
                ),
              ],
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد مواد بعد',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اضغط زر اضافة مادة جديدة',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ItemCard(
                  item: item,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditItemScreen(item: item),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('إضافة مادة'),
      ),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final int urgentCount;
  final int warningCount;

  const _SummaryBadge({
    required this.urgentCount,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (urgentCount > 0) parts.add('🔴 $urgentCount');
    if (warningCount > 0) parts.add('🟡 $warningCount');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: urgentCount > 0
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: urgentCount > 0
              ? const Color(0xFFC62828).withValues(alpha: 0.3)
              : const Color(0xFFF57F17).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        parts.join('  '),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: urgentCount > 0
              ? const Color(0xFFC62828)
              : const Color(0xFFF57F17),
        ),
      ),
    );
  }
}
