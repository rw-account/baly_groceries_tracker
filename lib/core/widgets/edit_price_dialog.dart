// lib/core/widgets/edit_price_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/context_extensions.dart';

/// نوع بيانات موحد لنجاح أو إلغاء الديالوج (أفضل للقراءة)
typedef PriceDialogResult = ({bool confirmed, double? price});
const PriceDialogResult _cancelledResult = (confirmed: false, price: null);

/// دالة مساعدة لتسهيل استدعاء الديالوج ومعالجة الإغلاق بالخارج
Future<PriceDialogResult> showEditPriceDialog(
  BuildContext context, {
  double? initialPrice,
  String? itemName, // اختياري: لعرض اسم المنتج في العنوان
}) async {
  final result = await showDialog<PriceDialogResult>(
    context: context,
    builder: (context) => _EditPriceDialog(
      initialPrice: initialPrice,
      itemName: itemName,
    ),
  );
  return result ?? _cancelledResult;
}

/// A reusable dialog that allows the user to edit or clear a price value.
class _EditPriceDialog extends StatefulWidget {
  final double? initialPrice;
  final String? itemName;

  const _EditPriceDialog({
    this.initialPrice,
    this.itemName,
  });

  @override
  State<_EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<_EditPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice != null ? widget.initialPrice!.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final cleanText = _controller.text.trim();
      final parsed = cleanText.isEmpty ? null : double.tryParse(cleanText);
      Navigator.pop(context, (confirmed: true, price: parsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // عنوان ذكي: يعرض اسم المنتج إذا تم تمريره، وإلا يعرض "تعديل السعر"
    final titleText = widget.itemName != null 
        ? context.loc.editPriceDialogTitleWithItem(widget.itemName!) 
        : context.loc.editPriceDialogTitle;

    return AlertDialog.adaptive(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          style: TextStyle(color: cs.onSurface),
          cursorColor: cs.primary,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              if ('.'.allMatches(newValue.text).length > 1) {
                return oldValue;
              }
              return newValue;
            }),
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.loc.priceFieldLabel,
            hintText: context.loc.priceFieldHint,
            floatingLabelStyle: TextStyle(color: cs.primary),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final cleanValue = value.trim();
            final parsed = double.tryParse(cleanValue);
            if (parsed == null) return context.loc.invalidPriceFormat;
            if (parsed < 0) return context.loc.priceCannotBeNegativeDialog;
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _cancelledResult),
          child: Text(context.loc.cancelLabel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(context.loc.dialogSave),
        ),
      ],
    );
  }
}