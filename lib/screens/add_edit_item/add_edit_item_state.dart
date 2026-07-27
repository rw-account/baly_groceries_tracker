// lib/screens/add_edit_item/add_edit_item_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_edit_item_screen.dart';
import 'dart:math' as math;

/// Abstract base that owns every controller, field, and computed property.
/// Mixins and the concrete State class compose on top of this.
abstract class AddEditItemState extends ConsumerState<AddEditItemScreen> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController daysCtrl;
  late TextEditingController warningCtrl;
  late TextEditingController urgentCtrl;
  late TextEditingController notesCtrl;
  late TextEditingController dateCtrl;

  late bool notificationsEnabled;
  late DateTime? lastRefreshedAt;
  bool isPickingDate = false;

  String? _nameErrorText;
  String? get nameErrorText => _nameErrorText;
  void setNameErrorText(String? v) {
    if (mounted) setState(() => _nameErrorText = v);
  }

  bool _saving = false;
  bool get saving => _saving;
  void setSaving(bool v) {
    if (mounted) setState(() => _saving = v);
  }

  // Original values for change detection
  late String _initialName;
  late String _initialDesc;
  late String _initialDays;
  late String _initialWarning;
  late String _initialUrgent;
  late String _initialNotes;
  late bool _initialNotificationsEnabled;
  late DateTime? _initialLastRefreshedAt;

  bool get isEditing => widget.item != null;

  bool get hasChanges =>
      nameCtrl.text != _initialName ||
      descCtrl.text != _initialDesc ||
      daysCtrl.text != _initialDays ||
      warningCtrl.text != _initialWarning ||
      urgentCtrl.text != _initialUrgent ||
      notesCtrl.text != _initialNotes ||
      notificationsEnabled != _initialNotificationsEnabled ||
      lastRefreshedAt != _initialLastRefreshedAt;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    final now = DateTime.now();

    // For UI display only: negative remaining days are shown as 0
    // to provide a clearer and more intuitive user experience.
    final remainingDays = i != null ? math.max(0, i.remainingDaysAt(now).toInt()) : null;

    nameCtrl = TextEditingController(text: i?.name ?? '');
    descCtrl = TextEditingController(text: i?.quantityDescription ?? '');
    daysCtrl = TextEditingController(text: remainingDays?.toString() ?? '');
    warningCtrl = TextEditingController(text: (i?.warningThresholdDays ?? 10).toString());
    urgentCtrl = TextEditingController(text: (i?.urgentThresholdDays ?? 3).toString());
    notesCtrl = TextEditingController(text: i?.notes ?? '');
    notificationsEnabled = i?.notificationsEnabled ?? true;
    lastRefreshedAt = i?.lastRefreshedAt;
    
    // Left empty to prevent forgetting to update the renewal date;
    // the validator will show an error if left blank.
    dateCtrl = TextEditingController(text: '',);

    _initialName = nameCtrl.text;
    _initialDesc = descCtrl.text;
    _initialDays = daysCtrl.text;
    _initialWarning = warningCtrl.text;
    _initialUrgent = urgentCtrl.text;
    _initialNotes = notesCtrl.text;
    _initialNotificationsEnabled = notificationsEnabled;
    _initialLastRefreshedAt = lastRefreshedAt;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    daysCtrl.dispose();
    warningCtrl.dispose();
    urgentCtrl.dispose();
    notesCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }
}
