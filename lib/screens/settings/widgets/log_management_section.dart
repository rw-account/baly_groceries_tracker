// lib/screens/settings/widgets/log_management_section.dart

import 'package:flutter/material.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../models/log_retention_option.dart';
import 'retention_radio_tile.dart';

class LogManagementSection extends StatelessWidget {
  const LogManagementSection({
    super.key,
    required this.selectedOption,
    required this.customDaysValue,
    required this.onOptionSelected,
    required this.onCustomOptionTap,
    required this.onDeleteLogsNow,
  });

  final LogRetentionOption selectedOption;
  final int? customDaysValue;
  final ValueChanged<LogRetentionOption> onOptionSelected;
  final VoidCallback onCustomOptionTap;
  final VoidCallback onDeleteLogsNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isOff = selectedOption == LogRetentionOption.off;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.history_toggle_off_rounded,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.loc.logManagement,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.loc.logRetentionSectionSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                context.loc.logRetentionDurationLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.15),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  RetentionRadioTile(
                    title: context.loc.logRetentionOff,
                    isSelected: isOff,
                    onTap: () => onOptionSelected(LogRetentionOption.off),
                  ),
                  if (isOff)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      child: _RetentionOffWarning(
                        message: context.loc.logRetentionOffWarning,
                      ),
                    ),
                  _optionDivider(colorScheme),
                  RetentionRadioTile(
                    title: context.loc.logRetentionThreeMonths,
                    isSelected: selectedOption == LogRetentionOption.threeMonths,
                    onTap: () => onOptionSelected(LogRetentionOption.threeMonths),
                  ),
                  _optionDivider(colorScheme),
                  RetentionRadioTile(
                    title: context.loc.logRetentionSixMonths,
                    isSelected: selectedOption == LogRetentionOption.sixMonths,
                    onTap: () => onOptionSelected(LogRetentionOption.sixMonths),
                  ),
                  _optionDivider(colorScheme),
                  RetentionRadioTile(
                    title: context.loc.logRetentionOneYear,
                    isSelected: selectedOption == LogRetentionOption.oneYear,
                    onTap: () => onOptionSelected(LogRetentionOption.oneYear),
                  ),
                  _optionDivider(colorScheme),
                  RetentionRadioTile(
                    title: customDaysValue != null
                        ? context.loc.customRetentionFormat(customDaysValue!)
                        : context.loc.logRetentionCustom,
                    isSelected: selectedOption == LogRetentionOption.custom,
                    onTap: onCustomOptionTap,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDeleteLogsNow,
                icon: const Icon(Icons.delete_outline),
                label: Text(context.loc.deleteLogNow),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.onErrorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1,
        color: colorScheme.outline.withValues(alpha: 0.12),
      ),
    );
  }
}

class _RetentionOffWarning extends StatelessWidget {
  const _RetentionOffWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
