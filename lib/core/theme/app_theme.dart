import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// This app only supports dark mode; there is no light theme available.
class AppTheme {
  static const primaryBlue = Color(0xFF66C0F4);
  static const bg = Color(0xFF171A21);
  static const surface = Color(0xFF151E2B);
  static const card = Color(0xFF22394F);
  static const textPrimary = Color(0xFFC7D5E0);
  static const textSecondary = Color(0xFF94A3B8);

  static const _error = Color(0xFFFF6B6B);
  static const _warning = Color(0xFFFFB74D);
  static const _safe = Color(0xFF34D399);

  static const _cardRadius = 16.0;
  static const _buttonRadius = 16.0;
  static const _chipRadius = 8.0;
  static const _dialogRadius = 28.0;
  static const _fieldRadius = 12.0;
  static const _snackBarRadius = 12.0;

  static const _space8 = 8.0;
  static const _space16 = 16.0;

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
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
      margin: EdgeInsets.symmetric(horizontal: _space16, vertical: _space8),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        side: const BorderSide(color: primaryBlue, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.black,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    ),

    popupMenuTheme: const PopupMenuThemeData(
      color: card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_dialogRadius))),
      textStyle: TextStyle(color: textPrimary),
    ),

    menuTheme: const MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(card),
        surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        elevation: WidgetStatePropertyAll(0),
        shadowColor: WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_dialogRadius))),
        ),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: const Color(0xFF3D5A73),
      thickness: 1,
      space: 1,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E2D3D),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 16),
      hintStyle: const TextStyle(color: textSecondary, fontSize: 16),
      floatingLabelStyle: const TextStyle(color: primaryBlue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: const Color(0xFF3D5A73), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: _error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: const BorderSide(color: _error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_fieldRadius),
        borderSide: BorderSide(color: const Color(0xFF3D5A73).withValues(alpha: 0.5), width: 1),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 57, letterSpacing: -0.25),
      displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 45, letterSpacing: 0),
      displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 36, letterSpacing: 0),
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 32, letterSpacing: 0),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 28, letterSpacing: 0),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 24, letterSpacing: 0),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 22, letterSpacing: 0),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: 0.15),
      titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16, height: 1.5, letterSpacing: 0.5),
      bodyMedium: TextStyle(color: textPrimary, fontSize: 14, height: 1.4, letterSpacing: 0.25),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.3, letterSpacing: 0.4),
      labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
      labelMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 12, letterSpacing: 0.5),
      labelSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.5),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: card,
      disabledColor: card.withValues(alpha: 0.5),
      selectedColor: primaryBlue.withValues(alpha: 0.2),
      secondarySelectedColor: primaryBlue,
      labelStyle: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
      secondaryLabelStyle: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_chipRadius)),
      side: BorderSide.none,
      elevation: 0,
      pressElevation: 0,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_dialogRadius)),
      titleTextStyle: const TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
      contentTextStyle: const TextStyle(color: textPrimary, fontSize: 16, height: 1.5),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(_dialogRadius)),
      ),
      modalBackgroundColor: surface,
      dragHandleColor: textSecondary,
      dragHandleSize: const Size(36, 4),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: card,
      contentTextStyle: const TextStyle(color: textPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_snackBarRadius)),
      elevation: 0,
      actionTextColor: primaryBlue,
    ),

    dividerColor: const Color(0xFF3D5A73),
    iconTheme: const IconThemeData(color: textSecondary, size: 24),
    primaryIconTheme: const IconThemeData(color: Colors.black, size: 24),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      indicatorColor: primaryBlue.withValues(alpha: 0.12),
      indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primaryBlue, fontWeight: FontWeight.w600, fontSize: 12);
        }
        return const TextStyle(color: textSecondary, fontSize: 12);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryBlue, size: 24, fill: 1.0);
        }
        return const IconThemeData(color: textSecondary, size: 24, fill: 0.0);
      }),
      height: 72,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      elevation: 0,
      selectedItemColor: primaryBlue,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      type: BottomNavigationBarType.fixed,
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
      linearTrackColor: Color(0xFF1E2D3D),
      circularTrackColor: Color(0xFF1E2D3D),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryBlue;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.black),
      side: WidgetStateBorderSide.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return BorderSide.none;
        return const BorderSide(color: textSecondary, width: 1.5);
      }),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryBlue;
        return textSecondary;
      }),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryBlue;
        return Colors.grey.shade400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryBlue.withValues(alpha: 0.5);
        return Colors.grey.shade700;
      }),
      trackOutlineWidth: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return 0.0;
        return 1.0;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        return const Color(0xFF3D5A73);
      }),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryBlue,
      inactiveTrackColor: primaryBlue.withValues(alpha: 0.3),
      thumbColor: primaryBlue,
      overlayColor: primaryBlue.withValues(alpha: 0.12),
      valueIndicatorColor: primaryBlue,
      valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    tabBarTheme: TabBarThemeData(
      labelColor: primaryBlue,
      unselectedLabelColor: textSecondary,
      indicatorColor: primaryBlue,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
      dividerColor: Colors.transparent,
    ),

    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
      tileColor: Colors.transparent,
      selectedTileColor: primaryBlue.withValues(alpha: 0.12),
      iconColor: textSecondary,
      textColor: textPrimary,
      titleTextStyle: const TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      subtitleTextStyle: const TextStyle(color: textSecondary, fontSize: 14),
      leadingAndTrailingTextStyle: const TextStyle(color: textSecondary, fontSize: 12),
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