// lib/screens/add_edit_item/mixins/date_picker_mixin.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../add_edit_item_state.dart';

mixin DatePickerMixin on AddEditItemState {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static const String _datePickerHelpText = 'اختر تاريخ التجديد';
  static const String _datePickerCancelText = 'إلغاء';
  static const String _datePickerConfirmText = 'تأكيد';
  static const String _datePickerError = 'تعذّر فتح منتقي التاريخ، يرجى المحاولة مرة أخرى';

  static const String _resetDialogTitle = 'إعادة تعيين تاريخ التجديد';
  static const String _resetDialogContent = 'هل تريد تعيين تاريخ التجديد إلى تاريخ اليوم؟';
  static const String _resetCancelLabel = 'إلغاء';
  static const String _resetConfirmLabel = 'موافق';

  Future<void> pickLastRefreshedDate() async {
    if (isPickingDate) return;
    isPickingDate = true;

    try {
      final now = DateTime.now();
      final initialDate = lastRefreshedAt.isAfter(now) ? now : lastRefreshedAt;

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(now.year - 5),
        lastDate: now,
        locale: const Locale('ar'),
        helpText: _datePickerHelpText,
        cancelText: _datePickerCancelText,
        confirmText: _datePickerConfirmText,
      );

      if (picked == null || !mounted) return;

      _applyDateChange(picked);
    } catch (_) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_datePickerError, style: TextStyle(color: theme.colorScheme.onTertiary)),
            backgroundColor: theme.colorScheme.tertiary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isPickingDate = false);
      }
    }
  }

  Future<void> resetLastRefreshedToToday() async {
    if (isPickingDate) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(_resetDialogTitle),
        content: const Text(_resetDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(_resetCancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(_resetConfirmLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    _applyDateChange(DateTime.now());
  }

  void _applyDateChange(DateTime newDate) {
    setState(() {
      lastRefreshedAt = newDate;
      dateCtrl.text = _dateFormat.format(newDate);
    });
  }
}