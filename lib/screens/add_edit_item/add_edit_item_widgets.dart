// lib/screens/add_edit_item/add_edit_item_widgets.dart

import 'package:flutter/material.dart';

/// Section header with icon + bold label
Widget buildSectionTitle(
  BuildContext context,
  String title,
  IconData icon,
) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 8),
      Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

/// Standard text form field used throughout the screen
Widget buildTextField({
  required BuildContext context,
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  TextInputType keyboardType = TextInputType.text,
  String? suffix,
  String? errorText,
  int? minLines,
  int? maxLines = 1,
  void Function(String)? onChanged,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    minLines: minLines,
    maxLines: maxLines,
    validator: validator,
    onChanged: onChanged,
    onTap: () {
      Future.delayed(const Duration(milliseconds: 50), () {
        if (controller.text.isNotEmpty) {
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      });
    },
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixText: suffix,
      filled: true,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
  );
}

/// Compact numeric field for safe / warning / urgent thresholds
Widget buildThresholdField({
  required TextEditingController controller,
  required String label,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onTap: () {
          Future.delayed(const Duration(milliseconds: 50), () {
            if (controller.text.isNotEmpty) {
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }
          });
        },
        decoration: InputDecoration(
          suffixText: 'يوم',
          suffixStyle: const TextStyle(fontSize: 11),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
      ),
    ],
  );
}

/// Date field + optional "reset to today" button (edit mode only)
Widget buildRefreshDateField({
  required BuildContext context,
  required TextEditingController dateCtrl,
  required bool isEditing,
  required VoidCallback onPickDate,
  required VoidCallback onResetToToday,
}) {
  final dateField = TextFormField(
    readOnly: true,
    controller: dateCtrl,
    onTap: isEditing ? onPickDate : null,
    decoration: InputDecoration(
      labelText: 'تاريخ التجديد',
      hintText: 'YYYY-MM-DD',
      prefixIcon: const Icon(Icons.event_available_outlined),
      suffixIcon: IconButton(
        onPressed: isEditing ? onPickDate : null,
        tooltip: 'اختيار تاريخ التجديد',
        icon: const Icon(Icons.calendar_month_outlined),
      ),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    ),
  );

  final resetButton = FilledButton.tonalIcon(
    onPressed: isEditing ? onResetToToday : null,
    icon: const Icon(Icons.today_outlined, size: 18),
    label: const Text('إعادة تعيين إلى تاريخ اليوم'),
    style: FilledButton.styleFrom(
      minimumSize: const Size(0, 56),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  if (!isEditing) return dateField;

  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
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
