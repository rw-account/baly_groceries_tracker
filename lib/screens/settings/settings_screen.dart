// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:baly_groceries_tracker/providers/item_history_provider.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/utils/context_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_retention_option.dart';
import '../../providers/locale_provider.dart';
import '../../providers/storage_service_provider.dart';
import '../../services/backup_service.dart';
import '../../services/backup_exception.dart';
import 'widgets/widgets.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isProcessing = false;
  LogRetentionOption _logRetentionOption = LogRetentionOption.sixMonths;
  int? _customDaysValue;

  @override
  void initState() {
    super.initState();
    _loadRetentionSettings();
  }

  Future<void> _loadRetentionSettings() async {
    final storage = ref.read(storageServiceProvider);
    final savedOption = await storage.getLogRetentionOption();
    final savedCustomDays = await storage.getLogRetentionCustomDays();

    if (!mounted) return;

    setState(() {
      _logRetentionOption = savedOption;
      _customDaysValue = savedCustomDays;
    });
  }

  Future<void> _handleBackup() async {
    setState(() => _isProcessing = true);
    try {
      final storage = ref.read(storageServiceProvider);
      await BackupService.runBackup(storage);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.backupSuccess)),
      );
    } on BackupException catch (e) {
      if (!mounted) return;
      final message = _getErrorMessage(e, context.loc);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isProcessing = true);
    try {
      final confirmed = await _confirmRestore();
      if (!confirmed) return;
      final storage = ref.read(storageServiceProvider);
      await BackupService.runRestore(storage);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.restoreSuccess)),
      );
      // Wait a moment so the user can read the message, then restart.
      Future.delayed(const Duration(milliseconds: 1500), () {
        Restart.restartApp();
      });
    } on BackupException catch (e) {
      if (!mounted) return;
      final message = _getErrorMessage(e, context.loc);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool> _confirmRestore() async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.restoreConfirmationTitle),
        content: Text(context.loc.restoreConfirmationContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.restoreConfirmLabel),
          ),
        ],
      ),
    ) ?? false;
  }

  String _getErrorMessage(BackupException error, AppLocalizations loc) {
    switch (error.type) {
      case BackupErrorType.backupFileNotFound:
        return loc.backupFileNotFound;
      case BackupErrorType.backupCancelled:
        return loc.operationCancelled;
      case BackupErrorType.backupSaveError:
        return loc.backupFailed;
      case BackupErrorType.restoreCancelled:
        return loc.operationCancelled;
      case BackupErrorType.restoreFileNotFound:
        return loc.restoreFileNotFound;
      case BackupErrorType.restoreInvalidFile:
        return loc.restoreInvalidFile;
      case BackupErrorType.restoreFailed:
        return loc.restoreFailed;
      case BackupErrorType.unknown:
        return loc.unknownError;
    }
  }

  Future<void> _saveRetentionOption(
    LogRetentionOption option, {
    int? customDays,
  }) async {
    final storage = ref.read(storageServiceProvider);
    await storage.setLogRetentionOption(option, customDays: customDays);
  }

  DateTime? _calculateCutoffForCurrentSelection() {
    return calculateLogRetentionCutoffDate(
      option: _logRetentionOption,
      customDays: _customDaysValue,
      referenceDate: DateTime.now(),
    );
  }

  Future<void> _handleRetentionOptionChanged(LogRetentionOption option) async {
    final customDays = option == LogRetentionOption.custom ? _customDaysValue : null;

    setState(() {
      _logRetentionOption = option;
    });

    await _saveRetentionOption(option, customDays: customDays);

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.loc.retentionPolicyUpdated),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showCustomDaysDialog() async {
    final result = await CustomDaysDialog.show(
      context,
      initialValue: _customDaysValue,
    );

    if (result != null && mounted) {
      setState(() {
        _customDaysValue = result;
        _logRetentionOption = LogRetentionOption.custom;
      });
      await _saveRetentionOption(
        LogRetentionOption.custom,
        customDays: result,
      );

      if (!mounted) return;
    
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.loc.retentionPolicyUpdated),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleDeleteLogsNow() async {
    final confirmed = await _confirmDeleteLogsNow();
    if (!confirmed || !mounted) return;

    final storage = ref.read(storageServiceProvider);
    final cutoff = _calculateCutoffForCurrentSelection();

    if (cutoff == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.autoDeletionOffNoLogsRemoved)),
      );
      return;
    }

    final deletedCount = await storage.deleteLogsOlderThan(cutoff);

    if (deletedCount > 0) {
      ref.invalidate(itemHistoryProvider);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deletedCount > 0
              ? context.loc.logDeletedCount(deletedCount)
              : context.loc.noLogsMatchedRetention,
        ),
      ),
    );
  }

  Future<bool> _confirmDeleteLogsNow() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.deleteLogNowConfirmTitle),
        content: Text(context.loc.deleteLogNowConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(context.loc.deleteButtonLabel),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settings),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildSettingsList(context, ref, locale),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, Locale currentLocale) {
    final localeNotifier = ref.read(localeProvider.notifier);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
      children: [
        LanguageSection(
          currentLanguageCode: currentLocale.languageCode,
          onLanguageSelected: localeNotifier.changeLocale,
        ),
        const SizedBox(height: 32),
        BackupRestoreSection(
          isProcessing: _isProcessing,
          onBackup: _isProcessing ? null : _handleBackup,
          onRestore: _isProcessing ? null : _handleRestore,
        ),
        const SizedBox(height: 32),
        LogManagementSection(
          selectedOption: _logRetentionOption,
          customDaysValue: _customDaysValue,
          onOptionSelected: _handleRetentionOptionChanged,
          onCustomOptionTap: _showCustomDaysDialog,
          onDeleteLogsNow: _handleDeleteLogsNow,
        ),
      ],
    );
  }
}
