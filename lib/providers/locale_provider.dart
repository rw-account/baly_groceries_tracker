// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:home_orders_tracker/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {

  static String currentLanguage = 'ar';

  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';
    currentLanguage = languageCode;
    return Locale(languageCode);
  }

  Future<void> changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);   
    currentLanguage = languageCode;
    state = AsyncData(Locale(languageCode));

    try {
      final storage = ref.read(storageServiceProvider);
      final items = await storage.getAllItems();

      await NotificationService.scheduleDailySummary(items);
    } catch (_) {
    }
  }
}
