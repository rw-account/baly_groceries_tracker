// lib/screens/add_edit_item/widgets/stock_status_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baly_groceries_tracker/l10n/app_localizations.dart';
import 'package:baly_groceries_tracker/providers/locale_provider.dart';
import 'package:intl/intl.dart';

enum StockStatusChoice { outOfStock, stillAvailable }

typedef StockStatusDialogResult = ({
  bool confirmed,
  StockStatusChoice? choice,
  int? remainingDays,
  DateTime? outOfStockDate
});

const StockStatusDialogResult _cancelledResult = (
  confirmed: false,
  choice: null,
  remainingDays: null,
  outOfStockDate: null
);

Future<StockStatusDialogResult> showStockStatusDialog(
  BuildContext context, {
  String? itemName,
}) async {
  final result = await showDialog<StockStatusDialogResult>(
    context: context,
    builder: (context) => _StockStatusDialog(itemName: itemName),
  );
  return result ?? _cancelledResult;
}

class _StockStatusDialog extends StatefulWidget {
  final String? itemName;
  const _StockStatusDialog({this.itemName});

  @override
  State<_StockStatusDialog> createState() => _StockStatusDialogState();
}

class _StockStatusDialogState extends State<_StockStatusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  
  StockStatusChoice? _selectedChoice = StockStatusChoice.outOfStock;
  
  DateTime _outOfStockDate = DateTime.now();
  bool _isToday = true;
  bool _isYesterday = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickCustomDate() async {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Locale(LocaleNotifier.currentLanguage);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _outOfStockDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: currentLocale,
      helpText: l10n.outOfStockDatePickerHelpText,
      cancelText: l10n.cancelLabel,
      confirmText: l10n.datePickerConfirmText,
    );
    if (picked != null && picked != _outOfStockDate) {
      setState(() {
        _outOfStockDate = picked;
        _isToday = false;
        _isYesterday = false;
      });
    }
  }

  void _submit() {
    if (_selectedChoice == null) return;

    if (_selectedChoice == StockStatusChoice.outOfStock) {
      final now = DateTime.now();
      final cleanNow = DateTime(now.year, now.month, now.day);
      final cleanOutOfStock = DateTime(
        _outOfStockDate.year,
        _outOfStockDate.month,
        _outOfStockDate.day,
      );
      
      final realRemainingDays = cleanOutOfStock.difference(cleanNow).inDays;

      Navigator.pop(context, (
        confirmed: true,
        choice: StockStatusChoice.outOfStock, 
        remainingDays: realRemainingDays, 
        outOfStockDate: _outOfStockDate
      ));
    } else if (_selectedChoice == StockStatusChoice.stillAvailable) {
      if (_formKey.currentState?.validate() ?? false) {
        final days = int.tryParse(_controller.text.trim()) ?? 0;
        Navigator.pop(context, (
          confirmed: true,
          choice: StockStatusChoice.stillAvailable, 
          remainingDays: days,
          outOfStockDate: null
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasItemName = widget.itemName != null && widget.itemName!.trim().isNotEmpty;
    final titleText = hasItemName 
        ? l10n.stockStatusDialogTitleWithItem(widget.itemName!.trim()) 
        : l10n.stockStatusDialogTitle;

    return AlertDialog.adaptive(
      title: Text(titleText),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: RadioGroup<StockStatusChoice>(
            groupValue: _selectedChoice,
            onChanged: (val) => setState(() => _selectedChoice = val),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.stockStatusChooseCorrectStatus,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                
                // First option: Effectively out of stock
                RadioListTile<StockStatusChoice>(
                  value: StockStatusChoice.outOfStock,
                  title: Text(l10n.stockStatusOutOfStockOption),
                  activeColor: cs.error,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Show options only if "Effectively out of stock" is selected
                if (_selectedChoice == StockStatusChoice.outOfStock) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4, bottom: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.stockStatusToday),
                          selected: _isToday,
                          onSelected: (_) {
                            setState(() {
                              _outOfStockDate = DateTime.now();
                              _isToday = true;
                              _isYesterday = false;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: Text(l10n.stockStatusYesterday),
                          selected: _isYesterday,
                          onSelected: (_) {
                            setState(() {
                              _outOfStockDate = DateTime.now().subtract(const Duration(days: 1));
                              _isToday = false;
                              _isYesterday = true;
                            });
                          },
                        ),
                        ActionChip(
                          label: Text(_isToday || _isYesterday ? l10n.stockStatusOtherDate : _formatDate(_outOfStockDate)),
                          avatar: const Icon(Icons.calendar_today_outlined, size: 16),
                          onPressed: _pickCustomDate,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
                
                // Second option: Still have it
                RadioListTile<StockStatusChoice>(
                  value: StockStatusChoice.stillAvailable,
                  title: Text(l10n.stockStatusStillAvailableOption),
                  subtitle: Text(l10n.stockStatusResetRemainingDays),
                  activeColor: cs.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Show input field only if "Still have it" is selected
                if (_selectedChoice == StockStatusChoice.stillAvailable) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: cs.onSurface),
                    cursorColor: cs.primary,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.stockStatusRemainingDaysLabel,
                      hintText: l10n.stockStatusRemainingDaysHint,
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
                      if (value == null || value.trim().isEmpty) return l10n.fieldRequiredValidation;
                      final n = int.tryParse(value.trim());
                      if (n == null || n <= 0) return l10n.enterValidNumberValidation;
                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _cancelledResult),
          child: Text(l10n.cancelLabel),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(l10n.saveLabel),
        ),
      ],
    );
  }
}