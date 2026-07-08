import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ثيم Steam الرسمي - دارك فقط
class SteamTheme {
  // ألوان Steam الأصلية
  static const steamBlue = Color(0xFF66C0F4);      // أزرار وروابط
  static const bg = Color(0xFF171A21);             // خلفية التطبيق
  static const surface = Color(0xFF1B2838);        // AppBar و surfaces
  static const card = Color(0xFF2A475E);           // كروت وقوائم
  static const textPrimary = Color(0xFFC7D5E0);   // نص أساسي
  static const textSecondary = Color(0xFF8B9BB4);  // نص ثانوي

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: steamBlue,
      onPrimary: Colors.black,
      secondary: steamBlue,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dividerColor: card,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary, height: 1.4),
      bodySmall: TextStyle(color: textSecondary),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: steamBlue,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    chipTheme: ChipThemeData(
      backgroundColor: card,
      labelStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),
  );

  /// يضبط شريط الحالة والتنقل بنفس ألوان Steam
  static void applySystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: surface,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }
}