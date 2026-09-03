// lib/main.dart

import 'dart:async';
import 'package:baly_groceries_tracker/providers/app_state_provider.dart';
import 'package:baly_groceries_tracker/providers/items_provider.dart';
import 'package:baly_groceries_tracker/providers/locale_provider.dart';
import 'package:baly_groceries_tracker/providers/storage_service_provider.dart';
import 'package:baly_groceries_tracker/services/battery_service.dart';
import 'package:baly_groceries_tracker/services/workmanager_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:baly_groceries_tracker/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final storage = StorageService();
  await storage.init();

  final appState = AppStateNotifier(prefs);

  await NotificationService.init();
  await WorkmanagerService.init();
  unawaited(
    storage.runLogRetentionCleanup().catchError((e, st) {
      debugPrint('Log retention cleanup failed: $e');
      return 0;
    }),
  );
  unawaited(BatteryService.initFirstLaunchDate(prefs));

  AppTheme.applySystemUI();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        appStateNotifierProvider.overrideWithValue(appState),
      ],
      child: const BalyGroceriesTrackerApp(),
    ),
  );
}

class BalyGroceriesTrackerApp extends ConsumerStatefulWidget {
  const BalyGroceriesTrackerApp({super.key});

  @override
  ConsumerState<BalyGroceriesTrackerApp> createState() => _BalyGroceriesTrackerAppState();
}

class _BalyGroceriesTrackerAppState extends ConsumerState<BalyGroceriesTrackerApp>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(itemsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Baly Groceries Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
