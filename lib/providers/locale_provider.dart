// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:baly_groceries_tracker/providers/app_state_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    await appState.setLanguage(languageCode);

    currentLanguage = languageCode;
    state = Locale(languageCode);
  }
}