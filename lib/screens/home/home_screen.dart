// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:restart_app/restart_app.dart';
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
      if (mounted) {
        checkAndShowBatteryDialog(context);
      }
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
          ? _buildSearchAppBar(context)
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
              return _buildEmptySearchState(context);
            }
            return ItemsList(
              items: searchResults,
              onItemTap: (item) {
                context.push(RoutePaths.editItemPath(item.id), extra: item).then((_) {
                  if (_isSearching) _toggleSearch();
                });
              },
            );
          }

          return Column(
            children: [
              SummaryBar(
                safeCount: items.length - summary.urgentCount - summary.warningCount,
                warningCount: summary.warningCount,
                urgentCount: summary.urgentCount,
              ),
              Expanded(
                child: ItemsList(
                  items: items,
                  onItemTap: (item) {
                    context.push(RoutePaths.editItemPath(item.id), extra: item).then((_) {
                      if (_isSearching) _toggleSearch();
                    });
                  },
                ),
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(context),
        error: (error, _) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: _buildFABs(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

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
    );
  }

  Widget _buildFABs() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right:5, left: 5),
            child: SizedBox(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                heroTag: 'add_fab',
              onPressed: () {
                context.push(RoutePaths.addItemFull).then((_) {
                  if (_isSearching) _toggleSearch();
                });
              },
                child:Icon(Icons.add_outlined),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 64,
            width: 64,
            child: FloatingActionButton(
              heroTag: 'search_fab',
              onPressed: _toggleSearch,
              child: Icon(_isSearching ? Icons.close_outlined : Icons.search_outlined, size: 32),
            ),
          ),
        ],
      ),
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: cs.error,
            ),
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

  void _showShareDialog(List<ItemModel> items) {
    showDialog(
      context: context,
      builder: (context) => ShareOptionsDialog(items: items),
    );
  }
}