// lib/services/battery_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import '../../../core/utils/context_extensions.dart';

class BatteryService {
  BatteryService._();

  static const _batteryChannel =
      MethodChannel('com.home_orders_tracker.app/battery_optimization');

  static const _lastPromptKey = 'battery_prompt_last_shown';
  static const _firstLaunchKey = 'app_first_launch_date';

  static const _initialDelayDays = 3;
  static const _reminderDays = 7;

  /// يسجل تاريخ أول إطلاق للتطبيق (يجب استدعاؤها في main.dart)
  static Future<void> initFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_firstLaunchKey) == null) {
      await prefs.setInt(_firstLaunchKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result = await _batteryChannel
          .invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return true; // iOS or unavailable
    }
  }

  /// يقرر ما إذا كان يجب عرض الحوار أم لا
  static Future<bool> shouldShowBatteryPrompt() async {
    if (await isIgnoringBatteryOptimizations()) return false;

    final prefs = await SharedPreferences.getInstance();
    final int? firstLaunchMillis = prefs.getInt(_firstLaunchKey);
    if (firstLaunchMillis == null) return false; // لم يتم التهيئة بعد

    final int daysSinceFirstLaunch = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(firstLaunchMillis))
        .inDays;

    if (daysSinceFirstLaunch < _initialDelayDays) return false;

    final int? lastPromptMillis = prefs.getInt(_lastPromptKey);
    if (lastPromptMillis != null) {
      final int daysPassed = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(lastPromptMillis))
          .inDays;
      if (daysPassed < _reminderDays) return false;
    }

    return true;
  }

  /// يسجل أن الحوار قد ظهر اليوم
  static Future<void> markPromptAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// يحاول فتح إعدادات البطارية ويعيد true إذا نجح
  static Future<bool> openBatterySettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
      return true;
    } catch (e) {
      try {
        // خطة B
        await AppSettings.openAppSettings();
        return true;
      } catch (_) {
        return false;
      }
    }
  }
}


Future<void> checkAndShowBatteryDialog(BuildContext context) async {
  // 1. نسأل الـ Service هل يجب عرض الحوار؟
  final shouldShow = await BatteryService.shouldShowBatteryPrompt();
  if (!shouldShow || !context.mounted) return;

  final cs = Theme.of(context).colorScheme;

  // 2. نعرض الحوار
  final shouldProceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: cs.outlineVariant, width: 1),
      ),
      title: Text(
        ctx.loc.batteryDialogTitle, // تم استخدام ctx بدلاً من context
        style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
      ),
      content: Text(
        ctx.loc.batteryDialogContent,
        style: TextStyle(color: cs.onSurface, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: cs.primary),
          child: Text(ctx.loc.batteryDialogNotNow),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ctx.loc.batteryDialogOpenSettings),
        ),
      ],
    ),
  );

  // 3. نسجل تاريخ اليوم (سواء وافق أو رفض)
  await BatteryService.markPromptAsShown();

  if (shouldProceed != true || !context.mounted) return;

  // 4. نحاول فتح الإعدادات
  final success = await BatteryService.openBatterySettings();
  
  if (!success && context.mounted) {
    // 5. خطة C: إظهار خطأ إذا فشل فتح الإعدادات
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
          backgroundColor: cs.errorContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          content: Text(
            context.loc.batterySnackBarError,
            style: TextStyle(color: cs.onErrorContainer),
          ),
          action: SnackBarAction(
            label: context.loc.batterySnackBarRetry,
            textColor: cs.onErrorContainer,
            onPressed: () async {
              await BatteryService.openBatterySettings();
            },
          ),
        ),
      );
  }
}