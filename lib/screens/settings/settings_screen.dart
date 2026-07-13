// lib/screens/settings/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/context_extensions.dart';
import '../../providers/locale_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: localeAsync.when(
        data: (locale) => _buildSettingsList(context, ref, locale),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
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
          locale: const Locale('ar'),
          label: context.loc.arabic,
          isSelected: currentLocale.languageCode == 'ar',
          onTap: () => localeNotifier.changeLocale('ar'),
        ),
        const SizedBox(height: 8),
        _LanguageOption(
          locale: const Locale('en'),
          label: context.loc.english,
          isSelected: currentLocale.languageCode == 'en',
          onTap: () => localeNotifier.changeLocale('en'),
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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