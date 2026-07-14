// lib/screens/add_edit_item/mixins/discard_mixin.dart
import 'package:flutter/material.dart';
import '../add_edit_item_state.dart';
import '../../../core/utils/context_extensions.dart';

mixin DiscardMixin on AddEditItemState {
  Future<bool> confirmDiscard() async {
    if (!hasChanges) return true;

    final theme = Theme.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(context.loc.discardDialogTitle),
        content: Text(context.loc.discardDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.loc.cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              minimumSize: const Size(80, 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.discardLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}