// lib/screens/add_edit_item/mixins/save_mixin.dart
import 'package:flutter/material.dart';
import '../../../models/item_model.dart';
import '../../../providers/items_provider.dart';
import '../add_edit_item_state.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/context_extensions.dart';

mixin SaveMixin on AddEditItemState {
  static const int _defaultWarningThreshold = 10;
  static const int _defaultUrgentThreshold = 3;

  void Function(String message) get showError;

  Future<void> save() async {
    if (saving) return;

    FocusScope.of(context).unfocus();
    setNameErrorText(null);

    if (!formKey.currentState!.validate()) return;

    final name = nameCtrl.text.trim();
    final notifier = ref.read(itemsProvider.notifier);

    if (_isDuplicateName(notifier, name)) {
      setNameErrorText(context.loc.duplicateNameError);
      return;
    }

    final days = int.tryParse(daysCtrl.text.trim());
    if (days == null) {
      showError(context.loc.invalidDaysError);
      return;
    }

    final warn =
        int.tryParse(warningCtrl.text.trim()) ?? _defaultWarningThreshold;
    final urgent =
        int.tryParse(urgentCtrl.text.trim()) ?? _defaultUrgentThreshold;

    final thresholdError = _validateThresholds( warn, urgent);
    if (thresholdError != null) {
      showError(thresholdError);
      return;
    }

    await _persist(
      notifier: notifier,
      name: name,
      days: days,
      warn: warn,
      urgent: urgent,
    );
  }

  bool _isDuplicateName(ItemsNotifier notifier, String name) {
    return notifier.isNameDuplicate(
      name,
      excludeId: isEditing ? widget.item!.id : null,
    );
  }

  String? _validateThresholds(int warn, int urgent) {
    if (warn < 0 || urgent < 0) {
      return context.loc.negativeThresholdError;
    }
    if (warn <= urgent) {
      return context.loc.thresholdOrderError;
    }
    return null;
  }

  Future<void> _persist({
    required ItemsNotifier notifier,
    required String name,
    required int days,
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
          warningThresholdDays: warn,
          urgentThresholdDays: urgent,
          notificationsEnabled: notificationsEnabled,
          lastRefreshedAt: lastRefreshedAt,
        );
      }
      
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      showError(context.loc.genericSaveError);
    } finally {
      if (mounted) setState(() => setSaving(false));
    }
  }
}