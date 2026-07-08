// lib/screens/expiry/widgets/expiry_item_tile.dart

import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import 'expiry_remaining_label.dart';

class ExpiryItemTile extends StatelessWidget {
  const ExpiryItemTile({
    super.key,
    required this.item,
    required this.color,
    required this.isInShoppingList,
    required this.isAdding,
    required this.isAddingAll, // <-- أضف هذا
    required this.onAddToShoppingList,
  });

  final ItemModel item;
  final Color color;
  final bool isInShoppingList;
  final bool isAdding;
  final bool isAddingAll; // <-- أضف هذا
  final VoidCallback onAddToShoppingList;

  static const double _stripeWidth = 5;
  static const double _stripeHeight = 66;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Row(
          children: [
            Container(width: _stripeWidth, height: _stripeHeight, color: color),
            Expanded(
              child: ListTile(
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: ExpiryRemainingLabel(item: item),
                trailing: _buildTrailing(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (isAdding) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (isInShoppingList) {
      return Chip(
        label: const Text('في القائمة'),
        avatar: const Icon(Icons.check, size: 18),
        backgroundColor: Colors.grey.shade100,
      );
    }

    return IconButton(
      icon: const Icon(Icons.add_shopping_cart),
      tooltip: 'إضافة إلى قائمة الشراء',
      // <-- تعطيل الزر إذا كان يتم إضافة الكل حالياً
      onPressed: isAddingAll ? null : onAddToShoppingList, 
    );
  }
}