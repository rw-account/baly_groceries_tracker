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

  // ألوان دلالية مخصصة لهوية Steam (للأخطاء، التحذيرات، إلخ)
  static const _steamError = Color(0xFFE74C3C);       // أحمر Steam للأخطاء
  static const _steamWarning = Color(0xFFE5A952);     // برتقالي/ذهبي للتحذيرات

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: steamBlue,
      onPrimary: Colors.black,
      secondary: steamBlue,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: card,
      
      // ⬇️ إضافة الألوان الدلالية التي استخدمناها في الكود ⬇️
      
      // للأخطاء (بديل Colors.red)
      error: _steamError,
      onError: Colors.white,

      // للتحذيرات (بديل Colors.orange) - استخدمنا tertiary في الكود
      tertiary: _steamWarning,
      onTertiary: Colors.black,

      // لخلفية البطاقات المميزة (بديل Colors.white في الوضع الفاتح)
      surfaceContainerLow: Color(0xFF1E2D3D), // درجة بين surface والـ card لتبدو بارزة

      // لخلفية العناصر الفرعية (بديل Colors.grey.shade100) - مثل بطاقة الملاحظات والـ Chips
      secondaryContainer: Color(0xFF2A475E), // استخدام لون الـ card كخلفية ثانوية
      onSecondaryContainer: textPrimary,     // لون النص فوقها

      // لحالات النجاح / الآمنة (بديل Colors.green) - استخدمنا primaryContainer في Empty State
      primaryContainer: Color(0xFF0E3A5C),   // خلفية داكنة مائلة للأزرق
      onPrimaryContainer: steamBlue,         // الأيقونة والنص بلون Steam الأزرق

      // للحدود والفواصل (بديل Colors.grey.shade300)
      outlineVariant: Color(0xFF3D5A73),
      
      // للظلال (بديل Colors.black)
      shadow: Colors.black,
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
    dividerColor: const Color(0xFF3D5A73), // تم تحسينه ليكون outlineVariant
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary, height: 1.4),
      bodySmall: TextStyle(color: textSecondary),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFF2A475E), // secondaryContainer
      labelStyle: const TextStyle(color: textPrimary), // onSecondaryContainer
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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