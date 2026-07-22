// lib/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_orders_tracker/providers/app_state_provider.dart';
import 'package:home_orders_tracker/router/route_paths.dart';
import 'package:home_orders_tracker/core/theme/app_theme.dart';
import 'package:home_orders_tracker/l10n/app_localizations.dart';
import 'package:introduction_screen/introduction_screen.dart';

/// Builds a luxurious, glowing icon container
Widget _buildLuxuryIcon(BuildContext context, IconData icon) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return Container(
    width: 140,
    height: 140,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colorScheme.surfaceContainerHighest,
          colorScheme.surface,
        ],
      ),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.25),
          blurRadius: 30,
          spreadRadius: 4,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(
      icon,
      size: 48.0,
      color: colorScheme.primary,
    ),
  );
}

/// Builds the shared [PageDecoration]
PageDecoration _buildPageDecoration(BuildContext context) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return PageDecoration(
    pageColor: colorScheme.surface,
    titleTextStyle: textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    ),
    bodyTextStyle: textTheme.bodyLarge!.copyWith(
      height: 1.5,
      color: AppTheme.textSecondary,
    ),
    imagePadding: const EdgeInsets.only(bottom: 60.0),
    contentMargin: const EdgeInsets.symmetric(horizontal: 30.0),
    bodyAlignment: Alignment.topCenter,
  );
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  List<PageViewModel> _buildPages(BuildContext context, AppLocalizations l10n) {
    return [
      PageViewModel(
        title: l10n.onboardingTitle1,
        body: l10n.onboardingBody1,
        image: _buildLuxuryIcon(context, Icons.lightbulb_outline_rounded),
        decoration: _buildPageDecoration(context),
      ),
      PageViewModel(
        title: l10n.onboardingTitle2,
        body: l10n.onboardingBody2,
        image: _buildLuxuryIcon(context, Icons.notifications_none_rounded),
        decoration: _buildPageDecoration(context),
      ),
      PageViewModel(
        title: l10n.onboardingTitle3,
        body: l10n.onboardingBody3,
        image: _buildLuxuryIcon(context, Icons.shopping_bag_outlined),
        decoration: _buildPageDecoration(context),
      ),
      PageViewModel(
        title: l10n.onboardingTitle4,
        body: l10n.onboardingBody4,
        image: _buildLuxuryIcon(context, Icons.shield_outlined),
        decoration: _buildPageDecoration(context),
      ),
    ];
  }

  Future<void> _completeOnboarding() async {
    await ref.read(appStateNotifierProvider).completeOnboarding();
    if (mounted) {
      context.go(RoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isRTL = l10n.localeName == 'ar';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // ✅ تم التعديل هنا: جعل خلفية الـ Scaffold متطابقة مع colorScheme.surface
    final Color backgroundColor = colorScheme.surface;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBody: true,
        extendBodyBehindAppBar: true,
        // ✅ تم التعديل هنا: إضافة bottom: false لجعل لون الخلفية يمتد لآخر الشاشة من الأسفل تماماً بدون قطع بVisual
        body: SafeArea(
          bottom: false,
          child: IntroductionScreen(
            key: _introKey,
            globalBackgroundColor: backgroundColor,
            pages: _buildPages(context, l10n),
            dotsContainerDecorator: BoxDecoration(
              color: colorScheme.surface,
            ),
            showSkipButton: true,
            showBackButton: false,

            // 1. زر التخطي (Skip)
            skip: Text(
              l10n.onboardingSkip,
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),

            // 2. زر التالي (Next)
            next: Text(
              l10n.onboardingNext,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            // 3. زر البدء/الإنهاء الفاخر (Done)
            done: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                l10n.onboardingDone,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            // 4. تصفير الحواشي الداخلية ومنع الوميض المربع عند الضغط
            skipStyle: TextButton.styleFrom(padding: EdgeInsets.zero, overlayColor: Colors.transparent,),
            nextStyle: TextButton.styleFrom(padding: EdgeInsets.zero, overlayColor: Colors.transparent,),
            doneStyle: TextButton.styleFrom(padding: EdgeInsets.zero, overlayColor: Colors.transparent,),

            onDone: _completeOnboarding,
            onSkip: _completeOnboarding,

            dotsDecorator: DotsDecorator(
              activeColor: colorScheme.primary,
              color: AppTheme.textSecondary.withValues(alpha: 0.3),
              size: const Size.square(8.0),
              activeSize: const Size(24.0, 8.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),

            // 5. ضبط الهوامش السفلية المخصصة لعناصر التحكم لتعطي مساحة تنفس مريحة للأزرار والنقاط
            controlsPadding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 12.0,
            ),
            controlsMargin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          ),
        ),
      ),
    );
  }
}
