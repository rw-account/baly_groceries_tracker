// lib/screens/add_edit_item/widgets/field_utils.dart

import 'package:flutter/material.dart';

InputBorder appFieldBorder(
  BuildContext context, {
  Color? color,
  double radius = 12,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(
      color: color ?? Theme.of(context).colorScheme.outlineVariant,
    ),
  );
}

class EndCursorOnFocus {
  EndCursorOnFocus({required this.controller, required this.focusNode}) {
    focusNode.addListener(_handleFocusChange);
  }

  final TextEditingController controller;
  final FocusNode focusNode;

  void _handleFocusChange() {
    if (!focusNode.hasFocus) return;
    if (controller.text.isEmpty) return;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  void dispose() {
    focusNode.removeListener(_handleFocusChange);
  }
}