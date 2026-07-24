// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../../models/item_model.dart';

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
    try {
      // 1. تحميل بيانات المناطق الزمنية
      tz_data.initializeTimeZones();

      // 2. ضبط المنطقة الزمنية باستخدام flutter_timezone (موثوق في أندرويد و iOS)
      try {
        // نقوم بجلب كائن معلومات المنطقة الزمنية أولاً
        final TimezoneInfo deviceZoneInfo = await FlutterTimezone.getLocalTimezone();
        
        // نستخدم الـ identifier لاستخراج النص مثل "Asia/Riyadh"
        final String deviceZone = deviceZoneInfo.identifier;
        
        tz.setLocalLocation(tz.getLocation(deviceZone));
      } catch (_) {
        // احتياطي في حال تعذر تحديد المنطقة الزمنية
        tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
      }

      // 3. تهيئة الإشعارات
      const androidInit = AndroidInitializationSettings('ic_notification');
      const settings = InitializationSettings(android: androidInit);
      await _plugin.initialize(settings: settings);

      // 4. طلب إذن الإشعارات (أندرويد 13+)
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.requestNotificationsPermission();
    } catch (e) {
      // لو حدث أي خطأ غير متوقع، لن يوقف التطبيق
      // ignore: avoid_print
      print('NotificationService.init error: $e');
    }
  }

  // ─── Schedule ─────────────────────────────────────────────────────────────────

  /// Schedules (or replaces) the single daily summary notification at 8 PM.
  static Future<void> scheduleDailySummary(List<ItemModel> items) async {
    try {
      await _plugin.cancel(id: _notificationId);

      final alertItems = items.where((item) {
        return item.notificationsEnabled && item.status != ItemStatus.safe;
      }).toList();

      if (alertItems.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final String langCode = prefs.getString('language_code') ?? 'ar';

      final urgentItems =
          alertItems.where((i) => i.status == ItemStatus.urgent).toList();
      final warningItems =
          alertItems.where((i) => i.status == ItemStatus.warning).toList();

      final separator = langCode == 'ar' ? '، ' : ', ';
      final buffer = StringBuffer();
      if (urgentItems.isNotEmpty) {
        final urgentPrefix = langCode == 'ar' ? '🔴 عاجل' : '🔴 Urgent';
        buffer.writeln('$urgentPrefix: ${urgentItems.map((e) => e.name).join(separator)}');
      }
      
      if (warningItems.isNotEmpty) {
        final warningPrefix = langCode == 'ar' ? '🟡 انتبه' : '🟡 Warning';
        buffer.writeln('$warningPrefix: ${warningItems.map((e) => e.name).join(separator)}');
      }

      final body = buffer.toString().trim();

      final title = langCode == 'ar' ? 'ملخص طلبات البيت' : 'Home Items Summary';

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate =
          tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);

      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        id: _notificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            icon: 'ic_notification',
            styleInformation: BigTextStyleInformation(body),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Makes the notification repeat daily automatically
      );
    } catch (e) {
      // ignore: avoid_print
      print('Notification scheduling error: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancel(id: _notificationId);
  }
}
