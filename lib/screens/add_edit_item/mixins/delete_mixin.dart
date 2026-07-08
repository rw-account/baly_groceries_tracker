// lib/screens/add_edit_item/mixins/delete_mixin.dart
import 'package:flutter/material.dart';
import '../../../providers/items_provider.dart';
import '../add_edit_item_state.dart';
import 'package:go_router/go_router.dart';

mixin DeleteMixin on AddEditItemState {
  bool _deleting = false;

  static const String _dialogTitle = 'حذف المادة';
  static const String _dialogContentPrefix = 'هل أنت متأكد من حذف "';
  static const String _dialogContentSuffix =
      '"؟ سيتم حذفها أيضًا من قائمة الشراء إن كانت مضافة هناك. لا يمكن التراجع عن هذا الإجراء.';
  static const String _cancelButtonLabel = 'إلغاء';
  static const String _deleteButtonLabel = 'حذف';
  static const String _deleteError = 'تعذّر حذف المادة، يرجى المحاولة مرة أخرى';

  Future<void> delete() async {
    if (_deleting) return;

    final itemName = widget.item!.name;
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(_dialogTitle),
        content: Text('$_dialogContentPrefix$itemName$_dialogContentSuffix'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(_cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text(_deleteButtonLabel),
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
            content: Text(_deleteError, style: TextStyle(color: theme.colorScheme.onError)),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }
}