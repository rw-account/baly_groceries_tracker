import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale> build() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';
    return Locale(languageCode);
  }

  // دالة لتغيير اللغة وحفظها فوراً
  Future<void> changeLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    // تحديث الحالة ليراها التطبيق فوراً
    state = AsyncData(Locale(languageCode));
  }
}
