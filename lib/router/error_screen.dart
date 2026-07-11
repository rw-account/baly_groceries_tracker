// lib/router/error_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/context_extensions.dart';

/// A friendly, unified error screen displayed for:
/// - Unknown routes (incorrect or expired links).
/// - A requested item that does not exist (e.g., it was deleted).
/// - Any other unexpected error during UI construction.
class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorScreen({
    super.key,
    this.title = 'حدث خطأ غير متوقع',
    this.message = 'لم نتمكن من إكمال الطلب، يرجى المحاولة مرة أخرى.',
    this.icon = Icons.error_outline_rounded,
    this.onRetry,
    this.retryLabel = 'العودة إلى الرئيسية',
  });

  /// حالة جاهزة: مسار غير معروف.
  factory ErrorScreen.unknownRoute(BuildContext context) => ErrorScreen(
        title: context.loc.errorUnknownRouteTitle,
        message: context.loc.errorUnknownRouteMessage,
        icon: Icons.signpost_outlined,
      );

  /// حالة جاهزة: العنصر المطلوب غير موجود.
  factory ErrorScreen.itemNotFound(BuildContext context) => ErrorScreen(
        title: context.loc.errorItemNotFoundTitle,
        message: context.loc.errorItemNotFoundMessage,
        icon: Icons.search_off_rounded,
      );

  /// حالة جاهزة: فشل جلب العنصر من المصدر (شبكة/قاعدة بيانات).
  factory ErrorScreen.itemLoadFailed(BuildContext context) => ErrorScreen(
        title: context.loc.errorItemLoadFailedTitle,
        message: context.loc.errorItemLoadFailedMessage,
        icon: Icons.cloud_off_rounded,
      );

  /// حالة جاهزة: خطأ غير متوقع أثناء بناء شاشة تحميل العنصر.
  factory ErrorScreen.itemLoadUnexpectedError(BuildContext context) => ErrorScreen(
        title: context.loc.errorItemLoadUnexpectedTitle,
        message: context.loc.errorItemLoadUnexpectedMessage,
        icon: Icons.error_outline_rounded,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 56,
                    color: cs.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.outline,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onRetry ?? () => context.go('/home'),
                    icon: const Icon(Icons.home_rounded),
                    label: Text(retryLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Replaces Flutter's default red "error of death" screen with a friendly,
/// localized error widget for the entire app.
///
/// Call this once in `main()` before `runApp()`.
void installGlobalErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const ErrorScreen(
      title: 'حدث خطأ غير متوقع',
      message: 'حدث خلل أثناء عرض هذه الشاشة. حاول العودة والمحاولة مرة أخرى.',
      icon: Icons.bug_report_outlined,
    );
  };
}
