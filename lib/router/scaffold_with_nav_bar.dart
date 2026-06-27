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
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        animationDuration: const Duration(milliseconds: 400),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
            tooltip: 'الشاشة الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning),
            label: 'النفاد',
            tooltip: 'العناصر القريبة من النفاد',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart_rounded),
            label: 'الشراء',
            tooltip: 'قائمة التسوق',
          ),
        ],
      ),
    );
  }
}
