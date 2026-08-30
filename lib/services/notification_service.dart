// lib/services/notification_service.dart

import 'dart:async';
import 'package:baly_groceries_tracker/core/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item_model.dart';

enum NotificationPermissionState {
  granted,
  requestNeeded,
  settingsRequired,
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Notification Config
  static const int _notificationId = 999;
  static const String _channelId = 'item_alerts';
  static const String _channelName = 'Item Alerts';
  static const String _channelDescription =
      'Notification showing items requiring attention';
  static const Color _notificationColor = Color(0xFF66C0F4);

  // Defaults
  static const String _arabicLanguageCode = 'ar';

  // SharedPreferences Keys
  static const String _languageCodeKey = 'language_code';
  static const String _dontAskPrePermissionKey =
      'dont_ask_notification_pre_permission';
  static const String _dontAskSettingsKey = 'dont_ask_notification_settings';

  // ─────────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────────

  static Future<void> init() async {
    try {
      await _initializePlugin();
    } catch (e, stackTrace) {
      debugPrint('NotificationService.init error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> _initializePlugin() async {
    const androidInit = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings: settings);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Permission Handling
  // ─────────────────────────────────────────────────────────────────────────────

  static NotificationPermissionState resolvePermissionState(
      PermissionStatus status) {
    if (status.isGranted) {
      return NotificationPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return NotificationPermissionState.settingsRequired;
    }
    return NotificationPermissionState.requestNeeded;
  }

  /// Requests notification permissions with a custom pre-prompt and settings fallback.
  static Future<void> requestPermissions(BuildContext? context) async {
    final status = await Permission.notification.status;
    final permissionState = resolvePermissionState(status);

    if (permissionState == NotificationPermissionState.granted) {
      return;
    }

    if (permissionState == NotificationPermissionState.settingsRequired) {
      if (context != null && context.mounted) {
        await _showSettingsBanner(context);
      }
      return;
    }

    bool shouldContinue = true;
    if (context != null && context.mounted) {
      shouldContinue = await _showPrePermissionBanner(context);
    }

    if (!shouldContinue) return;

    final requestedStatus = await Permission.notification.request();

    // Android <= 12 doesn't prompt for notifications at runtime.
    // Using !isGranted ensures the fallback banner shows across all API levels.
    if (!requestedStatus.isGranted && context != null && context.mounted) {
      await _showSettingsBanner(context);
    }
  }

  static Future<bool> _showPrePermissionBanner(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool dontAskAgain = prefs.getBool(_dontAskPrePermissionKey) ?? false;

    if (dontAskAgain) {
      return false;
    }

    if (!context.mounted) return false;

    ScaffoldMessenger.of(context).clearMaterialBanners();
    final Completer<bool> completer = Completer<bool>();
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 2,
        backgroundColor: colorScheme.primaryContainer,
        forceActionsBelow: true,
        leading: Icon(
          Icons.notifications_active_rounded,
          color: colorScheme.primary,
          size: 28,
        ),
        content: Text(
          context.loc.notificationPrePermissionMessage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.setBool(_dontAskPrePermissionKey, true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearMaterialBanners();
              }
              if (!completer.isCompleted) completer.complete(false);
            },
            child: Text(
              context.loc.dontAskAgain,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearMaterialBanners();
              if (!completer.isCompleted) completer.complete(false);
            },
            child: Text(
              context.loc.notNow,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearMaterialBanners();
              if (!completer.isCompleted) completer.complete(true);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(80, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.enable),
          ),
        ],
      ),
    );

    return completer.future;
  }

  static Future<void> _showSettingsBanner(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool dontAskAgain = prefs.getBool(_dontAskSettingsKey) ?? false;

    if (dontAskAgain) {
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearMaterialBanners();
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: 2,
        backgroundColor: Color.alphaBlend(
          colorScheme.errorContainer,
          colorScheme.surface,
        ),
        forceActionsBelow: true,
        leading: Icon(
          Icons.notifications_off_rounded,
          color: colorScheme.onErrorContainer,
          size: 28,
        ),
        content: Text(
          context.loc.notificationSettingsMessage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onErrorContainer,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final p = await SharedPreferences.getInstance();
              await p.setBool(_dontAskSettingsKey, true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearMaterialBanners();
              }
            },
            child: Text(
              context.loc.dontAskAgain,
              style: TextStyle(
                color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearMaterialBanners();
            },
            child: Text(
              context.loc.notNow,
              style: TextStyle(
                color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearMaterialBanners();
              openAppSettings();
            },
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              minimumSize: const Size(80, 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(context.loc.settings),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Daily Summary Notification
  // ─────────────────────────────────────────────────────────────────────────────

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
    } catch (e, stackTrace) {
      debugPrint('Notification show error: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
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
      final int limit =
          urgentItems.length > maxItemsToShow ? maxItemsToShow : urgentItems.length;
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
      final int limit =
          warningItems.length > maxItemsToShow ? maxItemsToShow : warningItems.length;
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