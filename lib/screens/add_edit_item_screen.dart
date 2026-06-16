// lib/screens/add_edit_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../providers/items_provider.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final ItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _daysCtrl;
  late TextEditingController _safeCtrl;
  late TextEditingController _warningCtrl;
  late TextEditingController _urgentCtrl;
  late bool _notificationsEnabled;

  String? _nameErrorText;
  bool _saving = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _descCtrl = TextEditingController(text: i?.quantityDescription ?? '');
    _daysCtrl = TextEditingController(
        text: i?.expectedDays.toString() ?? '');
    _safeCtrl = TextEditingController(
        text: (i?.safeThresholdDays ?? 20).toString());
    _warningCtrl = TextEditingController(
        text: (i?.warningThresholdDays ?? 10).toString());
    _urgentCtrl = TextEditingController(
        text: (i?.urgentThresholdDays ?? 3).toString());
    _notificationsEnabled = i?.notificationsEnabled ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _daysCtrl.dispose();
    _safeCtrl.dispose();
    _warningCtrl.dispose();
    _urgentCtrl.dispose();
    super.dispose();
  }

  // ─── Save ─────────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _nameErrorText = null);

    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(itemsProvider.notifier);

    final isDuplicate = notifier.isNameDuplicate(
      _nameCtrl.text.trim(),
      excludeId: _isEditing ? widget.item!.id : null,
    );
    if (isDuplicate) {
      setState(() => _nameErrorText = 'الاسم موجود مسبقاً');
      return;
    }

    final days = int.parse(_daysCtrl.text.trim());
    final safe = int.tryParse(_safeCtrl.text.trim()) ?? 20;
    final warn = int.tryParse(_warningCtrl.text.trim()) ?? 10;
    final urg = int.tryParse(_urgentCtrl.text.trim()) ?? 3;

    // Validate threshold order: safe > warning > urgent.
    if (safe <= warn || warn <= urg) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'يجب أن تكون الحدود مرتبة: الآمن > الانتباه > العاجل'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        final updated = ItemModel(
          id: widget.item!.id,
          name: _nameCtrl.text.trim(),
          quantityDescription: _descCtrl.text.trim(),
          expectedDays: days,
          createdAt: widget.item!.createdAt,
          notificationsEnabled: _notificationsEnabled,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urg,
          lastRefreshedAt: widget.item!.lastRefreshedAt,
        );
        await notifier.updateItem(updated);
      } else {
        await notifier.addItem(
          name: _nameCtrl.text.trim(),
          quantityDescription: _descCtrl.text.trim(),
          expectedDays: days,
          safeThresholdDays: safe,
          warningThresholdDays: warn,
          urgentThresholdDays: urg,
          notificationsEnabled: _notificationsEnabled,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ─── Delete ───────────────────────────────────────────────────────────────────

  Future<void> _delete() async {
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

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل المادة' : 'إضافة مادة جديدة'),
        centerTitle: false,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _delete,
              tooltip: 'حذف',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('معلومات المادة', Icons.inventory_2_outlined),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameCtrl,
              label: 'اسم المادة',
              hint: 'مثال: سكر، دقيق، زيت',
              icon: Icons.label_outline,
              errorText: _nameErrorText,
              onChanged: (_) {
                if (_nameErrorText != null) {
                  setState(() => _nameErrorText = null);
                }
              },
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _descCtrl,
              label: 'وصف الكمية (اختياري)',
              hint: 'مثال: كيس 5 كيلو، عبوتان',
              icon: Icons.notes_outlined,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _daysCtrl,
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
            const SizedBox(height: 24),
            _sectionTitle('حدود التنبيه', Icons.tune_outlined),
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
                  child: _buildThresholdField(
                    controller: _safeCtrl,
                    label: '🟢 الحد الآمن',
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThresholdField(
                    controller: _warningCtrl,
                    label: '🟡 حد الانتباه',
                    color: const Color(0xFFF57F17),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThresholdField(
                    controller: _urgentCtrl,
                    label: '🔴 الحد العاجل',
                    color: const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('الإشعارات', Icons.notifications_outlined),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SwitchListTile(
                title: const Text('تفعيل الإشعارات'),
                subtitle: Text(
                  _notificationsEnabled
                      ? 'ستصلك إشعارات عند الاقتراب من النفاذ'
                      : 'لن تصلك أي إشعارات لهذه المادة',
                  style: theme.textTheme.bodySmall,
                ),
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                secondary: Icon(
                  _notificationsEnabled
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  color:
                      _notificationsEnabled ? Colors.green : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_isEditing
                      ? Icons.save_outlined
                      : Icons.add),
              label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة المادة'),
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
    );
  }

  // ─── Helper widgets ───────────────────────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    String? errorText,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: () {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (controller.text.isNotEmpty) {
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          }
        });
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        filled: true,
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
    );
  }

  Widget _buildThresholdField({
    required TextEditingController controller,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          onTap: () {
            Future.delayed(const Duration(milliseconds: 50), () {
              if (controller.text.isNotEmpty) {
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            });
          },
          decoration: InputDecoration(
            suffixText: 'يوم',
            suffixStyle: const TextStyle(fontSize: 11),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          ),
        ),
      ],
    );
  }
}
