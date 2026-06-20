// lib/providers/summary_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import 'items_provider.dart';

class SummaryData {
  final int urgentCount;
  final int warningCount;
  final int safeCount;
  final int totalCount;

  const SummaryData({
    required this.urgentCount,
    required this.warningCount,
    required this.safeCount,
    required this.totalCount,
  });
}

final summaryProvider = Provider<SummaryData>((ref) {
  final itemsAsync = ref.watch(itemsProvider);

  return itemsAsync.when(
    data: (items) {
      return SummaryData(
        urgentCount: items.where((i) => i.status == ItemStatus.urgent).length,
        warningCount: items.where((i) => i.status == ItemStatus.warning).length,
        safeCount: items.where((i) => i.status == ItemStatus.safe).length,
        totalCount: items.length,
      );
    },
    loading: () => const SummaryData(urgentCount: 0, warningCount: 0, safeCount: 0, totalCount: 0),
    error: (_, __) => const SummaryData(urgentCount: 0, warningCount: 0, safeCount: 0, totalCount: 0),
  );
});