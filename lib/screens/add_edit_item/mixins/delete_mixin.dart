// lib/screens/add_edit_item/mixins/delete_mixin.dart
import 'package:flutter/material.dart';
import '../../../providers/items_provider.dart';
import '../add_edit_item_state.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/context_extensions.dart';

mixin DeleteMixin on AddEditItemState {
  bool _deleting = false;

  Future<void> delete() async {
    if (_deleting) return;

    final itemName = widget.item!.name;
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.loc.deleteItemDialogTitle),
        content: Text(context.loc.deleteItemDialogContentFormat(itemName)),
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
            ),
            child: Text(context.loc.deleteButtonLabel),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    try {
      await ref.read(itemsProvider.notifier).deleteItem(widget.item!.id);

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.loc.deleteItemError, style: TextStyle(color: theme.colorScheme.onError)),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }
}