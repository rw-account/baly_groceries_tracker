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
      final storage = ref.read(storageServiceProvider);
      await BackupService.runRestore(storage); // الآن ترمي استثناء عند الفشل
      if (!mounted) return;

      // نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.restoreSuccess)),
      );
      // انتظر قليلاً حتى يقرأ المستخدم الرسالة، ثم أعد التشغيل
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

  /// يحول [BackupException] إلى رسالة مترجمة، بالاعتماد على enum
  /// بدلاً من البحث النصي الهش داخل رسالة الخطأ.
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
    final localeAsync = ref.watch(localeProvider);

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
      body: localeAsync.when(
        data: (locale) => _buildSettingsList(context, ref),
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error.toString()),
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
            context.loc.errorOccurredFormat(context.loc.loadingSettingsMessage),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
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
              context.loc
                  .errorOccurredFormat(context.loc.errorLoadingSettingsMessage),
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(localeProvider),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(context.loc.errorRetryLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
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
          locale: const Locale('ar'),
          label: context.loc.arabic,
          isSelected: ref.watch(localeProvider).value?.languageCode == 'ar',
          onTap: () => localeNotifier.changeLocale('ar'),
        ),
        const SizedBox(height: 8),
        _LanguageOption(
          locale: const Locale('en'),
          label: context.loc.english,
          isSelected: ref.watch(localeProvider).value?.languageCode == 'en',
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
    required this.locale,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Locale locale;
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