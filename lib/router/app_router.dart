// lib/router/app_router.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_orders_tracker/providers/app_state_provider.dart';

import '../screens/home/home_screen.dart';
import '../screens/expiry/expiry_screen.dart';
import '../screens/shopping_list/shopping_list_screen/shopping_list_screen.dart';
import '../screens/add_edit_item/add_edit_item_screen.dart';
import '../screens/shopping_list/add_shopping_item_screen/add_shopping_item_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/language_selection_screen.dart';
import '../models/item_model.dart';
import '../screens/item_history/item_history_screen.dart';

import 'route_paths.dart';
import 'router_keys.dart';
import 'page_transitions.dart';
import 'error_screen.dart';
import 'item_loader_screen.dart';
import 'scaffold_with_nav_bar.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appStateNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.home,
    errorBuilder: (context, state) => ErrorScreen.unknownRoute(context),

    // Automatically re-runs redirect when AppStateNotifier changes.
    refreshListenable: appState,
    redirect: (context, state) {
      final isOnboardingCompleted = appState.onboardingCompleted;
      final hasLanguageSelected = appState.hasLanguageSelected;
      
      final isOnboardingRoute = state.matchedLocation == RoutePaths.onboarding;
      final isLanguageSelectionRoute = state.matchedLocation == RoutePaths.languageSelection;
      
      if (!hasLanguageSelected && !isLanguageSelectionRoute) {
        return RoutePaths.languageSelection;
      }
      
      if (hasLanguageSelected && !isOnboardingCompleted && !isOnboardingRoute && !isLanguageSelectionRoute) {
        return RoutePaths.onboarding;
      }
      
      if (isOnboardingCompleted && (isOnboardingRoute || isLanguageSelectionRoute)) {
        return RoutePaths.home;
      }
      
      return null;
    },
  routes: [
    // Language Selection & Onboarding (shown before main app)
    GoRoute(
      path: RoutePaths.languageSelection,
      pageBuilder: (context, state) => buildSlideFadeTransitionPage(
        context: context,
        state: state,
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.onboarding,
      pageBuilder: (context, state) => buildSlideFadeTransitionPage(
        context: context,
        state: state,
        child: const OnboardingScreen(),
      ),
    ),
    // Main App with Bottom Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Home branch
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
                        child: ErrorScreen.itemNotFound(context),
                      );
                    }

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
                  routes: [
                    GoRoute(
                      path: RoutePaths.itemHistory,
                      pageBuilder: (context, state) {
                        final itemId = state.pathParameters['itemId'] ?? '';
                        return buildSlideFadeTransitionPage(
                          context: context,
                          state: state,
                          child: ItemHistoryScreen(itemId: itemId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Expiry branch
        StatefulShellBranch(
          navigatorKey: expiryBranchNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.expiry,
              builder: (context, state) => const ExpiryScreen(),
            ),
          ],
        ),

        // Shopping List branch
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
    // Settings route
    GoRoute(
      path: RoutePaths.settings,
      pageBuilder: (context, state) => buildSlideFadeTransitionPage(
        context: context,
        state: state,
        child: const SettingsScreen(),
      ),
    ),
  ],
);
});