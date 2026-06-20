// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/widgets.dart';
import '../../providers/items_provider.dart';
import '../add_edit_item/add_edit_item_screen.dart';
import '../../services/battery_service.dart';
import '../../providers/summary_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Wait until the first frame is built so the context is safe to use for dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BatteryService.requestBatteryOptimizationExemption(context);
    });
  }

  // ─── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final summary = ref.watch(summaryProvider);
    final urgentCount = summary.urgentCount;
    final warningCount = summary.warningCount;

    return Scaffold(

      appBar: HomeAppBar(urgentCount: urgentCount, warningCount: warningCount),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState();
          }
          return ItemsList(items: items);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطأ: $error')),
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