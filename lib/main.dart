// lib/main.dart

import 'dart:async';
import 'package:home_orders_tracker/providers/app_state_provider.dart';
import 'package:home_orders_tracker/providers/locale_provider.dart';
import 'package:home_orders_tracker/providers/storage_service_provider.dart';
import 'package:home_orders_tracker/services/battery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_orders_tracker/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart'; 
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final storage = StorageService();
  await storage.init();

  final appState = AppStateNotifier(prefs);

  await NotificationService.init();
  unawaited(BatteryService.initFirstLaunchDate());

  AppTheme.applySystemUI(); 
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
        appStateNotifierProvider.overrideWithValue(appState),
      ],
      child: const HomeOrdersTrackerApp(),
    ),
  );
}

class HomeOrdersTrackerApp extends ConsumerWidget {
  const HomeOrdersTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp.router(
          title: 'Home Orders Tracker',
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
