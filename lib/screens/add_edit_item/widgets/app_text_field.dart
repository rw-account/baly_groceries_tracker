// lib/screens/add_edit_item/widgets/app_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'field_utils.dart';

/// Reusable text field used throughout the add/edit item screen.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.suffixStyle,
    this.errorText,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.labelStyle,
  });

  final TextEditingController controller;
  final String label;
  final TextStyle? labelStyle;
  final String? hint;
  final Icon icon;
  final TextInputType keyboardType;
  final String? suffix;
  final TextStyle? suffixStyle;
  final String? errorText;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;

  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? Function(String?)? validator;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownedFocusNode;
  EndCursorOnFocus? _cursorHelper;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

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
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: widget.labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        hintText: widget.hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIcon: widget.icon,
        suffixText: widget.suffix,
        suffixStyle: widget.suffixStyle,
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        errorText: widget.errorText,
        errorStyle: theme.textTheme.bodySmall?.copyWith(color: cs.error),
        border: appFieldBorder(context),
        enabledBorder: appFieldBorder(context),
        focusedBorder: appFieldBorder(context, color: cs.primary),
        errorBorder: appFieldBorder(context, color: cs.error),
        focusedErrorBorder: appFieldBorder(context, color: cs.error),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignLabelWithHint: widget.maxLines != null && widget.maxLines! > 1,
      ),
    );
  }
}
