// lib/services/workmanager_service.dart

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'storage_service.dart';

const String dailyTask = 'daily_notification_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Minimal Flutter engine init needed for SQLite path resolution.
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await NotificationService.init();

      if (task == dailyTask) {
        // Uses a self-contained DB connection that closes itself.
        final items = await StorageService.getAllItemsBackground();
        await NotificationService.scheduleDailySummary(items);
      }
    } catch (e) {
      // Log and return true so Workmanager does not retry aggressively.
      // ignore: avoid_print
      print('[WorkmanagerService] task error: $e');
    }

    return true;
  });
}

class WorkmanagerService {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);

    await Workmanager().registerPeriodicTask(
      'dailyTaskId',
      dailyTask,
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );
  }
}
