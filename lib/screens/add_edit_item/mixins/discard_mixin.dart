// lib/screens/add_edit_shared/mixins/discard_mixin.dart
import 'package:flutter/material.dart';
import '../add_edit_item_state.dart';

/// Handles unsaved-changes discard confirmation.
///
/// Shows a modal dialog when the user tries to leave the screen while
/// there are pending modifications. Relies on [hasChanges] from the
/// attached [AddEditItemState].
mixin DiscardMixin on AddEditItemState {
  // ---------- User-facing messages ----------
  static const String _discardTitle = 'تجاهل التغييرات؟';
  static const String _discardContent =
      'لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟';
  static const String _cancelLabel = 'إلغاء';
  static const String _discardLabel = 'تجاهل';

  // ---------- Public API ----------

  /// Returns `true` if navigation should proceed (no changes or user
  /// confirmed discard), and `false` if the user cancelled the dialog.
  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(_discardTitle),
        content: const Text(_discardContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(_cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(_discardLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}