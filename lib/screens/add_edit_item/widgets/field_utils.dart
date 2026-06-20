// lib/screens/add_edit_item/widgets/field_utils.dart

import 'package:flutter/material.dart';

/// Builds a consistent outline border used across all input fields in this screen.
///
/// This ensures a unified visual style and avoids repeating border configuration
/// in multiple widgets. Any future design change can be applied from a single place.
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

/// Utility that moves the text cursor to the end of the input field
/// when it gains focus for the first time.
///
/// Common use cases:
/// - Pre-filled fields in edit screens
/// - Navigating between fields using keyboard actions (e.g., Tab)
///
/// This improves UX by placing the cursor at the end instead of the start,
/// without interfering with user interaction when the field is already focused.
class EndCursorOnFocus {
  EndCursorOnFocus({required this.controller, required this.focusNode}) {
    focusNode.addListener(_handleFocusChange);
  }

  final TextEditingController controller;
  final FocusNode focusNode;

  /// Handles focus changes and moves the cursor only when the field
  /// transitions into a focused state.
  void _handleFocusChange() {
    if (!focusNode.hasFocus) return;
    if (controller.text.isEmpty) return;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  /// Removes the focus listener to prevent memory leaks.
  ///
  /// Must be called from the owning widget's dispose() method.
  void dispose() {
    focusNode.removeListener(_handleFocusChange);
  }
}
