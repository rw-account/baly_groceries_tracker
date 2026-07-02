// lib/services/battery_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';

class BatteryService {
  BatteryService._(); // Prevents instantiation of this class.

  static const _batteryChannel =
      MethodChannel('com.home_orders_tracker.app/battery_optimization');
      
  // مفاتيح التخزين
  static const _lastPromptKey = 'battery_prompt_last_shown';
  static const _firstLaunchKey = 'app_first_launch_date';
  
  // فترات الانتظار بالأيام
  static const _initialDelayDays = 3; // ننتظر 3 أيام قبل أول ظهور للحوار
  static const _reminderDays = 7; // نذكره كل 7 أيام إذا رفض

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result =
          await _batteryChannel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      // On iOS or if the channel is unavailable, assume unrestricted.
      return true;
    }
  }

  static Future<void> requestBatteryOptimizationExemption(BuildContext context) async {
    if (!context.mounted) return;

    // 1. التحقق من الحالة الحقيقية للجهاز
    if (await isIgnoringBatteryOptimizations()) return;

    final prefs = await SharedPreferences.getInstance();

    // 2. تسجيل تاريخ أول إطلاق للتطبيق (إذا لم يكن مسجلاً)
    int? firstLaunchMillis = prefs.getInt(_firstLaunchKey);
    if (firstLaunchMillis == null) {
      firstLaunchMillis = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_firstLaunchKey, firstLaunchMillis);
    }

    final DateTime firstLaunchDate = 
        DateTime.fromMillisecondsSinceEpoch(firstLaunchMillis);
    final int daysSinceFirstLaunch = DateTime.now().difference(firstLaunchDate).inDays;

    // 3. إذا لم تمر 3 أيام على تثبيت التطبيق، لا تعرض الحوار إطلاقاً
    if (daysSinceFirstLaunch < _initialDelayDays) {
      return; 
    }

    // 4. التحقق من تاريخ آخر ظهور للحوار (نظام التذكير كل 7 أيام)
    final int? lastPromptMillis = prefs.getInt(_lastPromptKey);
    
    if (lastPromptMillis != null) {
      final DateTime lastPromptDate = 
          DateTime.fromMillisecondsSinceEpoch(lastPromptMillis);
      final int daysPassed = DateTime.now().difference(lastPromptDate).inDays;
      
      // إذا لم تمر 7 أيام منذ آخر تذكير، لا نعرض الحوار
      if (daysPassed < _reminderDays) {
        return; 
      }
    }

    // Guard after the async gap.
    if (!context.mounted) return;

    // 5. نعرض الحوار
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

    // 6. نسجل تاريخ اليوم لكي نعيد الكرة بعد 7 أيام
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);

    if (shouldProceed == true) {
      if (!context.mounted) return;

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