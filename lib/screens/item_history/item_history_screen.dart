// lib/screens/item_history/item_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_orders_tracker/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:home_orders_tracker/core/utils/context_extensions.dart';
import 'package:home_orders_tracker/models/item_change_log_model.dart';
import 'package:home_orders_tracker/models/item_model.dart';
import 'package:home_orders_tracker/providers/item_history_provider.dart';
import 'package:home_orders_tracker/providers/items_provider.dart';
import 'package:home_orders_tracker/router/route_paths.dart';

String _formatFullDateTime(DateTime date) {
  return DateFormat('yyyy/MM/dd - hh:mm:ss a', 'en').format(date);
}

class ItemHistoryScreen extends ConsumerWidget {
  final String itemId;

  const ItemHistoryScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final historyAsync = ref.watch(itemHistoryProvider(itemId));

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.changeHistoryTitle),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: historyAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_toggle_off_outlined,
                      size: 64,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.loc.changeHistoryEmpty,
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isLatest = (index == 0);

              return _LogItemCard(
                log: log,
                isLatest: isLatest,
                onRevert: () => _confirmAndRevert(context, ref, log),
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: cs.primary),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              context.loc.errorMessage(error.toString()),
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.error),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndRevert(
    BuildContext context,
    WidgetRef ref,
    ItemChangeLogModel log,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(context.loc.revertConfirmTitle),
        content: Text(context.loc.revertConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.revertButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(context.loc.loading),
              ],
            ),
          ),
        );
      },
    );

    try {
      final formattedDate = _formatFullDateTime(log.timestampDateTime);
      final dateStr = '\u200E$formattedDate';
      final revertDescription = context.loc.revertDescription(dateStr);

      final restoredItem = await ref
          .read(itemsProvider.notifier)
          .revertItemToVersion(
            itemId: itemId,
            logEntry: log,
            description: revertDescription,
          );

      if (!context.mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (restoredItem != null) {
        _showSuccessSnackBar(context, context.loc.revertSuccess);
        context.go(RoutePaths.editItemPath(itemId));
      } else {
        _showErrorSnackBar(context, context.loc.revertFailed);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorSnackBar(context, context.loc.revertFailed);
      }
    }
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: theme.colorScheme.onError),
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

class _LogItemCard extends StatelessWidget {
  final ItemChangeLogModel log;
  final bool isLatest;
  final VoidCallback onRevert;

  const _LogItemCard({
    required this.log,
    required this.isLatest,
    required this.onRevert,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final formattedDate = '\u200E${_formatFullDateTime(log.timestampDateTime)}';

    final oldState = log.parsedPreviousState;
    final newState = log.parsedNewState;
    final diffSentences =
        _buildDiffSentences(context, oldState, newState, log.actionType);

    final tagInfo = _getTagInfo(context, log.actionType);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color:
              isLatest ? cs.primary.withValues(alpha: 0.5) : cs.outlineVariant,
          width: isLatest ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Action Tag & Local Timestamp
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagInfo.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tagInfo.icon,
                          size: 14, color: tagInfo.foregroundColor),
                      const SizedBox(width: 4),
                      Text(
                        tagInfo.label,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: tagInfo.foregroundColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          formattedDate,
                          textAlign: TextAlign.end,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (log.description != null &&
                log.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                log.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.primary,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Diff Sentences
            ...diffSentences.map(
              (sentence) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        sentence,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Revert button (only shown for non-latest entries with valid state)
            if (!isLatest && (newState != null || oldState != null)) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: OutlinedButton.icon(
                  onPressed: onRevert,
                  icon: const Icon(Icons.history_outlined, size: 18),
                  label: Text(context.loc.revertButton),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.primary,
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNullableFullDateTime(DateTime? date) {
    if (date == null) return '-';
    return '\u200E${_formatFullDateTime(date)}';
  }

  /// Checks if two nullable DateTimes represent the exact same moment.
  bool _isSameMoment(DateTime? d1, DateTime? d2) {
    if (d1 == null && d2 == null) return true;
    if (d1 == null || d2 == null) return false;

    return d1.isAtSameMomentAs(d2);
  }

  /// Analyzes state changes between item versions and converts them into
  /// localized, human-readable summary sentences for display.
  List<String> _buildDiffSentences(
    BuildContext context,
    ItemModel? oldItem,
    ItemModel? newItem,
    String actionType,
  ) {
    final loc = context.loc;
    final List<String> diffs = [];

    if (actionType == ItemActionType.create || oldItem == null) {
      if (newItem != null) {
        diffs.add(loc.diffItemCreated);
        diffs.add('${loc.itemNameFieldLabel}: ${newItem.name}');
        if (newItem.quantityDescription.isNotEmpty) {
          diffs.add(
              '${loc.quantityDescriptionLabel}: ${newItem.quantityDescription}');
        }
        diffs.add(
            '${loc.expectedDaysLabel}: ${newItem.expectedDays} ${loc.daysSuffix}');
      }
      return diffs;
    }

    if (actionType == ItemActionType.delete || newItem == null) {
      diffs.add(loc.diffItemDeleted);
      return diffs;
    }

    // Property comparisons
    if (oldItem.name != newItem.name) {
      diffs.add(loc.diffNameChanged(oldItem.name, newItem.name));
    }

    if (oldItem.quantityDescription != newItem.quantityDescription) {
      diffs.add(loc.diffQtyDescChanged(
        oldItem.quantityDescription.isEmpty ? '-' : oldItem.quantityDescription,
        newItem.quantityDescription.isEmpty ? '-' : newItem.quantityDescription,
      ));
    }

    if (oldItem.expectedDays != newItem.expectedDays) {
      diffs.add(loc.diffExpectedDaysChanged(
        oldItem.expectedDays.toString(),
        newItem.expectedDays.toString(),
      ));
    }

    if (oldItem.warningThresholdDays != newItem.warningThresholdDays) {
      diffs.add(loc.diffWarningDaysChanged(
        oldItem.warningThresholdDays.toString(),
        newItem.warningThresholdDays.toString(),
      ));
    }

    if (oldItem.urgentThresholdDays != newItem.urgentThresholdDays) {
      diffs.add(loc.diffUrgentDaysChanged(
        oldItem.urgentThresholdDays.toString(),
        newItem.urgentThresholdDays.toString(),
      ));
    }

    if (oldItem.notificationsEnabled != newItem.notificationsEnabled) {
      diffs.add(loc.diffNotificationsChanged(
        oldItem.notificationsEnabled ? loc.enabledText : loc.disabledText,
        newItem.notificationsEnabled ? loc.enabledText : loc.disabledText,
      ));
    }

    if (oldItem.notes != newItem.notes) {
      diffs.add(loc.diffNotesChanged);
    }

    if (!_isSameMoment(oldItem.lastRefreshedAt, newItem.lastRefreshedAt)) {
      diffs.add(loc.diffRefreshedAtChangedFromTo(
        _formatNullableFullDateTime(oldItem.lastRefreshedAt),
        _formatNullableFullDateTime(newItem.lastRefreshedAt),
      ));
    }

    if (diffs.isEmpty) {
      diffs.add(loc.diffNoChanges);
    }

    return diffs;
  }

  /// Returns the tag styling and metadata (color, label, and icon)
  /// associated with a specific [ItemActionType] for the log card header.
  _TagInfo _getTagInfo(BuildContext context, String actionType) {
    final cs = Theme.of(context).colorScheme;
    final customColors = Theme.of(context).extension<CustomColors>();
    final safeColor = customColors?.safe ?? const Color(0xFF34D399);
    final loc = context.loc;

    switch (actionType) {
      case ItemActionType.create:
        return _TagInfo(
          label: loc.actionCreate,
          backgroundColor: safeColor.withValues(alpha: 0.15),
          foregroundColor: safeColor,
          icon: Icons.add_circle_outline,
        );
      case ItemActionType.restock:
        const restockColor = Color(0xFF2DD4BF);
        return _TagInfo(
          label: loc.actionRestock,
          backgroundColor: restockColor.withValues(alpha: 0.15),
          foregroundColor: restockColor,
          icon: Icons.add_shopping_cart_outlined,
        );
      case ItemActionType.update:
        return _TagInfo(
          label: loc.actionUpdate,
          backgroundColor: cs.primaryContainer,
          foregroundColor: cs.onPrimaryContainer,
          icon: Icons.edit_outlined,
        );
      case ItemActionType.stockCorrection:
        return _TagInfo(
          label: loc.actionStockCorrection,
          backgroundColor: cs.tertiary.withValues(alpha: 0.15),
          foregroundColor: cs.tertiary,
          icon: Icons.sync_problem_outlined,
        );
      case ItemActionType.delete:
        return _TagInfo(
          label: loc.actionDelete,
          backgroundColor: cs.error.withValues(alpha: 0.15),
          foregroundColor: cs.error,
          icon: Icons.delete_outline,
        );
      default:
        return _TagInfo(
          label: actionType,
          backgroundColor: cs.surfaceContainerHighest,
          foregroundColor: cs.onSurface,
          icon: Icons.info_outline,
        );
    }
  }
}

class _TagInfo {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  _TagInfo({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });
}
