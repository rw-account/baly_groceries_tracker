// lib/screens/expiry/widgets/expiry_item_tile.dart

import 'package:flutter/material.dart';

import '../../../models/item_model.dart';
import 'expiry_remaining_label.dart';

/// بطاقة عرض عنصر واحد ضمن شاشة العناصر على وشك النفاد، مع شريط جانبي
/// ملوّن يدل على درجة الخطورة، وزر لإضافة العنصر إلى قائمة الشراء.
///
/// الودجت بلا حالة داخلية (Stateless): كل ما يخص "هل هو قيد الإضافة؟"
/// أو "هل هو موجود بالقائمة؟" يُمرَّر من الشاشة الأم، مما يجعل هذه
/// البطاقة سهلة إعادة الاستخدام والاختبار بمعزل عن باقي الشاشة.
class ExpiryItemTile extends StatelessWidget {
  const ExpiryItemTile({
    super.key,
    required this.item,
    required this.color,
    required this.isInShoppingList,
    required this.isAdding,
    required this.onAddToShoppingList,
  });

  final ItemModel item;
  final Color color;
  final bool isInShoppingList;
  final bool isAdding;
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
            // يظهر هذا الشريط على يمين البطاقة تلقائياً بفضل اتجاه
            // الواجهة RTL المعتمد في التطبيق.
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
      onPressed: onAddToShoppingList,
    );
  }
}
