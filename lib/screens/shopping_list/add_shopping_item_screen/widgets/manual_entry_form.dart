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
  int _nameLength = 0;
  static const int _maxLength = 60;

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _priceFocus = FocusNode();
    _nameLength = widget.nameController.text.length; 
    // تركيز تلقائي عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocus.requestFocus();
    });
    widget.nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) {
      setState(() => _nameLength = widget.nameController.text.length);
    }
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_onNameChanged);
    _nameFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── مؤشر الخطوة ──────────────────────────────────────
          _StepChips(
            nameFocused: _nameFocus.hasFocus,
            priceFocused: _priceFocus.hasFocus,
            nameHasValue: widget.nameController.text.isNotEmpty,
          ),
          const SizedBox(height: 20),

          // ── حقل الاسم ────────────────────────────────────────
          _FieldLabel(label: 'اسم العنصر'),
          const SizedBox(height: 6),
          TextField(
            controller: widget.nameController,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            maxLength: _maxLength,
            onChanged: widget.onNameChanged,
            onSubmitted: (_) => _priceFocus.requestFocus(),
            decoration: _inputDeco(
              theme: theme,
              hint: 'مثال: حليب، خبز، أرز…',
              hasError: widget.isDuplicate,
              isFocused: _nameFocus.hasFocus,
            ),
          ),

          // عداد الحروف
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                '$_nameLength / $_maxLength',
                style: TextStyle(
                  fontSize: 11,
                  color: _nameLength > 50 ? cs.error : cs.outline,
                ),
              ),
            ),
          ),

          // رسالة التكرار
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: widget.isDuplicate
                ? Padding(
                    padding: const EdgeInsets.only(top: 6, right: 2),
                    child: _InlineMessage(
                      icon: Icons.warning_amber_rounded,
                      text: 'يوجد عنصر بنفس الاسم في قائمة الشراء',
                      color: cs.error,
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 18),

          // ── حقل السعر ────────────────────────────────────────
          _FieldLabel(
            label: 'السعر',
            suffix: Text(' (اختياري)',
                style: TextStyle(fontSize: 12, color: cs.outline)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.priceController,
            focusNode: _priceFocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                if ('.'.allMatches(newValue.text).length > 1) {
                  return oldValue;
                }
                return newValue;
              }),
            ],
            onChanged: widget.onPriceChanged,
            onSubmitted: (_) {
              if (widget.canSubmit && !widget.isSubmitting) widget.onSubmit();
            },
            decoration: _inputDeco(
              theme: theme,
              hint: '0.00',
              hasError: widget.priceError != null,
              isFocused: _priceFocus.hasFocus,
            ).copyWith(
              errorText: widget.priceError,
            ),
          ),

          const SizedBox(height: 28),

          // ── زر الإضافة ───────────────────────────────────────
          FilledButton.icon(
            onPressed: (widget.canSubmit && !widget.isSubmitting)
                ? widget.onSubmit
                : null,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: widget.isSubmitting
                  ? SizedBox(
                      key: const ValueKey('spin'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add_rounded,
                      key: ValueKey('icon'), size: 20),
            ),
            label: Text(widget.isSubmitting ? 'جارٍ الإضافة…' : 'إضافة للقائمة'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco({
    required ThemeData theme,
    required String hint,
    required bool hasError,
    required bool isFocused,
    String? suffixText,
  }) {
    final cs = theme.colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.outline),
      suffixText: suffixText,
      filled: true,
      fillColor: hasError
          ? cs.errorContainer.withValues(alpha: 0.12)
          : cs.surfaceContainerHighest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

// ── ويدجت مساعدة: تسمية الحقل ──────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget? suffix;
  const _FieldLabel({required this.label, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w600)),
        if (suffix != null) suffix!,
      ],
    );
  }
}

// ── ويدجت مساعدة: رسالة خطأ/تحذير داخلية ──────────────────────────────────
class _InlineMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _InlineMessage(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 12.5, color: color)),
        ),
      ],
    );
  }
}

// ── ويدجت مساعدة: شرائح مؤشر الخطوة ───────────────────────────────────────
class _StepChips extends StatelessWidget {
  final bool nameFocused;
  final bool priceFocused;
  final bool nameHasValue;
  const _StepChips(
      {required this.nameFocused,
      required this.priceFocused,
      required this.nameHasValue});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _Chip(
          label: 'الاسم',
          icon: Icons.edit_outlined,
          isActive: nameFocused,
          isDone: nameHasValue && !nameFocused,
          cs: cs,
        ),
        const SizedBox(width: 8),
        _Chip(
          label: 'السعر',
          icon: Icons.attach_money_rounded,
          isActive: priceFocused,
          isDone: false,
          cs: cs,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDone;
  final ColorScheme cs;
  const _Chip(
      {required this.label,
      required this.icon,
      required this.isActive,
      required this.isDone,
      required this.cs});

  @override
  Widget build(BuildContext context) {
    final Color bg = isDone
        ? cs.secondaryContainer
        : isActive
            ? cs.primaryContainer
            : cs.surfaceContainerHighest;
    final Color fg = isDone
        ? cs.onSecondaryContainer
        : isActive
            ? cs.onPrimaryContainer
            : cs.outline;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? cs.primary.withValues(alpha: 0.4) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_rounded : icon,
            size: 13,
            color: fg,
          ),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: fg)),
        ],
      ),
    );
  }
}