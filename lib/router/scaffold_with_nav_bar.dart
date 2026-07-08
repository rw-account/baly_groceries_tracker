// lib/router/scaffold_with_nav_bar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main shell that hosts a [StatefulNavigationShell] and displays a bottom
/// navigation bar using Material 3 [NavigationBar] with subtle haptic feedback
/// when switching tabs and a built-in animation on the selected indicator.
///
/// Because the shell uses [IndexedStack] internally to maintain each branch,
/// tab switching is immediate and never loses state (text input, scroll
/// position, nested navigation stacks, etc.).
class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    // إن كان التبويب المحدد هو نفسه الحالي، تُعاد للجذر (initialLocation)؛
    // وإن كان تبويبًا آخر، يُحافَظ على آخر مكان توقّف عنده المستخدم فيه.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: cs.primary.withValues(alpha: 0.12),
        shadowColor: Colors.transparent,
        elevation: 0,
        height: 65,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: cs.outline),
            selectedIcon: Icon(Icons.home_rounded, color: cs.primary),
            label: 'الرئيسية',
            tooltip: 'الشاشة الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined, color: cs.outline),
            selectedIcon: Icon(Icons.warning, color: cs.primary),
            label: 'النفاد',
            tooltip: 'العناصر القريبة من النفاد',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined, color: cs.outline),
            selectedIcon: Icon(Icons.shopping_cart_rounded, color: cs.primary),
            label: 'الشراء',
            tooltip: 'قائمة التسوق',
          ),
        ],
      ),
    );
  }
}
