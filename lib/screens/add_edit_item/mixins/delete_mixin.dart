// lib/screens/add_edit_item/mixins/delete_mixin.dart
import 'package:flutter/material.dart';
import '../../../providers/items_provider.dart';
import '../add_edit_item_state.dart';
import 'package:go_router/go_router.dart';

/// Handles the deletion of an [ItemModel] with confirmation.
///
/// Mix this into [AddEditItemState] to gain safe, user-friendly
/// delete functionality that prevents accidental double-taps and
/// shows clear error feedback.
mixin DeleteMixin on AddEditItemState {
  bool _deleting = false;

  // ---------- User-facing messages ----------
  static const String _dialogTitle = 'حذف المادة';
  static const String _dialogContentPrefix = 'هل أنت متأكد من حذف "';
  static const String _dialogContentSuffix = '"؟ لا يمكن التراجع عن هذا الإجراء.';
  static const String _cancelButtonLabel = 'إلغاء';
  static const String _deleteButtonLabel = 'حذف';
  static const String _deleteError = 'تعذّر حذف المادة، يرجى المحاولة مرة أخرى';

  // ---------- Public entry point ----------
  Future<void> delete() async {
    // 1. Guard against concurrent delete operations.
    if (_deleting) return;

    final itemName = widget.item!.name;

    // 2. Ask for explicit confirmation (dialog is modal, no outside dismiss).
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(_deleteButtonLabel),
          ),
        ],
      ),
    );

    // 3. If user cancelled or widget no longer mounted, stop.
    if (confirmed != true || !mounted) return;

    // 4. Mark deleting to block double-taps, then execute.
    setState(() => _deleting = true);

    try {
      await ref.read(itemsProvider.notifier).deleteItem(widget.item!.id);

      // 5. On success, return to the previous screen.
      if (mounted) context.pop();
    } catch (_) {
      // 6. On failure, show a snackbar and stay on the current screen.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_deleteError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 7. Always release the deleting lock.
      if (mounted) setState(() => _deleting = false);
    }
  }
}