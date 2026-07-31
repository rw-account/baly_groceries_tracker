// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/utils/context_extensions.dart';
import '../../l10n/app_localizations.dart';
import '../../models/log_retention_option.dart';
import '../../providers/locale_provider.dart';
import '../../providers/storage_service_provider.dart';
import '../../services/backup_service.dart';
import '../../services/backup_exception.dart';

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
  }

  Future<void> _showCustomDaysDialog() async {
    final controller = TextEditingController(
      text: _customDaysValue?.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<int>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(context.loc.customRetentionDaysTitle),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.loc.customRetentionDaysContent),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: context.loc.customRetentionDaysLabel,
                      hintText: context.loc.customRetentionDaysHint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'الرجاء إدخال عدد الأيام';
                      }

                      final days = int.tryParse(text);
                      if (days == null) {
                        return 'الرجاء إدخال رقم صحيح';
                      }

                      if (days <= 0) {
                        return 'يجب أن يكون العدد أكبر من صفر';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(context.loc.cancelLabel),
              ),
              FilledButton(
                onPressed: () {
                  final isValid = formKey.currentState?.validate() ?? false;
                  if (!isValid) return;

                  final value = int.parse(controller.text.trim());
                  Navigator.pop(ctx, value);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(80, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(context.loc.saveLabel),
              ),
            ],
          );
        },
      );

      if (result != null && mounted) {
        setState(() {
          _customDaysValue = result;
        });
        await _saveRetentionOption(
          LogRetentionOption.custom,
          customDays: result,
        );
      }
    } finally {
      controller.dispose();
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
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.loc.language,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _LanguageOption(
          label: context.loc.arabic,
          isSelected: currentLocale.languageCode == 'ar',
          onTap: () => localeNotifier.changeLocale('ar'),
        ),
        const SizedBox(height: 8),
        _LanguageOption(
          label: context.loc.english,
          isSelected: currentLocale.languageCode == 'en',
          onTap: () => localeNotifier.changeLocale('en'),
        ),

        const SizedBox(height: 32),

        Text(
          context.loc.backupAndRestore,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        _BackupRestoreTile(
          icon: Icons.backup_outlined,
          title: context.loc.createBackup,
          subtitle: context.loc.createBackupSubtitle,
          isProcessing: _isProcessing,
          onTap: _isProcessing ? null : _handleBackup,
        ),
        const SizedBox(height: 8),
        _BackupRestoreTile(
          icon: Icons.restore_outlined,
          title: context.loc.restoreBackup,
          subtitle: context.loc.restoreBackupSubtitle,
          isProcessing: _isProcessing,
          onTap: _isProcessing ? null : _handleRestore,
        ),

        const SizedBox(height: 32),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.loc.logManagement,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _RetentionRadioTile(
                  title: context.loc.logRetentionOff,
                  isSelected: _logRetentionOption == LogRetentionOption.off,
                  onTap: () => _handleRetentionOptionChanged(LogRetentionOption.off),
                ),
                if (_logRetentionOption == LogRetentionOption.off) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.loc.logRetentionOffWarning,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _RetentionRadioTile(
                  title: context.loc.logRetentionThreeMonths,
                  isSelected: _logRetentionOption == LogRetentionOption.threeMonths,
                  onTap: () => _handleRetentionOptionChanged(LogRetentionOption.threeMonths),
                ),
                const SizedBox(height: 8),
                _RetentionRadioTile(
                  title: context.loc.logRetentionSixMonths,
                  isSelected: _logRetentionOption == LogRetentionOption.sixMonths,
                  onTap: () => _handleRetentionOptionChanged(LogRetentionOption.sixMonths),
                ),
                const SizedBox(height: 8),
                _RetentionRadioTile(
                  title: context.loc.logRetentionOneYear,
                  isSelected: _logRetentionOption == LogRetentionOption.oneYear,
                  onTap: () => _handleRetentionOptionChanged(LogRetentionOption.oneYear),
                ),
                const SizedBox(height: 8),
                _RetentionRadioTile(
                  title: _customDaysValue != null
                      ? context.loc.customRetentionFormat(_customDaysValue!)
                      : context.loc.logRetentionCustom,
                  isSelected: _logRetentionOption == LogRetentionOption.custom,
                  onTap: () async {
                    if (_logRetentionOption != LogRetentionOption.custom) {
                      await _handleRetentionOptionChanged(LogRetentionOption.custom);
                    }
                    if (mounted) {
                      await _showCustomDaysDialog();
                    }
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _handleDeleteLogsNow,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(context.loc.deleteLogNow),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RetentionRadioTile extends StatelessWidget {
  const _RetentionRadioTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked_outlined
              : Icons.radio_button_unchecked_outlined,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: isSelected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          isSelected
              ? Icons.radio_button_checked_outlined
              : Icons.radio_button_unchecked_outlined,
          color:
              isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

class _BackupRestoreTile extends StatelessWidget {
  const _BackupRestoreTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isProcessing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isProcessing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: isProcessing
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
        onTap: onTap,
      ),
    );
  }
}