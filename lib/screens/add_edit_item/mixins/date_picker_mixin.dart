// lib/screens/add_edit_item/mixins/date_picker_mixin.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../add_edit_item_state.dart';
import '../../../core/utils/context_extensions.dart';

mixin DatePickerMixin on AddEditItemState {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

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
        helpText: context.loc.datePickerHelpText,
        cancelText: context.loc.cancelLabel,
        confirmText: context.loc.datePickerConfirmText,
      );

      if (picked == null || !mounted) return;

      _applyDateChange(picked);
    } catch (_) {
      if (mounted) {
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.datePickerError, style: TextStyle(color: theme.colorScheme.onTertiary)),
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
        title: Text(context.loc.resetDateDialogTitle),
        content: Text(context.loc.resetDateDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.loc.resetDateConfirmLabel),
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