// lib/screens/add_edit_item/add_edit_item_mixins.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/item_model.dart';
import '../../providers/items_provider.dart';
import 'add_edit_item_state.dart';

/// Handles save logic
mixin SaveMixin on AddEditItemState {
  Future<void> save() async {
    if (saving) return;
    setState(() => nameErrorText = null);

    if (!formKey.currentState!.validate()) return;

    final notifier = ref.read(itemsProvider.notifier);

    final isDuplicate = notifier.isNameDuplicate(
      nameCtrl.text.trim(),
      excludeId: isEditing ? widget.item!.id : null,
    );
    if (isDuplicate) {
      setState(() => nameErrorText = 'الاسم موجود مسبقاً');
      return;
    }

    final days = int.parse(daysCtrl.text.trim());
    final safe = int.tryParse(safeCtrl.text.trim()) ?? 20;
    final warn = int.tryParse(warningCtrl.text.trim()) ?? 10;
    final urg = int.tryParse(urgentCtrl.text.trim()) ?? 3;
    final notes = notesCtrl.text.trim();

    if (safe <= warn || warn <= urg) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يجب أن تكون الحدود مرتبة: الآمن > الانتباه > العاجل'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => saving = true);
    try {
      if (isEditing) {
        final updated = ItemModel(
          id: widget.item!.id,
          name: nameCtrl.text.trim(),
          quantityDescription: descCtrl.text.trim(),
          expectedDays: days,
          createdAt: widget.item!.createdAt,
          notificationsEnabled: notificationsEnabled,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urg,
          lastRefreshedAt: lastRefreshedAt,
          notes: notes.isEmpty ? null : notes,
        );
        await notifier.updateItem(updated);
      } else {
        await notifier.addItem(
          name: nameCtrl.text.trim(),
          quantityDescription: descCtrl.text.trim(),
          expectedDays: days,
          notes: notes.isEmpty ? null : notes,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urg,
          notificationsEnabled: notificationsEnabled,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }
}

/// Handles delete logic
mixin DeleteMixin on AddEditItemState {
  Future<void> delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المادة'),
        content: Text('هل تريد حذف "${widget.item!.name}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(itemsProvider.notifier).deleteItem(widget.item!.id);
      if (mounted) Navigator.pop(context);
    }
  }
}

/// Handles date picking and reset
mixin DatePickerMixin on AddEditItemState {
  final _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> pickLastRefreshedDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: lastRefreshedAt.isAfter(now) ? now : lastRefreshedAt,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      locale: const Locale('ar'),
      helpText: 'اختر تاريخ التجديد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );
    if (picked == null) return;
    setState(() {
      lastRefreshedAt = picked;
      dateCtrl.text = _dateFormat.format(picked);
    });
  }

  Future<void> resetLastRefreshedToToday() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة تعيين تاريخ التجديد'),
        content: const Text('هل تريد تعيين تاريخ التجديد إلى تاريخ اليوم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('موافق'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final today = DateTime.now();
    setState(() {
      lastRefreshedAt = today;
      dateCtrl.text = _dateFormat.format(today);
    });
  }
}

/// Handles unsaved-changes discard confirmation
mixin DiscardMixin on AddEditItemState {
  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تجاهل التغييرات؟'),
        content: const Text('لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تجاهل'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
