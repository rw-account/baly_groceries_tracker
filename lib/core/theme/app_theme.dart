import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This app only supports dark mode; there is no light theme available
class AppTheme {
  static const primaryBlue = Color(0xFF66C0F4);
  static const bg = Color(0xFF171A21);
  static const surface = Color(0xFF151E2B);
  static const card = Color(0xFF22394F);
  static const textPrimary = Color(0xFFC7D5E0);
  static const textSecondary = Color(0xFF94A3B8);

  static const _error = Color(0xFFFF6B6B);
  static const _warning = Color(0xFFFFB74D);
  static const _safe = Color(0xFF00A884);

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,

    extensions: const <ThemeExtension<dynamic>>[
      CustomColors(safe: _safe),
    ],

    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      onPrimary: Colors.black,
      secondary: primaryBlue,
      onSecondary: Colors.black,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: card,
      error: _error,
      onError: Colors.white,
      tertiary: _warning,
      onTertiary: Colors.black,
      surfaceContainerLow: Color(0xFF1E2D3D),
      secondaryContainer: Color(0xFF22394F),
      onSecondaryContainer: textPrimary,
      primaryContainer: Color(0xFF0E3A5C),
      onPrimaryContainer: primaryBlue,
      outlineVariant: Color(0xFF3D5A73),
      shadow: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: card,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      textStyle: TextStyle(color: textPrimary),
    ),
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(card),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
        ),
      ),
    ),
    dividerColor: Color(0xFF3D5A73),
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
        backgroundColor: primaryBlue,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    chipTheme: ChipThemeData(
      backgroundColor: Color(0xFF22394F),
      labelStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: card,
      contentTextStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );

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

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? safe;

  const CustomColors({required this.safe});

  @override
  CustomColors copyWith({Color? safe}) {
    return CustomColors(safe: safe ?? this.safe);
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(safe: Color.lerp(safe, other.safe, t));
  }
}