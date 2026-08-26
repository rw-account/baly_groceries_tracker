// lib/screens/add_edit_item/mixins/date_picker_mixin.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../add_edit_item_state.dart';
import '../../../core/utils/context_extensions.dart';
import '../../../providers/locale_provider.dart';

mixin DatePickerMixin on AddEditItemState {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  DateTime _toDateOnly(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  Future<void> pickLastRefreshedDate() async {
    if (isPickingDate) return;
    isPickingDate = true;

    try {
      final todayDateOnly = _toDateOnly(DateTime.now());
      final initialDate = (lastRefreshedAt != null && !lastRefreshedAt!.isAfter(todayDateOnly))
        ? _toDateOnly(lastRefreshedAt!)
        : todayDateOnly;
      
      final currentLocale = Locale(LocaleNotifier.currentLanguage);

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: todayDateOnly,
        locale: currentLocale,
        helpText: context.loc.renewalDatePickerHelpText,
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

  Future<void> resetLastRefreshedToToday({bool skipConfirmation = false}) async {
    if (isPickingDate) return;

    if (!skipConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog.adaptive(
          title: Text(context.loc.resetDateDialogTitle),
          content: Text(context.loc.resetDateDialogContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.loc.cancelLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                minimumSize: const Size(80, 40),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(context.loc.resetDateConfirmLabel),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;
    }

    _applyDateChange(DateTime.now());
  }

  void _applyDateChange(DateTime newDate) {
    final dateOnly = _toDateOnly(newDate);
    setState(() {
      lastRefreshedAt = dateOnly;
      dateCtrl.text = _dateFormat.format(dateOnly);
    });
  }
}