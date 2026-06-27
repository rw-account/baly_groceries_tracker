// lib/router/app_router.dart

import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/expiry/expiry_screen.dart';
import '../screens/shopping_list/shopping_list_screen/shopping_list_screen.dart';
import '../screens/add_edit_item/add_edit_item_screen.dart';
import '../screens/shopping_list/add_shopping_item_screen/add_shopping_item_screen.dart';
import '../models/item_model.dart';

import 'route_paths.dart';
import 'router_keys.dart';
import 'page_transitions.dart';
import 'error_screen.dart';
import 'item_loader_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// Central routing configuration for the application.
///
/// Key design decisions:
///
/// - Each StatefulShellBranch uses its own GlobalKey`<NavigatorState>`
///   (see router_keys.dart) to ensure independent navigation stacks.
///   This prevents state loss when switching between tabs.
///
/// - Item editing flow supports deep linking:
///   when navigating via a route containing `itemId`, the item is loaded
///   using Riverpod inside item_loader_screen.dart instead of relying only
///   on `extra` (which is available only during in-app navigation).
///
/// - Unknown or invalid routes are gracefully handled by displaying
///   ErrorScreen.unknownRoute() instead of allowing the app to crash or
///   fall back to a blank/default screen.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: RoutePaths.home,
  errorBuilder: (context, state) => ErrorScreen.unknownRoute(),
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // ── فرع الرئيسية ─────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: homeBranchNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.home,
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: RoutePaths.addItem,
                  pageBuilder: (context, state) => buildSlideFadeTransitionPage(
                    context: context,
                    state: state,
                    child: const AddEditItemScreen(),
                  ),
                ),
                GoRoute(
                  path: RoutePaths.editItem,
                  pageBuilder: (context, state) {
                    final itemId = state.pathParameters['itemId'];

                    if (itemId == null || itemId.trim().isEmpty) {
                      return buildSlideFadeTransitionPage(
                        context: context,
                        state: state,
                        child: ErrorScreen.itemNotFound(),
                      );
                    }

                    // إن جاء extra من تنقّل داخلي عادي يُستخدم مباشرة
                    // (أسرع، بلا أي حالة تحميل)، وإلا فهذا رابط عميق
                    // ويتم جلب العنصر داخل ItemLoaderScreen عبر itemId.
                    final extraItem =
                        state.extra is ItemModel ? state.extra as ItemModel : null;

                    return buildSlideFadeTransitionPage(
                      context: context,
                      state: state,
                      child: ItemLoaderScreen(
                        itemId: itemId,
                        extraItem: extraItem,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        // ── فرع النفاد ───────────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: expiryBranchNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.expiry,
              builder: (context, state) => const ExpiryScreen(),
            ),
          ],
        ),

        // ── فرع قائمة التسوق ─────────────────────────────────────────
        StatefulShellBranch(
          navigatorKey: shoppingListBranchNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.shoppingList,
              builder: (context, state) => const ShoppingListScreen(),
              routes: [
                GoRoute(
                  path: RoutePaths.addShoppingItem,
                  pageBuilder: (context, state) => buildSlideFadeTransitionPage(
                    context: context,
                    state: state,
                    child: const AddShoppingItemScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
