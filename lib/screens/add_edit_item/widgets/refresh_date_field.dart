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
    final dateField = TextFormField(
      readOnly: true,
      controller: dateController,
      onTap: onPickDate,
      decoration: InputDecoration(
        labelText: context.loc.refreshDateLabel,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        hintText: context.loc.refreshDateHint,
        prefixIcon: Icon(Icons.event_available_outlined, color: Theme.of(context).colorScheme.primary),
        filled: true,
        border: appFieldBorder(context),
        enabledBorder: appFieldBorder(context),
      ),
    );

    if (!isEditing) return dateField;

    final resetButton = OutlinedButton.icon(
      onPressed: onResetToToday,
      icon: Icon(Icons.today_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(context.loc.resetToTodayButton),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
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