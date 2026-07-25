// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/item_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Notification Config
  static const int _notificationId = 999;
  static const String _channelId = 'daily_summary';
  static const String _channelName = 'Daily Digest';
  static const String _channelDescription =
      'Daily notification showing items requiring attention';
  static const Color _notificationColor = Color(0xFF66C0F4);

  // Defaults
  static const String _arabicLanguageCode = 'ar';
  static const String _fallbackTimezone = 'Asia/Riyadh';
  static const int _scheduledHour = 20; // 8 PM

  // SharedPreferences Keys
  static const String _languageCodeKey = 'language_code';

  // ─────────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────────

  /// Initializes timezone data, notification plugin, and requests permissions.
  static Future<void> init() async {
    try {
      await _configureTimeZone();
      await _initializePlugin();
      await _requestPermissions();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

  /// Loads timezone data and sets the local timezone based on device settings.
  static Future<void> _configureTimeZone() async {
    tz_data.initializeTimeZones();

    try {
      final TimezoneInfo deviceZoneInfo = await FlutterTimezone.getLocalTimezone();
      String zoneName = deviceZoneInfo.identifier;

      // A map for handling unsupported names in the library and converting them to their direct equivalents.
      const zoneAliases = {
        'Asia/Kuwait': 'Asia/Riyadh',
        'Asia/Aden': 'Asia/Riyadh',
        'Asia/Bahrain': 'Asia/Riyadh',
        'Asia/Qatar': 'Asia/Riyadh',
      };

      if (zoneAliases.containsKey(zoneName)) {
        zoneName = zoneAliases[zoneName]!;
      }

      tz.setLocalLocation(tz.getLocation(zoneName));
      debugPrint('NotificationService: TimeZone initialized -> $zoneName');
      
    } catch (e) {
      debugPrint('NotificationService: Failed to get device timezone ($e). Applying fallback...');
      try {
        tz.setLocalLocation(tz.getLocation(_fallbackTimezone));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
  }

  /// Initializes the local notifications plugin for Android.
  static Future<void> _initializePlugin() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: settings);
  }

  /// Requests notification permissions (required for Android 13+).
  static Future<void> _requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Scheduling
  // ─────────────────────────────────────────────────────────────────────────────

  /// Schedules (or replaces) the single daily summary notification.
  static Future<void> scheduleDailySummary(List<ItemModel> items) async {
    try {
      await _plugin.cancel(id: _notificationId);

      final alertItems = _filterAlertItems(items);
      if (alertItems.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final String langCode =
          prefs.getString(_languageCodeKey) ?? _arabicLanguageCode;
      final isArabic = langCode == _arabicLanguageCode;

      final urgentItems =
          alertItems.where((i) => i.status == ItemStatus.urgent).toList();
      final warningItems =
          alertItems.where((i) => i.status == ItemStatus.warning).toList();

      final title = isArabic ? 'طلبات البيت' : 'Home Items';
      
      final previewBody = _buildPreviewBody(urgentItems, warningItems, isArabic);

      final expandedText = _buildExpandedText(urgentItems, warningItems, isArabic);
      if (expandedText.isEmpty) return;

      final notificationStyle = BigTextStyleInformation(
        expandedText,
        contentTitle: title,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
        htmlFormatBigText: false,
      );

      final scheduledDate = _getScheduledTime();

      await _scheduleNotification(
        title: title,
        body: previewBody,
        scheduledDate: scheduledDate,
        notificationStyle: notificationStyle,
      );
    } catch (e) {
      debugPrint('Notification scheduling error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────────

  /// Filters items that have notifications enabled and are not in a 'safe' state.
  static List<ItemModel> _filterAlertItems(List<ItemModel> items) {
    return items.where((item) {
      return item.notificationsEnabled && item.status != ItemStatus.safe;
    }).toList();
  }

  /// Builds a short preview text to show the number of urgent and warning items.
  static String _buildPreviewBody(
    List<ItemModel> urgentItems,
    List<ItemModel> warningItems,
    bool isArabic,
  ) {
    final urgentCount = urgentItems.length;
    final warningCount = warningItems.length;

    if (urgentCount > 0 && warningCount > 0) {
      return isArabic
          ? '🔴 $urgentCount عاجل  •  🟡 $warningCount انتبه'
          : '🔴 $urgentCount urgent  •  🟡 $warningCount warning';
    } else if (urgentCount > 0) {
      return isArabic
          ? '🔴 $urgentCount عاجل'
          : '🔴 $urgentCount urgent';
    } else {
      return isArabic
          ? '🟡 $warningCount انتبه'
          : '🟡 $warningCount warning';
    }
  }

  /// Builds the full expanded notification text while showing only the first 2 items for each category.
  static String _buildExpandedText(
    List<ItemModel> urgentItems,
    List<ItemModel> warningItems,
    bool isArabic,
  ) {
    final buffer = StringBuffer();
    const int maxItemsToShow = 2;

    if (urgentItems.isNotEmpty) {
      buffer.writeln(isArabic ? '🔴 عاجل:' : '🔴 Urgent:');
      int limit = urgentItems.length > maxItemsToShow ? maxItemsToShow : urgentItems.length;
      for (int i = 0; i < limit; i++) {
        buffer.writeln('   • ${urgentItems[i].name}');
      }
      if (urgentItems.length > maxItemsToShow) {
        final remaining = urgentItems.length - maxItemsToShow;
        buffer.writeln(isArabic 
            ? '   • و $remaining أخرى' 
            : '   • +$remaining more');
      }
    }

    if (warningItems.isNotEmpty) {
      if (urgentItems.isNotEmpty) {
        buffer.writeln(); // Blank line as a separator between the two lists.
      }
      buffer.writeln(isArabic ? '🟡 انتبه:' : '🟡 Warning:');
      int limit = warningItems.length > maxItemsToShow ? maxItemsToShow : warningItems.length;
      for (int i = 0; i < limit; i++) {
        buffer.writeln('   • ${warningItems[i].name}');
      }
      if (warningItems.length > maxItemsToShow) {
        final remaining = warningItems.length - maxItemsToShow;
        buffer.writeln(isArabic 
            ? '   • و $remaining أخرى' 
            : '   • +$remaining more');
      }
    }

    return buffer.toString().trim();
  }

  /// Calculates the next scheduled time (Today at 8 PM or Tomorrow at 8 PM).
  static tz.TZDateTime _getScheduledTime() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      _scheduledHour,
    );

    // If 8 PM has already passed today, schedule for tomorrow
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> _scheduleNotification({
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required StyleInformation notificationStyle,
  }) async {
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
          color: _notificationColor,
          category: AndroidNotificationCategory.reminder,
          styleInformation: notificationStyle,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeats daily automatically
    );
  }
}