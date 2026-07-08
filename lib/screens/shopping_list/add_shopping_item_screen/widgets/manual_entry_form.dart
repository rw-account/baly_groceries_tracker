// lib/screens/shopping_list/add_shopping_item_screen/widgets/manual_entry_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _priceFocus = FocusNode();
    // تركيز تلقائي عند فتح الشاشة
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nameFocus.requestFocus());
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
    final canSubmit =
        widget.canSubmit && !widget.isDuplicate && !widget.isSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── حقل الاسم ────────────────────────────────────────
          TextField(
            controller: widget.nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            maxLength: _maxLength,
            onChanged: widget.onNameChanged,
            onSubmitted: (_) => _priceFocus.requestFocus(),
            style: const TextStyle(color: Color(0xFFC7D5E0)),
            cursorColor: cs.primary,
            decoration: _inputDeco(
              cs: cs,
              hint: 'مثال: حليب، بيض، أرز…',
              label: 'اسم العنصر',
              hasError: widget.isDuplicate,
            ),
          ),

          // رسالة التكرار
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: widget.isDuplicate
                ? Padding(
                    padding: const EdgeInsets.only(top: 6, right: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 14, color: cs.error),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.duplicateMessage ?? '',
                            style: TextStyle(fontSize: 12, color: cs.error),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // ── حقل السعر ────────────────────────────────────────
          TextField(
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
            onSubmitted: (_) {
              if (canSubmit) widget.onSubmit();
            },
            style: const TextStyle(color: Color(0xFFC7D5E0)),
            cursorColor: cs.primary,
            decoration: _inputDeco(
              cs: cs,
              hint: '0.00',
              label: 'السعر (اختياري)',
              hasError: widget.priceError != null,
              errorText: widget.priceError,
            ),
          ),

          const SizedBox(height: 24),

          // ── زر الإضافة ───────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: canSubmit ? widget.onSubmit : null,
              icon: widget.isSubmitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 20),
              label: Text(
                widget.isSubmitting ? 'جارٍ الإضافة…' : 'إضافة للقائمة',
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
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: cs.outline),
      labelStyle: TextStyle(color: cs.outline),
      floatingLabelStyle: TextStyle(color: cs.primary),
      errorText: errorText,
      errorStyle: TextStyle(color: cs.error),
      filled: true,
      fillColor: hasError
          ? cs.error.withValues(alpha: 0.08)
          : cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      counterStyle: TextStyle(color: cs.outline, fontSize: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: hasError ? cs.error : cs.outlineVariant,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(
          color: hasError ? cs.error : cs.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
    );
  }
}
