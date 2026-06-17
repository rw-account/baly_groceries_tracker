// lib/screens/add_edit_item/add_edit_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_model.dart';
import 'add_edit_item_state.dart';
import 'add_edit_item_mixins.dart';
import 'add_edit_item_widgets.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final ItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends AddEditItemState
    with SaveMixin, DeleteMixin, DatePickerMixin, DiscardMixin {

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await confirmDiscard();
        if (!context.mounted) return;
        if (canLeave && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'تعديل المادة' : 'إضافة مادة جديدة'),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final canLeave = await confirmDiscard();
              if (!context.mounted) return;
              if (canLeave && mounted) Navigator.pop(context);
            },
          ),
          actions: [
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: delete,
                tooltip: 'حذف',
              ),
          ],
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Notifications ──────────────────────────────────────────────
              buildSectionTitle(context, 'الإشعارات', Icons.notifications_outlined),
              const SizedBox(height: 8),
              Material(
                color: theme.colorScheme.surface,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: SwitchListTile(
                  title: const Text('تفعيل الإشعارات'),
                  subtitle: Text(
                    notificationsEnabled
                        ? 'ستصلك إشعارات عند الاقتراب من النفاذ'
                        : 'لن تصلك أي إشعارات لهذه المادة',
                    style: theme.textTheme.bodySmall,
                  ),
                  value: notificationsEnabled,
                  onChanged: (v) => setState(() => notificationsEnabled = v),
                  secondary: Icon(
                    notificationsEnabled
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: notificationsEnabled ? Colors.green : Colors.grey,
                  ),
                ),
              ),

              // ── Thresholds ─────────────────────────────────────────────────
              const SizedBox(height: 24),
              buildSectionTitle(context, 'حدود التنبيه', Icons.tune_outlined),
              const SizedBox(height: 4),
              Text(
                'يحدد التطبيق حالة كل مادة بناءً على هذه الحدود',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: buildThresholdField(
                      controller: safeCtrl,
                      label: '🟢 الحد الآمن',
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildThresholdField(
                      controller: warningCtrl,
                      label: '🟡 حد الانتباه',
                      color: const Color(0xFFF57F17),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: buildThresholdField(
                      controller: urgentCtrl,
                      label: '🔴 الحد العاجل',
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ],
              ),

              // ── Item info ──────────────────────────────────────────────────
              const SizedBox(height: 24),
              buildSectionTitle(context, 'معلومات المادة', Icons.inventory_2_outlined),
              const SizedBox(height: 12),
              buildTextField(
                context: context,
                controller: nameCtrl,
                label: 'اسم المادة',
                hint: 'مثال: سكر، دقيق، زيت',
                icon: Icons.label_outline,
                errorText: nameErrorText,
                onChanged: (_) {
                  if (nameErrorText != null) setState(() => nameErrorText = null);
                },
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              buildTextField(
                context: context,
                controller: descCtrl,
                label: 'وصف الكمية (اختياري)',
                hint: 'مثال: كيس 5 كيلو، عبوتان',
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 12),
              buildTextField(
                context: context,
                controller: daysCtrl,
                label: 'عدد الأيام المتوقعة',
                hint: 'مثال: 30',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                suffix: 'يوم',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'أدخل عدد الأيام';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'أدخل رقمًا صحيحًا';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              buildRefreshDateField(
                context: context,
                dateCtrl: dateCtrl,
                isEditing: isEditing,
                onPickDate: pickLastRefreshedDate,
                onResetToToday: resetLastRefreshedToToday,
              ),
              const SizedBox(height: 12),
              buildTextField(
                context: context,
                controller: notesCtrl,
                label: 'ملاحظات (اختياري)',
                hint: 'اكتب أي ملاحظة إضافية',
                icon: Icons.edit_note_outlined,
                keyboardType: TextInputType.multiline,
                minLines: 3,
                maxLines: null,
              ),

              // ── Save button ────────────────────────────────────────────────
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isEditing ? Icons.save_outlined : Icons.add),
                label: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المادة'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
