// lib/screens/add_edit_item/add_edit_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/item_model.dart';
import 'add_edit_item_state.dart';
import 'mixins/save_mixin.dart';
import 'mixins/delete_mixin.dart';
import 'mixins/date_picker_mixin.dart';
import 'mixins/discard_mixin.dart';
import 'widgets/widgets.dart';
import 'package:go_router/go_router.dart';

/// شاشة إضافة/تعديل مادة.
///
/// المنطق (الحفظ، الحذف، اختيار التاريخ، تأكيد التجاهل) موزّع على
/// الـ mixins في `mixins/`، بينما عناصر الواجهة القابلة لإعادة الاستخدام
/// موجودة في `widgets/`. هذا الملف مسؤول فقط عن تركيب الشاشة وتنظيمها.
class AddEditItemScreen extends ConsumerStatefulWidget {
  final ItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends AddEditItemState
    with SaveMixin, DeleteMixin, DatePickerMixin, DiscardMixin {
  // ─── Focus nodes (للتنقل السلس بين الحقول بالضغط على "التالي") ─────────────
  final _nameFocus = FocusNode();
  final _descFocus = FocusNode();
  final _daysFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _descFocus.dispose();
    _daysFocus.dispose();
    super.dispose();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────

  /// يعالج الرجوع للخلف (زر AppBar أو زر النظام)، مع تأكيد التجاهل عند
  /// وجود تغييرات غير محفوظة. يتم تجاهل الطلب أثناء الحفظ لمنع مغادرة
  /// الشاشة في وضع غير مكتمل.
  Future<void> _handleBack() async {
    if (saving) return;
    final canLeave = await confirmDiscard();
    if (!mounted) return;
    if (canLeave) context.pop();
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,  // معناه ان زر الرجوع مغلق تماماً، ولا يمكن للمستخدم الخروج إلا إذا قمت أنت برمجياً باستدعاء Navigator.pop()
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return; // اذا خرج المستخدم بالفعل (مثلاً بالضغط على زر 'الغاء')، ارجع ولا تفعل شيء لمنع الحلقه غير النهائيه
        await _handleBack();
      },
      child: Scaffold(
        appBar: _buildAppBar(theme),
        body: SafeArea(
          child: _buildForm(theme),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(isEditing ? 'تعديل المادة' : 'إضافة مادة جديدة'),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'رجوع',
        onPressed: saving ? null : _handleBack,
      ),
      actions: [
        if (isEditing)
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: 'حذف',
            onPressed: saving ? null : delete,
          ),
      ],
    );
  }

  /// يلفّ محتوى النموذج بـ [AbsorbPointer]/[AnimatedOpacity] حتى تُعطَّل
  /// كل الحقول والأزرار تلقائيًا أثناء الحفظ، بدل تعطيل كل حقل يدويًا.
  Widget _buildForm(ThemeData theme) {
    return AbsorbPointer(
      absorbing: saving,
      child: AnimatedOpacity(
        opacity: saving ? 0.6 : 1,
        duration: const Duration(milliseconds: 200),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              ..._buildNotificationsSection(theme),
              ..._buildThresholdsSection(theme),
              ..._buildItemInfoSection(),
              ..._buildSaveSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notifications ─────────────────────────────────────────────────────

  List<Widget> _buildNotificationsSection(ThemeData theme) {
    return [
      const SectionTitle(
        title: 'الإشعارات',
        icon: Icons.notifications_outlined,
      ),
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
                ? 'ستصلك إشعارات عند الاقتراب من النفاد'
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
      const SizedBox(height: 24),
    ];
  }

  // ── Thresholds ─────────────────────────────────────────────────────────

  List<Widget> _buildThresholdsSection(ThemeData theme) {
    return [
      const SectionTitle(
        title: 'حدود التنبيه',
        icon: Icons.tune_outlined,
      ),
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
            child: ThresholdField(
              controller: safeCtrl,
              label: '🟢 الحد الآمن',
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ThresholdField(
              controller: warningCtrl,
              label: '🟡 حد الانتباه',
              color: const Color(0xFFF57F17),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ThresholdField(
              controller: urgentCtrl,
              label: '🔴 الحد العاجل',
              color: const Color(0xFFC62828),
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  // ── Item info ────────────────────────────────────────────────────────────

  List<Widget> _buildItemInfoSection() {
    return [
      const SectionTitle(
        title: 'معلومات المادة',
        icon: Icons.inventory_2_outlined,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: nameCtrl,
        label: 'اسم المادة',
        hint: 'مثال: سكر، دقيق، زيت',
        icon: Icons.label_outline,
        errorText: nameErrorText,
        focusNode: _nameFocus,
        textInputAction: TextInputAction.next,
        maxLength: 40,
        onChanged: (_) {
          // يمسح رسالة الخطأ (مثل "الاسم موجود مسبقاً") بمجرد ما يبدأ
          // المستخدم بالتعديل، بدل انتظار محاولة حفظ جديدة.
          if (nameErrorText != null) setNameErrorText(null);
        },
        onSubmitted: (_) => _descFocus.requestFocus(),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: descCtrl,
        label: 'وصف الكمية (اختياري)',
        hint: 'مثال: كيس 5 كيلو، عبوتان',
        icon: Icons.notes_outlined,
        focusNode: _descFocus,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _daysFocus.requestFocus(),
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: daysCtrl,
        label: 'عدد الأيام المتوقعة',
        hint: 'مثال: 30',
        icon: Icons.calendar_today_outlined,
        keyboardType: TextInputType.number,
        suffix: 'يوم',
        focusNode: _daysFocus,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _daysFocus.unfocus(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'أدخل عدد الأيام';
          final n = int.tryParse(v.trim());
          if (n == null || n <= 0) return 'أدخل رقمًا صحيحًا';
          return null;
        },
      ),
      const SizedBox(height: 12),
      RefreshDateField(
        dateController: dateCtrl,
        isEditing: isEditing,
        onPickDate: pickLastRefreshedDate,
        onResetToToday: resetLastRefreshedToToday,
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: notesCtrl,
        label: 'ملاحظات (اختياري)',
        hint: 'اكتب أي ملاحظة إضافية',
        icon: Icons.edit_note_outlined,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 3,
        maxLines: null,
      ),
    ];
  }

  // ── Save button ──────────────────────────────────────────────────────────

  List<Widget> _buildSaveSection() {
    return [
      const SizedBox(height: 32),
      FilledButton.icon(
        onPressed: saving ? null : save,
        icon: saving
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(isEditing ? Icons.save_outlined : Icons.add),
        label: Text(isEditing ? 'حفظ التعديلات' : 'إضافة المادة'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }
}