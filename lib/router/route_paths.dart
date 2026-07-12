// lib/router/route_paths.dart

/// مسارات التطبيق المركزية، لتسهيل الصيانة وتفادي الأخطاء الإملائية
/// عند الإشارة إلى نفس المسار من أكثر من مكان.
abstract class RoutePaths {
  RoutePaths._();

  // الفروع الرئيسية (تبويبات الشريط السفلي)
  static const String home = '/home';
  static const String expiry = '/expiry';
  static const String shoppingList = '/shopping-list';
  static const String settings = '/settings';

  // المسارات الفرعية (نسبية إلى الفرع الأب)
  static const String addItem = 'add-item';
  static const String editItem = 'edit-item/:itemId';
  static const String addShoppingItem = 'add-item';

  // المسارات الكاملة (مفيدة عند استدعاء context.go / context.push)
  static const String addItemFull = '/home/add-item';
  static const String addShoppingItemFull = '/shopping-list/add-item';

  /// يبني المسار الكامل لتعديل عنصر معيّن انطلاقًا من معرفه،
  /// ويُستخدم في الروابط العميقة (deep links) والتنقّل الداخلي.
  static String editItemPath(String itemId) => '/home/edit-item/$itemId';
}
