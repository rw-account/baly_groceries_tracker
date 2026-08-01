// lib/screens/settings/widgets/custom_days_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_orders_tracker/core/utils/context_extensions.dart';
import 'package:home_orders_tracker/screens/settings/settings_screen.dart';

class CustomDaysDialog extends StatefulWidget {
  final int? initialValue;

  const CustomDaysDialog({super.key, this.initialValue});

  static Future<int?> show(BuildContext context, {int? initialValue}) {
    return showDialog<int>(
      context: context,
      builder: (ctx) => CustomDaysDialog(initialValue: initialValue),
    );
  }

  @override
  State<CustomDaysDialog> createState() => _CustomDaysDialogState();
}

class _CustomDaysDialogState extends State<CustomDaysDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialValue?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.loc.customRetentionDaysTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.loc.customRetentionDaysContent),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: context.loc.customRetentionDaysLabel,
                hintText: context.loc.customRetentionDaysHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) => validateCustomDaysInput(value, context.loc),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context, null);
          },
          child: Text(context.loc.cancelLabel),
        ),
        FilledButton(
          onPressed: () {
            final isValid = _formKey.currentState?.validate() ?? false;
            if (!isValid) return;

            final text = _controller.text.trim();
            final value = int.tryParse(text);
            if (value == null || value <= 0) return;

            FocusScope.of(context).unfocus();
            Navigator.pop(context, value);
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(context.loc.saveLabel),
        ),
      ],
    );
  }
}