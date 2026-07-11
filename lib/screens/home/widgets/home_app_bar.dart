// lib/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';

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
    return AppBar(
      title: Text(context.loc.appTitle),
      centerTitle: false,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          position: PopupMenuPosition.under,
          onSelected: (value) {
            if (value == 'share') {
              onSharePressed();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(context.loc.shareItemDetails),
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