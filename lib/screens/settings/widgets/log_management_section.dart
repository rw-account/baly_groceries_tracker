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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.loc.logManagement,
          style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        
        Card(
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    context.loc.logRetentionDurationLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                RetentionRadioTile(
                  title: context.loc.logRetentionOff,
                  isSelected: isOff,
                  onTap: () => onOptionSelected(LogRetentionOption.off),
                ),
                if (isOff)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
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

                _optionDivider(colorScheme),
                
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onDeleteLogsNow,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: colorScheme.error,
                      ),
                      label: Text(
                        context.loc.deleteLogNow,
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: colorScheme.error.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _optionDivider(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outline.withValues(alpha: 0.15),
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
