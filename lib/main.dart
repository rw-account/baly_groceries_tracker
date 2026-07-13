// lib/main.dart

import 'package:home_orders_tracker/providers/locale_provider.dart';
import 'providers/items_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_orders_tracker/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart'; 
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  await NotificationService.init();
  await WorkmanagerService.init();

  AppTheme.applySystemUI(); 
  
  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const HomeOrdersTrackerApp(),
    ),
  );
}

class HomeOrdersTrackerApp extends ConsumerWidget {
  const HomeOrdersTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(localeProvider);
    
    return localeAsync.when(
        data: (locale) => MaterialApp.router(
          title: 'Home Orders Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          
          locale: locale,
          
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          routerConfig: appRouter,
        ),
        loading: () => const MaterialApp(
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        ),
        error: (error, stack) => MaterialApp(
          home: Scaffold(body: Center(child: Text('Error loading locale: $error'))),
        ),
      );
  }
}
