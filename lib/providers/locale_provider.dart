// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:home_orders_tracker/providers/app_state.dart';
import 'package:home_orders_tracker/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/notification_service.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  static String currentLanguage = 'ar';

  @override
  Locale build() {
    final appState = ref.read(appStateNotifierProvider);
    final languageCode = appState.prefs.getString('language_code') ?? 'ar';
    currentLanguage = languageCode;
    return Locale(languageCode);
  }

  Future<void> changeLocale(String languageCode) async {
    final appState = ref.read(appStateNotifierProvider);
    await appState.prefs.setString('language_code', languageCode);

    currentLanguage = languageCode;
    state = Locale(languageCode);

    // Reschedule the daily summary notification to apply the new language,
    // ensuring the alert is displayed in the user's updated locale.
    try {
      final storage = ref.read(storageServiceProvider);
      final items = await storage.getAllItems();
      await NotificationService.scheduleDailySummary(items);
    } catch (_) {}
  }
}