// lib/screens/add_edit_item/widgets/restock_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baly_groceries_tracker/l10n/app_localizations.dart';
import 'package:baly_groceries_tracker/screens/add_edit_item/widgets/field_utils.dart';

typedef RestockDialogResult = ({bool confirmed, int? newTotalDays});
const RestockDialogResult _cancelledResult = (confirmed: false, newTotalDays: null);

Future<RestockDialogResult> showRestockDialog(
  BuildContext context, {
  String? itemName,
  int? remainingDaysFromNow,
}) async {
  final result = await showDialog<RestockDialogResult>(
    context: context,
    builder: (context) => _RestockDialog(
      itemName: itemName,
      remainingDaysFromNow: remainingDaysFromNow,
    ),
  );
  return result ?? _cancelledResult;
}

class _RestockDialog extends StatefulWidget {
  final String? itemName;
  final int? remainingDaysFromNow;

  const _RestockDialog({
    this.itemName,
    this.remainingDaysFromNow,
  });

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _currentDaysController;
  late final TextEditingController _addedDaysController;

  // The original value stored in the database.
  late final int _originalDays;

  final _currentDaysFocus = FocusNode();
  final _addedDaysFocus = FocusNode();
  late final EndCursorOnFocus _currentCursorHelper;
  late final EndCursorOnFocus _addedCursorHelper;

  @override
  void initState() {
    super.initState();
    _originalDays = (widget.remainingDaysFromNow != null && widget.remainingDaysFromNow! > 0)
        ? widget.remainingDaysFromNow!
        : 0;

    // Pre-fill with '0' if expired or zero, ensuring instant validation readiness
    _currentDaysController = TextEditingController(
      text: _originalDays.toString(),
    );

    _addedDaysController = TextEditingController();

    _currentCursorHelper = EndCursorOnFocus(
      controller: _currentDaysController,
      focusNode: _currentDaysFocus,
    );
    _addedCursorHelper = EndCursorOnFocus(
      controller: _addedDaysController,
      focusNode: _addedDaysFocus,
    );
  }

  @override
  void dispose() {
    _currentCursorHelper.dispose();
    _addedCursorHelper.dispose();
    _currentDaysFocus.dispose();
    _addedDaysFocus.dispose();
    _currentDaysController.dispose();
    _addedDaysController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final finalDays = _calculateFinalTotal();
      if (finalDays > 0) {
        Navigator.pop(context, (confirmed: true, newTotalDays: finalDays));
      }
    }
  }

  // Calculates the final total in real time.
  int _calculateFinalTotal() {
    final current = int.tryParse(_currentDaysController.text.trim()) ?? 0;
    final added = int.tryParse(_addedDaysController.text.trim()) ?? 0;
    if (current < 0 || added < 0) return 0;
    return current + added;
  }

  InputDecoration _fieldDecoration(
    ColorScheme cs, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelStyle: TextStyle(color: cs.primary),
      filled: true,
      fillColor: cs.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final hasItemName = widget.itemName != null && widget.itemName!.trim().isNotEmpty;
    final titleText = hasItemName
        ? l10n.restockDialogTitleWithItem(widget.itemName!.trim())
        : l10n.restockDialogTitleDefault;

    final finalTotal = _calculateFinalTotal();

    final media = MediaQuery.of(context);

    final maxContentHeight = media.size.height * 0.62;

    return AlertDialog.adaptive(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2_outlined, color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titleText,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: maxContentHeight,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.restockDialogDescription,
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _currentDaysController,
                  focusNode: _currentDaysFocus,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(color: cs.onSurface),
                  cursorColor: cs.primary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(
                    cs,
                    label: l10n.currentDaysLabel,
                    hint: l10n.currentDaysHint,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.requiredFieldError;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 0) return l10n.invalidNumberError;
                    return null;
                  },
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.originalValueLabel(_originalDays),
                          style: textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                TextFormField(
                  controller: _addedDaysController,
                  focusNode: _addedDaysFocus,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(color: cs.onSurface),
                  cursorColor: cs.primary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration(
                    cs,
                    label: l10n.addedDaysLabel,
                    hint: l10n.addedDaysHint,
                  ),
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return l10n.requiredFieldError;
                    final n = int.tryParse(value.trim());
                    if (n == null || n <= 0) return l10n.invalidNumberError;
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Live final total display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.finalTotalLabel,
                          style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.daysValueText(finalTotal),
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _cancelledResult),
          child: Text(l10n.cancelButton),
        ),
        FilledButton.icon(
          onPressed: (finalTotal > 0 && _currentDaysController.text.isNotEmpty && _addedDaysController.text.isNotEmpty) 
            ? _submit 
            : null,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.saveUpdateButton),
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}