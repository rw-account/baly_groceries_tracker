// lib/screens/add_edit_item/widgets/refresh_date_field.dart

import 'package:flutter/material.dart';
import 'field_utils.dart';
import '../../../core/utils/context_extensions.dart';

class RefreshDateField extends StatelessWidget {
  const RefreshDateField({
    super.key,
    required this.dateController,
    required this.isEditing,
    required this.onPickDate,
    required this.onResetToToday,
  });

  final TextEditingController dateController;
  final bool isEditing;
  final VoidCallback onPickDate;
  final VoidCallback onResetToToday;

  static const double _narrowLayoutBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final dateField = TextFormField(
      readOnly: true,
      controller: dateController,
      onTap: onPickDate,
      decoration: InputDecoration(
        labelText: context.loc.refreshDateLabel,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintText: context.loc.refreshDateHint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(Icons.event_available_outlined),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: appFieldBorder(context),
        enabledBorder: appFieldBorder(context),
        focusedBorder: appFieldBorder(context, color: cs.primary),
        errorBorder: appFieldBorder(context, color: cs.error),
        focusedErrorBorder: appFieldBorder(context, color: cs.error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );

    if (!isEditing) return dateField;

    final resetButton = OutlinedButton.icon(
      onPressed: onResetToToday,
      icon: Icon(Icons.today_outlined, size: 18, color: cs.primary),
      label: Text(context.loc.resetToTodayButton),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: cs.primary, width: 1.5),
        foregroundColor: cs.primary,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _narrowLayoutBreakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [dateField, const SizedBox(height: 8), resetButton],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dateField),
            const SizedBox(width: 8),
            resetButton,
          ],
        );
      },
    );
  }
}