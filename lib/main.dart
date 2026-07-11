// lib/main.dart

import 'providers/items_provider.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_orders_tracker/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart'; 
import 'router/app_router.dart';
import 'package:home_orders_tracker/router/error_screen.dart';

Future<void> main() async {
  installGlobalErrorHandling(); 
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

class HomeOrdersTrackerApp extends StatelessWidget {
  const HomeOrdersTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Home Orders Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      
      // 🌟 تحديد اللغة العربية كلغة افتراضية حالياً
      locale: const Locale('ar'),
      
      // 🌟 الطريقة الحديثة والمختصرة لتسجيل اللغات والمندوبين
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      routerConfig: appRouter,
    );
  }
}
