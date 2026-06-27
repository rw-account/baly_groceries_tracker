// lib/screens/add_edit_item/mixins/save_mixin.dart
import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../providers/items_provider.dart';
import '../add_edit_item_state.dart';
import 'package:go_router/go_router.dart';

/// Handles the save logic (create / update) for an [ItemModel].
///
/// Any [State] using this mixin must implement the abstract getters below,
/// which expose the form fields and editing context required to build
/// and persist the item.
mixin SaveMixin on AddEditItemState {
  // ---------- Default threshold values ----------
  static const int _defaultSafeThreshold = 20;
  static const int _defaultWarningThreshold = 10;
  static const int _defaultUrgentThreshold = 3;

  // ---------- User-facing messages ----------
  static const String _duplicateNameError = 'الاسم موجود مسبقاً';
  static const String _invalidDaysError = 'يرجى إدخال عدد أيام صحيح';
  static const String _thresholdOrderError =
      'يجب أن تكون الحدود مرتبة: الآمن > الانتباه > العاجل';
  static const String _negativeThresholdError =
      'لا يمكن أن تكون الحدود قيمًا سالبة';
  static const String _genericSaveError =
      'حدث خطأ أثناء حفظ العنصر، حاول مرة أخرى';

  // ---------- Public entry point ----------
  Future<void> save() async {
    if (saving) return;

    FocusScope.of(context).unfocus();
    setNameErrorText(null);

    if (!formKey.currentState!.validate()) return;

    final name = nameCtrl.text.trim();
    final notifier = ref.read(itemsProvider.notifier);

    if (_isDuplicateName(notifier, name)) {
      setNameErrorText(_duplicateNameError);
      return;
    }

    final days = int.tryParse(daysCtrl.text.trim());
    if (days == null) {
      _showError(_invalidDaysError);
      return;
    }

    final safe = int.tryParse(safeCtrl.text.trim()) ?? _defaultSafeThreshold;
    final warn =
        int.tryParse(warningCtrl.text.trim()) ?? _defaultWarningThreshold;
    final urgent =
        int.tryParse(urgentCtrl.text.trim()) ?? _defaultUrgentThreshold;

    final thresholdError = _validateThresholds(safe, warn, urgent);
    if (thresholdError != null) {
      _showError(thresholdError);
      return;
    }

    await _persist(
      notifier: notifier,
      name: name,
      days: days,
      safe: safe,
      warn: warn,
      urgent: urgent,
    );
  }

  // ---------- Helpers ----------

  bool _isDuplicateName(ItemsNotifier notifier, String name) {
    return notifier.isNameDuplicate(
      name,
      excludeId: isEditing ? widget.item!.id : null,
    );
  }

  /// Returns an error message if thresholds are invalid, otherwise null.
  String? _validateThresholds(int safe, int warn, int urgent) {
    if (safe < 0 || warn < 0 || urgent < 0) {
      return _negativeThresholdError;
    }
    if (safe <= warn || warn <= urgent) {
      return _thresholdOrderError;
    }
    return null;
  }

  Future<void> _persist({
    required ItemsNotifier notifier,
    required String name,
    required int days,
    required int safe,
    required int warn,
    required int urgent,
  }) async {
    setState(() => setSaving(true));

    try {
      final description = descCtrl.text.trim();
      final notes = notesCtrl.text.trim();

      if (isEditing) {
        final updated = ItemModel(
          id: widget.item!.id,
          name: name,
          quantityDescription: description,
          expectedDays: days,
          createdAt: widget.item!.createdAt,
          notificationsEnabled: notificationsEnabled,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urgent,
          lastRefreshedAt: lastRefreshedAt,
          notes: notes.isEmpty ? null : notes,
        );
        await notifier.updateItem(updated);
      } else {
        await notifier.addItem(
          name: name,
          quantityDescription: description,
          expectedDays: days,
          notes: notes.isEmpty ? null : notes,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urgent,
          notificationsEnabled: notificationsEnabled,
          lastRefreshedAt: lastRefreshedAt,
        );
      }

      if (mounted) context.pop();
    } catch (e) {
      _showError(_genericSaveError);
    } finally {
      if (mounted) setState(() => setSaving(false));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}