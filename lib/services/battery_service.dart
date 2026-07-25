// lib/services/battery_service.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';
import '../../../core/utils/context_extensions.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Business Logic: Battery Service
// ─────────────────────────────────────────────────────────────────────────────

class BatteryService {
  BatteryService._();

  static const MethodChannel _batteryChannel =
      MethodChannel('com.home_orders_tracker.app/battery_optimization');

  // SharedPreferences Keys
  static const String _lastPromptKey = 'battery_prompt_last_shown';
  static const String _firstLaunchKey = 'app_first_launch_date';

  // Timing Constraints
  static const int _initialDelayDays = 3;
  static const int _reminderDays = 7;

  /// Registers the first launch date of the app (should be called in main.dart).
  static Future<void> initFirstLaunchDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_firstLaunchKey)) {
        await prefs.setInt(
          _firstLaunchKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      debugPrint('Failed to initialize first launch date: $e');
    }
  }

  /// Checks if the app is exempt from battery optimizations.
  /// Returns true on iOS or unsupported platforms to avoid unnecessary prompts.
  static Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result = await _batteryChannel
          .invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return true; // Assume true for iOS or unavailable platforms
    }
  }

  /// Determines if the battery optimization prompt should be shown to the user.
  static Future<bool> shouldShowBatteryPrompt() async {
    if (await isIgnoringBatteryOptimizations()) return false;

    final prefs = await SharedPreferences.getInstance();
    final int? firstLaunchMillis = prefs.getInt(_firstLaunchKey);
    if (firstLaunchMillis == null) return false; // Not initialized yet

    final DateTime now = DateTime.now();
    final DateTime firstLaunchDate = DateTime.fromMillisecondsSinceEpoch(firstLaunchMillis);
    final int daysSinceFirstLaunch = now.difference(firstLaunchDate).inDays;

    if (daysSinceFirstLaunch < _initialDelayDays) return false;

    final int? lastPromptMillis = prefs.getInt(_lastPromptKey);
    if (lastPromptMillis != null) {
      final DateTime lastPromptDate = DateTime.fromMillisecondsSinceEpoch(lastPromptMillis);
      final int daysSinceLastPrompt = now.difference(lastPromptDate).inDays;
      
      if (daysSinceLastPrompt < _reminderDays) return false;
    }

    return true;
  }

  /// Records that the prompt was shown today.
  static Future<void> markPromptAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Attempts to open the battery optimization settings.
  /// Returns true if successful, false otherwise.
  static Future<bool> openBatterySettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
      return true;
    } catch (e) {
      debugPrint('Failed to open specific battery settings: $e');
      try {
        // Fallback: Open general app settings
        await AppSettings.openAppSettings();
        return true;
      } catch (e) {
        debugPrint('Failed to open general app settings: $e');
        return false;
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI Orchestration: Battery Dialog
// ─────────────────────────────────────────────────────────────────────────────

/// Checks conditions and displays the battery optimization dialog if needed.
Future<void> checkAndShowBatteryDialog(BuildContext context) async {
  // 1. Check if the prompt should be shown via the service
  final bool shouldShow = await BatteryService.shouldShowBatteryPrompt();
  if (!shouldShow || !context.mounted) return;

  // 2. Show the dialog and wait for user response
  final bool? shouldProceed = await _showBatteryDialog(context);

  // 3. Mark the prompt as shown regardless of the user's choice
  await BatteryService.markPromptAsShown();

  if (shouldProceed != true || !context.mounted) return;

  // 4. Attempt to open settings
  final bool success = await BatteryService.openBatterySettings();
  
  // 5. Show error fallback if opening settings failed
  if (!success && context.mounted) {
    _showErrorSnackBar(context);
  }
}

/// Builds and shows the battery optimization AlertDialog.
Future<bool?> _showBatteryDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog.adaptive(
      title: Text(ctx.loc.batteryDialogTitle),
      content: Text(ctx.loc.batteryDialogContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(ctx.loc.batteryDialogNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            minimumSize: const Size(80, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: Text(ctx.loc.batteryDialogOpenSettings),
        ),
      ],
    ),
  );
}

/// Shows a SnackBar indicating that opening settings failed, with a retry action.
void _showErrorSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 10),
        content: Text(context.loc.batterySnackBarError),
        action: SnackBarAction(
          label: context.loc.batterySnackBarRetry,
          onPressed: () => BatteryService.openBatterySettings(),
        ),
      ),
    );
}