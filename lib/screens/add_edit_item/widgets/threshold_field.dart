// lib/screens/add_edit_item/widgets/threshold_field.dart

import 'package:flutter/material.dart';
import '../../../core/utils/field_utils.dart';

/// حقل رقمي مختصر لعتبات (آمن / تحذير / عاجل).
class ThresholdField extends StatelessWidget {
  const ThresholdField({
    super.key,
    required this.controller,
    required this.label,
    required this.color,
  });

  final TextEditingController controller;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onTap: () => moveCursorToEndOnTap(controller),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
      ],
    );
  }
}
