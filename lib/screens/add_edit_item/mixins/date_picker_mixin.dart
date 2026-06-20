// lib/screens/add_edit_item/mixins/date_picker_mixin.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../add_edit_item_state.dart';

/// Provides date picking and reset logic for the "last refreshed" field.
///
/// Mix this into [AddEditItemState] to allow the user to select a custom
/// date or reset it to today, with proper validation and error feedback.
mixin DatePickerMixin on AddEditItemState {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // ---------- Date picker labels (localized) ----------
  static const String _datePickerHelpText = 'اختر تاريخ التجديد';
  static const String _datePickerCancelText = 'إلغاء';
  static const String _datePickerConfirmText = 'تأكيد';
  static const String _datePickerError = 'تعذّر فتح منتقي التاريخ، يرجى المحاولة مرة أخرى';

  // ---------- Reset dialog labels ----------
  static const String _resetDialogTitle = 'إعادة تعيين تاريخ التجديد';
  static const String _resetDialogContent = 'هل تريد تعيين تاريخ التجديد إلى تاريخ اليوم؟';
  static const String _resetCancelLabel = 'إلغاء';
  static const String _resetConfirmLabel = 'موافق';

  /// Opens a date picker and updates [lastRefreshedAt] with the chosen date.
  ///
  /// The picker restricts selection to dates within the past 5 years up to
  /// today. If [lastRefreshedAt] is in the future (e.g., due to manual edit),
  /// the picker automatically caps the initial date to today.
  Future<void> pickLastRefreshedDate() async {
    // Prevent overlapping date picker dialogs
    if (isPickingDate) return;
    isPickingDate = true;

    try {
      final now = DateTime.now();

      // Ensure the initial date is not after today to avoid picker issues.
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_datePickerError),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isPickingDate = false);
      }
    }
  }

  /// Resets [lastRefreshedAt] to today's date after a confirmation dialog.
  ///
  /// A confirmation dialog is shown to prevent accidental resets. On approval,
  /// the date is set to today and the text field is updated accordingly.
  Future<void> resetLastRefreshedToToday() async {
    // Prevent multiple dialog opens at once
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

  // ---------- Private helpers ----------

  /// Updates [lastRefreshedAt] and the associated text controller.
  void _applyDateChange(DateTime newDate) {
    setState(() {
      lastRefreshedAt = newDate;
      dateCtrl.text = _dateFormat.format(newDate);
    });
  }
}