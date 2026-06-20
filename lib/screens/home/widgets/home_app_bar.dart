// lib/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'summary_badge.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int urgentCount;
  final int warningCount;

  const HomeAppBar({
    super.key,
    required this.urgentCount,
    required this.warningCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('متابعة طلبات البيت'),
      centerTitle: false,
      actions: [
          if (urgentCount > 0 || warningCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: SummaryBadge(
                urgentCount: urgentCount,
                warningCount: warningCount,
              ),
            ),
            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}