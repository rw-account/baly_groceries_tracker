// lib/screens/shopping_list/add_shopping_item_screen/widgets/manual_entry_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/context_extensions.dart';

class ManualEntryForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final bool isDuplicate;
  final String? duplicateMessage;
  final String? priceError;
  final bool canSubmit;
  final bool isSubmitting;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPriceChanged;
  final VoidCallback onSubmit;

  const ManualEntryForm({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.isDuplicate,
    required this.canSubmit,
    required this.onNameChanged,
    required this.onPriceChanged,
    required this.onSubmit,
    this.duplicateMessage,
    this.priceError,
    this.isSubmitting = false,
  });

  @override
  State<ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<ManualEntryForm> {
  late final FocusNode _nameFocus;
  late final FocusNode _priceFocus;
  static const int _maxLength = 60;

  String _localizedDuplicateMessage(BuildContext context, String code) {
    switch (code) {
      case 'itemExistsInShoppingList':
        return context.loc.itemExistsInShoppingList;
      case 'itemTrackedInApp':
        return context.loc.itemTrackedInApp;
      default:
        return code;
    }
  }

  String? _localizedPriceError(BuildContext context, String? code) {
    if (code == null) return null;
    switch (code) {
      case 'invalidPriceFormatMessage':
        return context.loc.invalidPriceFormatMessage;
      case 'priceCannotBeNegative':
        return context.loc.priceCannotBeNegative;
      default:
        return code;
    }
  }

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _priceFocus = FocusNode();
    // Auto-focus when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final canSubmit =
        widget.canSubmit && !widget.isDuplicate && !widget.isSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          TextFormField(
            controller: widget.nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            maxLength: _maxLength,
            onChanged: widget.onNameChanged,
            onFieldSubmitted: (_) => _priceFocus.requestFocus(),
            style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
            cursorColor: cs.primary,
            decoration: _inputDeco(
              cs: cs,
              hint: context.loc.itemNameHint,
              label: context.loc.itemNameLabel,
              hasError: widget.isDuplicate,
            ),
          ),

          // Duplicate message
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: widget.isDuplicate
                ? Padding(
                    padding: const EdgeInsets.only(top: 8, right: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _localizedDuplicateMessage(context, widget.duplicateMessage ?? ''),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 20),

          // Price field
          TextFormField(
            controller: widget.priceController,
            focusNode: _priceFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              TextInputFormatter.withFunction((old, current) {
                return '.'.allMatches(current.text).length > 1 ? old : current;
              }),
            ],
            onChanged: widget.onPriceChanged,
            onFieldSubmitted: (_) {
              if (canSubmit) widget.onSubmit();
            },
            style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
            cursorColor: cs.primary,
            decoration: _inputDeco(
              cs: cs,
              hint: context.loc.priceHint,
              label: context.loc.priceLabel,
              hasError: widget.priceError != null,
              errorText: _localizedPriceError(context, widget.priceError),
            ),
          ),

          const SizedBox(height: 28),

          // Add button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: canSubmit ? widget.onSubmit : null,
              icon: widget.isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add_outlined, size: 22),
              label: Text(
                widget.isSubmitting ? context.loc.addingLabel : context.loc.addToListButton,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({
    required ColorScheme cs,
    required String hint,
    required String label,
    required bool hasError,
    String? errorText,
  }) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);
    final errorColor = hasError ? cs.error : null;
    final effectiveBorderColor = errorColor ?? cs.outlineVariant;

    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.outline),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: cs.outline),
      floatingLabelStyle: TextStyle(color: cs.primary),
      errorText: errorText,
      errorStyle: theme.textTheme.bodySmall?.copyWith(color: cs.error),
      filled: true,
      fillColor: hasError ? cs.error.withValues(alpha: 0.08) : cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      counterStyle: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: effectiveBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: errorColor ?? cs.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
    );
  }
}