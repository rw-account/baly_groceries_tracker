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
import '../../core/utils/context_extensions.dart';

class AddEditItemScreen extends ConsumerStatefulWidget {
  final ItemModel? item;
  const AddEditItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends AddEditItemState
    with SaveMixin, DeleteMixin, DatePickerMixin, DiscardMixin {

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(); 

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

  @override
  void Function(String message) get showError => (String message) {
    final theme = _scaffoldMessengerKey.currentContext != null 
        ? Theme.of(_scaffoldMessengerKey.currentContext!) 
        : ThemeData.dark();
      
    _scaffoldMessengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: TextStyle(color: theme.colorScheme.onError)),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
  };

  Future<void> _handleBack() async {
    if (saving) return;
    final canLeave = await confirmDiscard();
    if (!mounted) return;
    if (canLeave) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack();
        },
        child: Scaffold(
          appBar: _buildAppBar(),
          body: SafeArea(
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final cs = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(isEditing ? context.loc.editItemTitle : context.loc.addItemScreenTitle),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_outlined),
        tooltip: context.loc.backTooltip,
        onPressed: saving ? null : _handleBack,
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.check, color: cs.primary),
          tooltip: isEditing ? context.loc.saveChangesButton : context.loc.addItemSubmitButton,
          onPressed: saving ? null : save,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return AbsorbPointer(
      absorbing: saving,
      child: AnimatedOpacity(
        opacity: saving ? 0.6 : 1,
        duration: const Duration(milliseconds: 200),
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              ..._buildItemInfoSection(),
              const SizedBox(height: 24),
              ..._buildThresholdsSection(),
              const SizedBox(height: 24),
              ..._buildNotificationsSection(),
              const SizedBox(height: 24),
              ..._buildDeleteSection(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNotificationsSection() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return [
      SectionTitle(
        title: context.loc.notificationsSectionTitle,
        icon: Icons.notifications_outlined,
      ),
      const SizedBox(height: 12),
      Card(
        elevation: 0,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: SwitchListTile(
          title: Text(context.loc.enableNotificationsTitle, style: theme.textTheme.titleMedium),
          subtitle: Text(
            notificationsEnabled
                ? context.loc.notificationsEnabledSubtitle
                : context.loc.notificationsDisabledSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          value: notificationsEnabled,
          onChanged: (v) => setState(() => notificationsEnabled = v),
          secondary: Icon(
            notificationsEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: notificationsEnabled ? cs.primary : cs.onSurfaceVariant,
          ),
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    ];
  }

  List<Widget> _buildThresholdsSection() {
    final cs = Theme.of(context).colorScheme;
    return [
      SectionTitle(
        title: context.loc.thresholdsSectionTitle,
        icon: Icons.tune_outlined,
      ),
      const SizedBox(height: 4),
      Text(
        context.loc.thresholdsDescription,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: ThresholdField(
              controller: warningCtrl,
              label: context.loc.warningThresholdLabel,
              color: cs.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ThresholdField(
              controller: urgentCtrl,
              label: context.loc.urgentThresholdLabel,
              color: cs.error,
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildItemInfoSection() {
    return [
      SectionTitle(
        title: context.loc.itemInfoSectionTitle,
        icon: Icons.inventory_2_outlined,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: nameCtrl,
        label: context.loc.itemNameFieldLabel,
        hint: context.loc.itemNameFieldHint,
        icon: const Icon(Icons.label_outline),
        errorText: nameErrorText,
        focusNode: _nameFocus,
        textInputAction: TextInputAction.next,
        maxLength: 40,
        onChanged: (_) {
          if (nameErrorText != null) setNameErrorText(null);
        },
        onSubmitted: (_) => _descFocus.requestFocus(),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? context.loc.nameRequiredError : null,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: descCtrl,
        label: context.loc.quantityDescriptionLabel,
        hint: context.loc.quantityDescriptionHint,
        icon: const Icon(Icons.notes_outlined),
        focusNode: _descFocus,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _daysFocus.requestFocus(),
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: daysCtrl,
        label: context.loc.expectedDaysLabel,
        hint: context.loc.expectedDaysHint,
        icon: const Icon(Icons.calendar_today_outlined),
        keyboardType: TextInputType.number,
        suffix: context.loc.daysSuffix,
        focusNode: _daysFocus,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _daysFocus.unfocus(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return context.loc.enterDaysError;
          final n = int.tryParse(v.trim());
          if (n == null || n < 0) return context.loc.enterValidNumberError;
          return null;
        },
      ),
      const SizedBox(height: 16),
      RefreshDateField(
        dateController: dateCtrl,
        isEditing: isEditing,
        onPickDate: pickLastRefreshedDate,
        onResetToToday: resetLastRefreshedToToday,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: notesCtrl,
        label: context.loc.notesLabel,
        icon: const Icon(Icons.edit_note_outlined),
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 3,
        maxLines: null,
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildDeleteSection() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (!isEditing) {
      return [const SizedBox(height: 8)];
    }
    return [
      const SizedBox(height: 8),
      SectionTitle(
        title: context.loc.deleteItemSectionTitle,
        icon: Icons.delete_outline,
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: saving ? null : delete,
        label: Text(context.loc.deleteItemTitle, style: theme.textTheme.titleMedium?.copyWith(color: cs.onError)),
        style: FilledButton.styleFrom(
          backgroundColor: cs.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          minimumSize: const Size(80, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      const SizedBox(height: 16),
    ];
  }
}