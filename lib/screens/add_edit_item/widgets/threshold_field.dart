// lib/screens/add_edit_item/widgets/threshold_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'field_utils.dart';
import '../../../core/utils/context_extensions.dart';

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

  /// Maximum number of digits allowed (prevents entering unrealistic values such as 99999 days).
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
        Semantics(
          label: '${widget.label} ${context.loc.thresholdDaysSuffix}',
          child: ExcludeSemantics(
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.loc.fieldRequiredValidation;
            }
            final n = int.tryParse(value.trim());
            if (n == null || n < 0) {
              return context.loc.enterValidNumberValidation;
            }
            return null;
          },
          decoration: InputDecoration(
            suffixText: context.loc.thresholdFieldSuffix,
            suffixStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            filled: true,
            fillColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5),
            errorText: widget.errorText,
            errorStyle: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
            border: appFieldBorder(context, radius: 12),
            enabledBorder: appFieldBorder(
                context, color: widget.color.withValues(alpha: 0.3), radius: 12),
            focusedBorder: appFieldBorder(context, color: widget.color, radius: 12),
            errorBorder: appFieldBorder(
                context, color: Theme.of(context).colorScheme.error, radius: 12),
            focusedErrorBorder: appFieldBorder(
                context, color: Theme.of(context).colorScheme.error, radius: 12),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}