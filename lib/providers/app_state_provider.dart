// lib/providers/app_state_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/log_retention_option.dart';

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

  Future<void> setLogRetentionOption(LogRetentionOption option, {int? customDays}) async {
    await prefs.setString('log_retention_option', option.storageValue);
    if (customDays != null) {
      await prefs.setInt('log_retention_custom_days', customDays);
    } else {
      await prefs.remove('log_retention_custom_days');
    }
    notifyListeners();
  }

  LogRetentionOption getLogRetentionOption() {
    final value = prefs.getString('log_retention_option');
    return LogRetentionOptionX.fromStorageValue(value);
  }

  int? getLogRetentionCustomDays() {
    return prefs.getInt('log_retention_custom_days');
  }
}