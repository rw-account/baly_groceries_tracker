// lib/screens/settings/widgets/backup_restore_section.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';
import 'backup_restore_tile.dart';

class BackupRestoreSection extends StatelessWidget {
  const BackupRestoreSection({
    super.key,
    required this.isProcessing,
    required this.onBackup,
    required this.onRestore,
  });

  final bool isProcessing;
  final VoidCallback? onBackup;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.backupAndRestore,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        BackupRestoreTile(
          icon: Icons.backup_outlined,
          title: context.loc.createBackup,
          subtitle: context.loc.createBackupSubtitle,
          isProcessing: isProcessing,
          onTap: onBackup,
        ),
        const SizedBox(height: 8),
        BackupRestoreTile(
          icon: Icons.restore_outlined,
          title: context.loc.restoreBackup,
          subtitle: context.loc.restoreBackupSubtitle,
          isProcessing: isProcessing,
          onTap: onRestore,
        ),
      ],
    );
  }
}
