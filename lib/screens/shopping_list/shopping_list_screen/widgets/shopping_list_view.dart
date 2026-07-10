// lib/screens/shopping_list/shopping_list_screen/widgets/shopping_list_view.dart

import 'package:flutter/material.dart';

import '../../../../models/shopping_item_model.dart';
import '../../../../core/widgets/shopping_item_card.dart';
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
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item.id;

              // Wrap the first item in the peek-animation widget when applicable.
              final bool shouldPeek =
                  showPeekAnimation && index == 0 && !isInSelectionMode;

              final card = Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ShoppingItemCard(
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
                ),
              );

              if (shouldPeek) {
                return _PeekAnimatedItem(key: const ValueKey('peek_item'), child: card);
              }
              return card;
            },
          ),
        ),
        ShoppingListTotalBar(total: total),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Peek animation widget
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps its [child] and plays a one-shot "peek" slide animation:
///   1. Slides right → ~12 % of screen width (200 ms, easeOut)
///   2. Holds for 400 ms
///   3. Slides back to 0 (250 ms, easeIn)
///
/// The animation fires once in [initState] and never repeats for the
/// lifetime of this widget instance.
class _PeekAnimatedItem extends StatefulWidget {
  const _PeekAnimatedItem({super.key, required this.child});

  final Widget child;

  @override
  State<_PeekAnimatedItem> createState() => _PeekAnimatedItemState();
}

class _PeekAnimatedItemState extends State<_PeekAnimatedItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // How far the card slides as a fraction of screen width.
  static const double _peekFraction = 0.12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    // Kick off the animation after the first frame so the card is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPeekSequence());
  }

  Future<void> _runPeekSequence() async {
    if (!mounted) return;

    // 1. Slide right.
    await _controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );

    if (!mounted) return;

    // 2. Hold.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    // 3. Slide back.
    await _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeIn,
    );
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_controller.value * peekOffset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
