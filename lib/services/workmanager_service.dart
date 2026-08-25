// lib/services/workmanager_service.dart

import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';
import 'storage_service.dart';

const String dailyTask = 'daily_notification_task';

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

    await Workmanager().registerPeriodicTask(
      'dailyTaskId',
      dailyTask,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelayTo8PM(),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
      ),
    );
  }

  static Duration _calculateInitialDelayTo8PM() {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, 20, 0, 0); // 8:00 PM

    if (now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }

    return target.difference(now);
  }
}