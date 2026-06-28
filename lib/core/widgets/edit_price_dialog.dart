// lib/core/widgets/edit_price_dialog.dart


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  static final _formatter = NumberFormat('#,##0.###');
  late final TextEditingController _controller;
  // دالة مساعدة لتنظيف النص من الفواصل
  String _cleanText(String text) => text.replaceAll(',', '');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialPrice != null
          ? _formatter.format(widget.initialPrice)
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
      final text = _controller.text.trim();
      final cleanText = _cleanText(text);
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'السعر',
            hintText: '0.00',
          ),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final cleanValue = _cleanText(value.trim());
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