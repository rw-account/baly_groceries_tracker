// lib/core/utils/field_utils.dart

import 'package:flutter/material.dart';

/// عند الضغط على حقل نصي يحتوي على قيمة، تُحرَّك علامة الإدراج (cursor)
/// إلى آخر النص بدل بدايته. مشتركة بين أكثر من حقل لتفادي تكرار الكود.
void moveCursorToEndOnTap(TextEditingController controller) {
  Future.delayed(const Duration(milliseconds: 50), () {
    if (controller.text.isNotEmpty) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  });
}
