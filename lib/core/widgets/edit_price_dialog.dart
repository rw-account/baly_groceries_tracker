// lib/core/widgets/edit_price_dialog.dart


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A reusable dialog that allows the user to edit or clear a price value.
///
/// Returns `(confirmed: false, price: null)` when cancelled, and
/// `(confirmed: true, price: parsedValue)` when the user saves.
/// If the text field is left empty, `price` will be `null`, which clears
/// any previously stored price.
class EditPriceDialog extends StatefulWidget {
  final double? initialPrice;

  const EditPriceDialog({super.key, required this.initialPrice});

  @override
  State<EditPriceDialog> createState() => _EditPriceDialogState();
}

class _EditPriceDialogState extends State<EditPriceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice != null
          ? widget.initialPrice!.toString()
          : '',
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
    return AlertDialog(
      title: const Text('تعديل السعر'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            // 1. يسمح بالأرقام والنقطة العادية فقط، ويمنع الفاصلة (,) تماماً
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            
            // 2. يمنع المستخدم من كتابة أكثر من نقطة عشرية واحدة
            TextInputFormatter.withFunction((oldValue, newValue) {
              if ('.'.allMatches(newValue.text).length > 1) {
                return oldValue; // يرفض النقطة الثانية ويبقي الرقم القديم
              }
              return newValue;
            }),
          ],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'السعر',
            hintText: '0.00',
          ),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final cleanValue = value.trim();
            final parsed = double.tryParse(cleanValue);
            if (parsed == null) return 'يرجى إدخال رقم صحيح';
            if (parsed < 0) return 'لا يمكن أن يكون السعر سالباً';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.pop(context, (confirmed: false, price: null)),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}