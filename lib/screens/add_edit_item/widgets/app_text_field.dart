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
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.suffix,
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
  final String hint;
  final Icon icon;
  final TextInputType keyboardType;
  final String? suffix;
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
  final TextStyle? labelStyle;

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
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icon,
        suffixText: widget.suffix,
        filled: true,
        errorText: widget.errorText,
        labelStyle: widget.labelStyle,
        border: appFieldBorder(context),
        enabledBorder: appFieldBorder(context),
      ),
    );
  }
}
