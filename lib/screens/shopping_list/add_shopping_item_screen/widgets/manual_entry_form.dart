// lib/screens/shopping_list/add_shopping_item_screen/widgets/manual_entry_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ManualEntryForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final bool isDuplicate;
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
            decoration: _inputDeco(
              cs: cs,
              hint: 'مثال: حليب، خبز، أرز…',
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
                        Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
                        const SizedBox(width: 6),
                        Text(
                          'يوجد عنصر بنفس الاسم في القائمة',
                          style: TextStyle(fontSize: 12, color: cs.error),
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
              if (widget.canSubmit && !widget.isSubmitting) widget.onSubmit();
            },
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
          FilledButton.icon(
            onPressed: (widget.canSubmit && !widget.isSubmitting) ? widget.onSubmit : null,
            icon: widget.isSubmitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: cs.onPrimary),
                  )
                : const Icon(Icons.add_rounded, size: 20),
            label: Text(widget.isSubmitting ? 'جارٍ الإضافة…' : 'إضافة للقائمة'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
      errorText: errorText,
      filled: true,
      fillColor: hasError
          ? cs.errorContainer.withValues(alpha: 0.12)
          : cs.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? cs.error : cs.outlineVariant,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? cs.error : cs.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
    );
  }
}