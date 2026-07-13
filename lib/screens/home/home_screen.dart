// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/widgets.dart';
import '../../providers/items_provider.dart';
import '../../services/battery_service.dart';
import '../../providers/summary_provider.dart';
import 'package:go_router/go_router.dart';
import '../../router/route_paths.dart';
import '../../models/item_model.dart';
import '../../core/utils/context_extensions.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) checkAndShowBatteryDialog(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemsProvider);
    final summary = ref.watch(summaryProvider);

    return Scaffold(
      appBar: _isSearching
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _toggleSearch,
              ),
              title: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.loc.searchHint,
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            )
          : HomeAppBar(
              urgentCount: summary.urgentCount,
              warningCount: summary.warningCount,
              onSharePressed: () => _showShareDialog(itemsAsync.value ?? []),
            ),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState();
          }

          if (_isSearching) {
            if (_searchQuery.isEmpty) {
              return const SizedBox.shrink();
            }
            
            final searchResults = items
                .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

            if (searchResults.isEmpty) {
              return Center(child: Text(context.loc.noResultsFound));
            }
            return ItemsList(items: searchResults);
          }

          return Column(
            children: [
              SummaryBar(
                safeCount: items.length - summary.urgentCount - summary.warningCount,
                warningCount: summary.warningCount,
                urgentCount: summary.urgentCount,
              ),
              Expanded(child: ItemsList(items: items)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(context.loc.errorMessage(error.toString()))),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FloatingActionButton(
              heroTag: 'search_fab',
              onPressed: _toggleSearch,
              child: Icon(_isSearching ? Icons.close : Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: FloatingActionButton.extended(
              heroTag: 'add_fab',
              onPressed: () => context.push(RoutePaths.addItemFull),
              icon: const Icon(Icons.add),
              label: Text(context.loc.addButtonLabel),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(List<ItemModel> items) {
    showDialog(
      context: context,
      builder: (context) => ShareOptionsDialog(items: items),
    );
  }
}