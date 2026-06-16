// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';

import 'providers/items_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/workmanager_service.dart';
import 'theme/app_theme.dart';

const _batteryChannel = MethodChannel('battery_optimization');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  await NotificationService.init();
  await WorkmanagerService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storage),
      ],
      child: const HomeReminderApp(),
    ),
  );
}

class HomeReminderApp extends StatelessWidget {
  const HomeReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابعة طلبات البيت',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeScreen(),
    );
  }
}

// ─── Battery optimisation helpers ────────────────────────────────────────────

Future<bool> _isIgnoringBatteryOptimizations() async {
  try {
    final bool? result =
        await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
    return result ?? false;
  } catch (_) {
    // On iOS or if the channel is unavailable, assume unrestricted.
    return false;
  }
}

Future<void> requestBatteryOptimizationExemption(BuildContext context) async {
  if (!context.mounted) return;

  if (await _isIgnoringBatteryOptimizations()) return;

  final prefs = await SharedPreferences.getInstance();
  final alreadyShown = prefs.getBool('battery_prompt_shown') ?? false;
  if (alreadyShown) return;

  // Guard after the async gap.
  if (!context.mounted) return;

  final shouldProceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('تفعيل الاشعارات في الخلفية'),
      content: const Text(
        'نريد أن تصلك التنبيهات في الوقت الصحيح دائمًا، حتى لو كان التطبيق مغلقًا.\n\n'
        'بعض الأجهزة قد تقوم بتقييد التطبيقات لتوفير البطارية، وهذا قد يؤثر على ظهور الإشعارات.\n\n'
        'يمكنك السماح للتطبيق بالعمل بحرية من إعدادات الجهاز.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('ليس الآن'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('فتح الإعدادات'),
        ),
      ],
    ),
  );

  if (shouldProceed == true) {
    // Guard again after the dialog async gap.
    if (!context.mounted) return;

    await prefs.setBool('battery_prompt_shown', true);
    try {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
        data: 'package:com.home_orders_tracker.app',
      );
      await intent.launch();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لضمان ظهور الاشعارات التذكيرية يرجى الذهاب إلى الإعدادات > التطبيقات > تطبيقنا > البطارية > السماح بالتشغيل في الخلفية',
            ),
          ),
        );
      }
    }
  }
}
