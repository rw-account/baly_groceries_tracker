// lib/screens/home/widgets/home_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
          onSelected: (value) async {
            switch (value) {
              case 'share':
                onSharePressed();
                break;
              case 'about':
                final packageInfo = await PackageInfo.fromPlatform();

                if (!context.mounted) return;

                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Row(
                        children: [
                          Image.asset(
                            'assets/icons/icon.png',
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  context.loc.appTitle,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  packageInfo.version,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.loc.aboutDialogDescription,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(
                                  'https://github.com/USERNAME/REPOSITORY');
                              try {
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          context.loc.githubLinkOpenFailed),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(context.loc.githubLinkOpenError),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text('GitHub'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(context.loc.closeLabel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            showLicensePage(
                              context: context,
                              applicationName: context.loc.appTitle,
                              applicationVersion: packageInfo.version,
                              applicationIcon: Image.asset(
                                'assets/icons/icon.png',
                                width: 40,
                                height: 40,
                              ),
                            );
                          },
                          child: Text(context.loc.showLicensesLabel),
                        ),
                      ],
                    );
                  },
                );
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
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Text(context.loc.aboutLabel),
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
