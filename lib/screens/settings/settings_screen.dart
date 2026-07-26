// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:restart_app/restart_app.dart';
import '../../core/utils/context_extensions.dart';
import '../../l10n/app_localizations.dart';
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
        // Language Section
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

        // Backup & Restore Section
        Text(
          context.loc.backupAndRestore,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),

        // Create Backup
        _BackupRestoreTile(
          icon: Icons.backup_outlined,
          title: context.loc.createBackup,
          subtitle: context.loc.createBackupSubtitle,
          isProcessing: _isProcessing,
          onTap: _isProcessing ? null : _handleBackup,
        ),

        const SizedBox(height: 8),

        // Restore Backup
        _BackupRestoreTile(
          icon: Icons.restore_outlined,
          title: context.loc.restoreBackup,
          subtitle: context.loc.restoreBackupSubtitle,
          isProcessing: _isProcessing,
          onTap: _isProcessing ? null : _handleRestore,
        ),
      ],
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