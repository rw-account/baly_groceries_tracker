import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home_orders_tracker/l10n/app_localizations.dart';
import 'package:home_orders_tracker/providers/locale_provider.dart';
import 'package:home_orders_tracker/router/route_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Language selection screen shown on first launch.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLanguage;
  bool _isLoading = false;

  Future<void> _selectLanguage(String languageCode) async {
    // منع اختيار نفس اللغة مرة أخرى أو أثناء التحميل
    if (_isLoading || _selectedLanguage == languageCode) return;

    setState(() {
      _selectedLanguage = languageCode;
      _isLoading = true;
    });

    // تحديث اللغة فوراً
    await ref.read(localeProvider.notifier).changeLocale(languageCode);

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToOnboarding() {
    context.go(RoutePaths.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    // مراقبة تغييرات اللغة لتحديث الواجهة واتجاه النص فوراً
    final locale = ref.watch(localeProvider);
    final isRTL = locale.languageCode == 'ar';


    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App icon/logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_basket_outlined,
                        size: 60,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      l10n.languageSelectionTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      l10n.languageSelectionSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Language options
                _buildLanguageOption(
                  context,
                  languageName: l10n.arabic,
                  isSelected: _selectedLanguage == 'ar',
                  onTap: () => _selectLanguage('ar'),
                ),
                const SizedBox(height: 16),
                _buildLanguageOption(
                  context,
                  languageName: l10n.english,
                  isSelected: _selectedLanguage == 'en',
                  onTap: () => _selectLanguage('en'),
                ),
                const SizedBox(height: 48), // لدفع الزر للأسفل إذا كان هناك مساحة

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: (_isLoading || _selectedLanguage == null) ? null : _navigateToOnboarding,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                l10n.onboardingNext,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languageName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}