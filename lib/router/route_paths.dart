// lib/router/route_paths.dart

/// Centralized app routes for easy maintenance and avoiding typos
/// when referencing the same route from multiple places.
abstract class RoutePaths {
  RoutePaths._();

  // Main branch routes (bottom navigation tabs)
  static const String home = '/home';
  static const String expiry = '/expiry';
  static const String shoppingList = '/shopping-list';
  static const String settings = '/settings';

  // Onboarding & Language Selection
  static const String languageSelection = '/language-selection';
  static const String onboarding = '/onboarding';

  // Sub-routes (relative to parent branch)
  static const String addItem = 'add-item';
  static const String editItem = 'edit-item/:itemId';
  static const String addShoppingItem = 'add-item';

  // Full paths (useful when calling context.go / context.push)
  static const String addItemFull = '/home/add-item';
  static const String addShoppingItemFull = '/shopping-list/add-item';

  /// Builds the full path for editing a specific item by its ID,
  /// used for deep links and internal navigation.
  static String editItemPath(String itemId) => '/home/edit-item/$itemId';
}
