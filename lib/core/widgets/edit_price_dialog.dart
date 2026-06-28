// lib/core/widgets/edit_price_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // عنوان ذكي: يعرض اسم المنتج إذا تم تمريره، وإلا يعرض "تعديل السعر"
    final titleText = widget.itemName != null 
        ? 'السعر لـ "${widget.itemName}"' 
        : 'تعديل السعر';

    return AlertDialog(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'السعر',
            hintText: '0.00',
            border: OutlineInputBorder(), // إضافة إطار ليكون أوضح في الديالوج
          ),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final cleanValue = value.trim();
            final parsed = double.tryParse(cleanValue);
            if (parsed == null) return 'صيغة السعر غير صحيحة';
            if (parsed < 0) return 'لا يمكن أن يكون السعر سالباً';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _cancelledResult),
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