// lib/screens/shopping_list/shopping_list_screen/widgets/shopping_list_view.dart

import 'package:flutter/material.dart';

import '../../../../models/shopping_item_model.dart';
import '../../../../core/widgets/shopping_item_card.dart';
import '../../../../core/widgets/delete_background.dart';
import 'shopping_list_total_bar.dart';

/// Renders the list of shopping items plus the running total bar.
/// Supports multi-select mode and an optional "peek" swipe-hint animation
/// for the first item.
class ShoppingListView extends StatelessWidget {
  const ShoppingListView({
    super.key,
    required this.items,
    required this.onDelete,
    // Selection-mode params
    required this.isInSelectionMode,
    required this.selectedIds,
    required this.onItemLongPress,
    required this.onItemTap,
    // Peek-animation params
    this.showPeekAnimation = false,
    this.onSwipeCompleted,
  });

  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onDelete;

  final bool isInSelectionMode;
  final Set<int> selectedIds;
  final void Function(int id) onItemLongPress;
  final void Function(int id) onItemTap;

  /// When true, the first item will play the peek/swipe-hint animation.
  final bool showPeekAnimation;

  /// Called when any item is successfully swiped to delete — used to mark
  /// the swipe-hint as seen so the animation stops on future screen opens.
  final VoidCallback? onSwipeCompleted;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.price ?? 0),
    );

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item.id;

              // Wrap the first item in the peek-animation widget when applicable.
              final bool shouldPeek =
                  showPeekAnimation && index == 0 && !isInSelectionMode;

              final itemContent = ShoppingItemCard(
                key: ValueKey('shopping_card_${item.id ?? item.title}'),
                item: item,
                onDelete: (deletedItem) {
                  // Mark the hint as seen the first time any item is swiped.
                  onSwipeCompleted?.call();
                  onDelete(deletedItem);
                },
                isInSelectionMode: isInSelectionMode,
                isSelected: id != null && selectedIds.contains(id),
                onLongPress:
                    id != null ? () => onItemLongPress(id) : null,
                onSelectionTap:
                    id != null ? () => onItemTap(id) : null,
              );

              final wrapped = shouldPeek
                  ? _PeekAnimatedItem(
                      key: const ValueKey('peek_item'),
                      child: itemContent,
                    )
                  : itemContent;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: wrapped,
              );
            },
          ),
        ),
        ShoppingListTotalBar(total: total),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Peek animation widget (shows the red delete background correctly)
// ─────────────────────────────────────────────────────────────────────────────
class _PeekAnimatedItem extends StatefulWidget {
  const _PeekAnimatedItem({super.key, required this.child});

  final Widget child;

  @override
  State<_PeekAnimatedItem> createState() => _PeekAnimatedItemState();
}

class _PeekAnimatedItemState extends State<_PeekAnimatedItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const double _peekFraction = 0.12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPeekSequence());
  }

  Future<void> _runPeekSequence() async {
      if (!mounted) return;
      await _controller.animateTo(1.0,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
          
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      
      if (!mounted) return;
      await _controller.animateBack(0.0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
    }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final peekOffset = screenWidth * _peekFraction;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final showBackground = _controller.value > 0.0;
              return Opacity(
                opacity: showBackground ? 1.0 : 0.0,
                child: DeleteBackground(alignment: AlignmentDirectional.centerStart),
              );
            },
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(isRtl ? -_controller.value * peekOffset : _controller.value * peekOffset, 0),
              child: child,
            );
          },
          child: widget.child,
        ),
      ],
    );
  }
}