// lib/services/notification_service.dart

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/item_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _notificationId = 999;
  static const String _channelId = 'daily_summary';
  static const String _channelName = 'الملخص اليومي';
  static const String _channelDescription =
      'إشعار يومي يوضح العناصر التي تحتاج انتباه';

  // ─── Init ────────────────────────────────────────────────────────────────────


  static Future<void> init() async {
    tz_data.initializeTimeZones();

    // الحصول على المنطقة الزمنية الحقيقية من الجهاز عبر القناة
    const channel = MethodChannel('com.home_orders_tracker.app/local_timezone');
    try {
      final String? deviceZone = await channel.invokeMethod<String>('getTimeZone');
      if (deviceZone != null && deviceZone.isNotEmpty) {
        tz.setLocalLocation(tz.getLocation(deviceZone));
      } else {
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      }
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  // ─── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedules (or replaces) the single daily summary notification at 8 PM.
  static Future<void> scheduleDailySummary(List<ItemModel> items) async {
    try {
      await _plugin.cancel(_notificationId);

      final alertItems = items.where((item) {
        return item.notificationsEnabled && item.status != ItemStatus.safe;
      }).toList();

      if (alertItems.isEmpty) return;

      final urgentItems =
          alertItems.where((i) => i.status == ItemStatus.urgent).toList();
      final warningItems =
          alertItems.where((i) => i.status == ItemStatus.warning).toList();

      final buffer = StringBuffer();
      if (urgentItems.isNotEmpty) {
        buffer.writeln('🔴 عاجل: ${urgentItems.map((e) => e.name).join('، ')}');
      }
      if (warningItems.isNotEmpty) {
        buffer.writeln('🟡 انتبه: ${warningItems.map((e) => e.name).join('، ')}');
      }

      final body = buffer.toString().trim();

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);

      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _notificationId,
        'ملخص طلبات البيت',
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Notification scheduling error: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancel(_notificationId);
  }
}