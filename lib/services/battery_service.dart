// lib/services/battery_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';


class BatteryService {
  BatteryService._(); // Prevents instantiation of this class.

  static const _batteryChannel = MethodChannel('com.home_orders_tracker.app/battery_optimization');

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

    if (await isIgnoringBatteryOptimizations()) return;

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
}
