// lib/models/shopping_item_model.dart

class ShoppingItem {
  final int? id; // null عند الإنشاء قبل الحفظ في قاعدة البيانات (AUTOINCREMENT)
  final String title;
  final int? inventoryItemId; // مرتبط بعنصر في المخزون (items.id) إذا لم يكن null
  final bool isChecked;
  final double? price; // السعر لكل وحدة من العنصر (اختياري)
  final DateTime createdAt;

  ShoppingItem({
    this.id,
    required this.title,
    this.inventoryItemId,
    this.isChecked = false,
    this.price,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ShoppingItem copyWith({
    int? id,
    String? title,
    int? inventoryItemId,
    bool? isChecked,
    double? price,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      isChecked: isChecked ?? this.isChecked,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'inventory_item_id': inventoryItemId,
      'is_checked': isChecked ? 1 : 0,
      'price': price,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ShoppingItem.fromMap(Map<String, Object?> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      inventoryItemId: map['inventory_item_id'] as int?,
      isChecked: (map['is_checked'] as int) == 1,
      price: (map['price'] as num?)?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  @override
  String toString() =>
      'ShoppingItem(id: $id, title: $title, inventoryItemId: $inventoryItemId, '
      'isChecked: $isChecked, price: $price, createdAt: $createdAt)';
}