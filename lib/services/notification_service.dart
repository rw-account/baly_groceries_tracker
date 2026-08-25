// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // SharedPreferences Keys
  static const String _languageCodeKey = 'language_code';

  // ─────────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    try {
      await _initializePlugin();
      await _requestPermissions();
    } catch (e) {
      debugPrint('NotificationService.init error: $e');
    }
  }

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

  static Future<void> showDailySummaryNow(List<ItemModel> items) async {
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

      final title = isArabic ? 'مواد على وشك النفاد' : 'Items About to Run Out';
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

      await _plugin.show(
        id: _notificationId,
        title: title,
        body: previewBody,
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
      );
    } catch (e) {
      debugPrint('Notification show error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────────

  static List<ItemModel> _filterAlertItems(List<ItemModel> items) {
    return items.where((item) {
      return item.notificationsEnabled && item.status != ItemStatus.safe;
    }).toList();
  }

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
        buffer.writeln();
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
}