// lib/screens/add_edit_shared/mixins/discard_mixin.dart
import 'package:flutter/material.dart';
import '../add_edit_item_state.dart';

mixin DiscardMixin on AddEditItemState {
  static const String _discardTitle = 'تجاهل التغييرات؟';
  static const String _discardContent =
      'لديك تغييرات غير محفوظة. هل تريد الخروج دون حفظ؟';
  static const String _cancelLabel = 'إلغاء';
  static const String _discardLabel = 'تجاهل';

  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;

    final theme = Theme.of(context);
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
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text(_discardLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}