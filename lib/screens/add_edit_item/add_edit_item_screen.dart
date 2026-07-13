// lib/screens/add_edit_item/add_edit_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_orders_tracker/core/theme/app_theme.dart';
import '../../models/item_model.dart';
import 'add_edit_item_state.dart';
import 'mixins/save_mixin.dart';
import 'mixins/delete_mixin.dart';
import 'mixins/date_picker_mixin.dart';
import 'mixins/discard_mixin.dart';
import 'widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/context_extensions.dart';

/// شاشة إضافة/تعديل مادة.
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
    final theme = Theme.of(context);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack();
        },
        child: Scaffold(
          appBar: _buildAppBar(theme),
          body: SafeArea(
            child: _buildForm(theme),
          ),
        ),
      ),
    );
  }

AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(isEditing ? context.loc.editItemTitle : context.loc.addItemScreenTitle),
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: context.loc.backTooltip,
        onPressed: saving ? null : _handleBack,
      ),
      actions: [
        if (isEditing)
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: context.loc.deleteTooltip,
            onPressed: saving ? null : delete,
          ),
      ],
    );
  }

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

  List<Widget> _buildNotificationsSection(ThemeData theme) {
    return [
      SectionTitle(
        title: context.loc.notificationsSectionTitle,
        icon: Icons.notifications_outlined,
      ),
      const SizedBox(height: 8),
      Material(
        color: theme.colorScheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: SwitchListTile(
          title: Text(context.loc.enableNotificationsTitle),
          subtitle: Text(
            notificationsEnabled
                ? context.loc.notificationsEnabledSubtitle
                : context.loc.notificationsDisabledSubtitle,
            style: theme.textTheme.bodySmall,
          ),
          value: notificationsEnabled,
          onChanged: (v) => setState(() => notificationsEnabled = v),
          secondary: Icon(
            notificationsEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: notificationsEnabled ? theme.colorScheme.primary : theme.iconTheme.color,
          ),
        ),
      ),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildThresholdsSection(ThemeData theme) {
    final cs = theme.colorScheme;
    return [
      SectionTitle(
        title: context.loc.thresholdsSectionTitle,
        icon: Icons.tune_outlined,
      ),
      const SizedBox(height: 4),
      Text(
        context.loc.thresholdsDescription,
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: ThresholdField(
              controller: safeCtrl,
              label: context.loc.safeThresholdLabel,
              color: theme.extension<CustomColors>()?.safe ?? const Color(0xFF00A884),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ThresholdField(
              controller: warningCtrl,
              label: context.loc.warningThresholdLabel,
              color: cs.tertiary,
            ),
          ),
          const SizedBox(width: 8),
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
      const SizedBox(height: 12),
      AppTextField(
        controller: nameCtrl,
        label: context.loc.itemNameFieldLabel,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        hint: context.loc.itemNameFieldHint,
        icon: Icon(Icons.label_outline, color: Theme.of(context).colorScheme.primary),
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
      const SizedBox(height: 12),
      AppTextField(
        controller: descCtrl,
        label: context.loc.quantityDescriptionLabel,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        hint: context.loc.quantityDescriptionHint,
        icon: Icon(Icons.notes_outlined, color: Theme.of(context).colorScheme.primary),
        focusNode: _descFocus,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _daysFocus.requestFocus(),
      ),
      const SizedBox(height: 12),
      AppTextField(
        controller: daysCtrl,
        label: context.loc.expectedDaysLabel,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        hint: context.loc.expectedDaysHint,
        icon: Icon(Icons.calendar_today_outlined, color: Theme.of(context).colorScheme.primary),
        keyboardType: TextInputType.number,
        suffix: context.loc.daysSuffix,
        suffixStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        focusNode: _daysFocus,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: (_) => _daysFocus.unfocus(),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return context.loc.enterDaysError;
          final n = int.tryParse(v.trim());
          if (n == null || n <= 0) return context.loc.enterValidNumberError;
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
        label: context.loc.notesLabel,
        hint: context.loc.notesHint,
        icon: Icon(Icons.edit_note_outlined, color: Theme.of(context).colorScheme.primary),
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        minLines: 3,
        maxLines: null,
      ),
    ];
  }

  List<Widget> _buildSaveSection() {
    final theme = Theme.of(context);
    return [
      const SizedBox(height: 32),
      FilledButton.icon(
        onPressed: saving ? null : save,
        icon: saving
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Icon(isEditing ? Icons.save_outlined : Icons.add),
        label: Text(isEditing ? context.loc.saveChangesButton : context.loc.addItemSubmitButton),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      const SizedBox(height: 20),
    ];
  }
}