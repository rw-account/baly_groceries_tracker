// lib/screens/add_edit_item/widgets/threshold_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'field_utils.dart';

/// حقل رقمي مختصر لعتبات (آمن / تحذير / عاجل).
class ThresholdField extends StatefulWidget {
  const ThresholdField({
    super.key,
    required this.controller,
    required this.label,
    required this.color,
    this.errorText,
    this.maxDigits = 4,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final Color color;
  final String? errorText;

  /// أقصى عدد أرقام مسموح (يمنع إدخال قيم غير منطقية مثل 99999 يوم).
  final int maxDigits;
  final void Function(String)? onChanged;

  @override
  State<ThresholdField> createState() => _ThresholdFieldState();
}

class _ThresholdFieldState extends State<ThresholdField> {
  final FocusNode _focusNode = FocusNode();
  EndCursorOnFocus? _cursorHelper;

  @override
  void initState() {
    super.initState();
    _cursorHelper = EndCursorOnFocus(
      controller: widget.controller,
      focusNode: _focusNode,
    );
  }

  @override
  void dispose() {
    _cursorHelper?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Semantics منفصل لأن الاعتماد على اللون فقط (آمن/تحذير/عاجل) لا
        // يكفي لمستخدمي قارئات الشاشة أو من يعانون من عمى الألوان.
        Semantics(
          label: '${widget.label} بالأيام',
          child: ExcludeSemantics(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                color: widget.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(widget.maxDigits),
          ],
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            suffixText: 'يوم',
            suffixStyle: const TextStyle(fontSize: 11),
            filled: true,
            errorText: widget.errorText,
            border: appFieldBorder(
              context,
              color: widget.color.withValues(alpha: 0.4),
              radius: 10,
            ),
            enabledBorder: appFieldBorder(
              context,
              color: widget.color.withValues(alpha: 0.3),
              radius: 10,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
      ],
    );
  }
}
