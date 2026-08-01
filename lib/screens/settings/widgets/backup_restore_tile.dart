// lib/screens/settings/widgets/backup_restore_tile.dart

import 'package:flutter/material.dart';

class BackupRestoreTile extends StatelessWidget {
  const BackupRestoreTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isProcessing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isProcessing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          icon,
          color: colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: isProcessing
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
        onTap: onTap,
      ),
    );
  }
}
