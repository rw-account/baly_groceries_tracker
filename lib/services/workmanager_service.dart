// lib/services/workmanager_service.dart

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'storage_service.dart';

const String dailyTask = 'daily_notification_task';

// SharedPreferences Keys
const String kNotificationHourKey = 'notification_hour';
const String kNotificationMinuteKey = 'notification_minute';
const int kDefaultHour = 5; 
const int kDefaultMinute = 0;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await NotificationService.init();

      if (task == dailyTask) {
        final items = await StorageService().getAllItemsBackground();
        await NotificationService.showDailySummaryNow(items);
      }
    } catch (e) {
      debugPrint('[WorkmanagerService] task error: $e');
    }

    return true;
  });
}

class WorkmanagerService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await updateDailyTaskSchedule();
  }

  /// Reschedule the task using the new time stored in SharedPreferences.
  static Future<void> updateDailyTaskSchedule() async {
    final initialDelay = await _calculateInitialDelayToTargetTime();

    await Workmanager().registerPeriodicTask(
      'dailyTaskId',
      dailyTask,
      frequency: const Duration(hours: 24),
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );
  }

  static Future<Duration> _calculateInitialDelayToTargetTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final int targetHour = prefs.getInt(kNotificationHourKey) ?? kDefaultHour;
    final int targetMinute = prefs.getInt(kNotificationMinuteKey) ?? kDefaultMinute;

    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, targetHour, targetMinute, 0);

    // If today's notification time has already passed, set the target for tomorrow.
    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }

    return target.difference(now);
  }
}