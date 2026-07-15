// lib/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../router/route_paths.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int urgentCount;
  final int warningCount;
  final VoidCallback onSharePressed;

  const HomeAppBar({
    super.key,
    required this.urgentCount,
    required this.warningCount,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      title: Text(context.loc.appTitle),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_outlined),
          position: PopupMenuPosition.under,
          onSelected: (value) {
            switch (value) {
              case 'share':
                onSharePressed();
                break;
              case 'settings':
                context.push(RoutePaths.settings);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(context.loc.shareItemDetails),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(context.loc.settings),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}