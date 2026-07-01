// lib/services/battery_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';

class BatteryService {
  BatteryService._(); // Prevents instantiation of this class.

  static const _batteryChannel =
      MethodChannel('com.home_orders_tracker.app/battery_optimization');

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result =
          await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      // On iOS or if the channel is unavailable, assume unrestricted.
      return false;
    }
  }

  static Future<void> requestBatteryOptimizationExemption(BuildContext context) async {
    if (!context.mounted) return;

    // 1. إن كان معفيًا بالفعل، لا حاجة لأي حوار
    if (await isIgnoringBatteryOptimizations()) return;

    final prefs = await SharedPreferences.getInstance();

    // 2. عداد مرات فتح التطبيق
    const String openCountKey = 'app_open_count';
    int openCount = prefs.getInt(openCountKey) ?? 0;

    // إذا لم نصل للعدد المطلوب (3 مرات)، نزيد العداد ونخرج
    if (openCount < 3) {
      await prefs.setInt(openCountKey, openCount + 1);
      return;
    }

    // 3. إن عُرض الحوار مرة سابقة فلا نكرره
    final alreadyShown = prefs.getBool('battery_prompt_shown') ?? false;
    if (alreadyShown) return;

    // Guard after the async gap.
    if (!context.mounted) return;

    // 4. نعرض الحوار
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
          action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
        );
        await intent.launch();
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 15),
              backgroundColor: Colors.red,
              content: Text(
                'تعذر فتح الإعدادات تلقائيًا. لضمان ظهور الاشعارات التذكيرية يرجى الذهاب إلى الإعدادات > التطبيقات > تطبيقنا > البطارية > السماح بالتشغيل في الخلفية',
              ),
            ),
          );
        }
      }
    }
  }
}
