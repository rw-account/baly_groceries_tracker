// lib/providers/app_state_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appStateNotifierProvider =
    Provider<AppStateNotifier>((ref) => throw UnsupportedError(
        'appStateNotifierProvider must be overridden in ProviderScope'));

class AppStateNotifier extends ChangeNotifier {
  final SharedPreferences prefs;

  bool _onboardingCompleted;
  bool _hasLanguageSelected;

  AppStateNotifier(this.prefs)
      : _onboardingCompleted = prefs.getBool('onboarding_completed') ?? false,
        _hasLanguageSelected = prefs.containsKey('language_code');

  bool get onboardingCompleted => _onboardingCompleted;
  bool get hasLanguageSelected => _hasLanguageSelected;

  Future<void> completeOnboarding() async {
    await prefs.setBool('onboarding_completed', true);
    _onboardingCompleted = true;
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await prefs.setString('language_code', languageCode);
    _hasLanguageSelected = true;
    notifyListeners();
  }
}