// lib/router/page_transitions.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// يبني صفحة بانتقال سلس يجمع بين التلاشي (fade) والانزلاق الخفيف (slide)،
/// لإعطاء شعورًا طبيعيًا عند فتح شاشة فرعية (مثل إضافة/تعديل عنصر)
/// دون أن يكون الانتقال مفاجئًا أو ثقيلًا.
CustomTransitionPage<T> buildSlideFadeTransitionPage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0.0),
        end: Offset.zero,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}
