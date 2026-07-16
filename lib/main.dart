// lib/main.dart

import 'package:home_orders_tracker/providers/locale_provider.dart';
import 'package:home_orders_tracker/services/battery_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final prefs = await SharedPreferences.getInstance();
  LocaleNotifier.currentLanguage = prefs.getString('language_code') ?? 'ar';
  await  BatteryService.initFirstLaunchDate();

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
        loading: () => MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.dark.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: AppTheme.dark.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.dark.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        error: (error, stack) => MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: AppTheme.dark.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading locale',
                      style: AppTheme.dark.textTheme.titleMedium?.copyWith(
                        color: AppTheme.dark.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: AppTheme.dark.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.dark.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(localeProvider),
                      icon: const Icon(Icons.refresh_outlined),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}
