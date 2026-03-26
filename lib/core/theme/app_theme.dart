import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_config.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData themeFromPalette(ThemePalette palette) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',

      // ── Color Scheme ───────────────────────────────────
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        secondary: palette.accent,
        surface: palette.surface,
        surfaceContainer: palette.surfaceVariant,
        error: const Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: palette.textPrimary,
        onError: Colors.white,
      ),

      // ── Scaffold ───────────────────────────────────────
      scaffoldBackgroundColor: palette.background,

      // ── App Bar ────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3.copyWith(color: palette.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // ── Card ───────────────────────────────────────────
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: palette.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: AppTextStyles.button,
          elevation: 0,
        ),
      ),

      // ── Outlined Button ────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary),
          minimumSize: const Size(double.infinity, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ── Text Button ────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          textStyle: AppTextStyles.labelLarge,
        ),
      ),

      // ── Input Field ────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingMd,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: palette.textSecondary,
        ),
        labelStyle: AppTextStyles.labelLarge.copyWith(color: palette.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(color: palette.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFEF4444)),
      ),

      // ── Divider ────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 0.5,
        space: 1,
      ),

      // ── Bottom Navigation ──────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // ── Material 3 Navigation Bar ────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.primary);
          }
          return IconThemeData(color: palette.textSecondary);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(color: palette.primary, fontWeight: FontWeight.w600);
          }
          return AppTextStyles.labelSmall.copyWith(color: palette.textSecondary);
        }),
      ),

      // ── Chip ───────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceVariant,
        selectedColor: palette.primary.withValues(alpha: 0.2),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: palette.textPrimary),
        side: BorderSide(color: palette.border, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      ),

      // ── Dialog ─────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),

      // ── Text ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: palette.textPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: palette.textPrimary),
        headlineLarge: AppTextStyles.h1.copyWith(color: palette.textPrimary),
        headlineMedium: AppTextStyles.h2.copyWith(color: palette.textPrimary),
        headlineSmall: AppTextStyles.h3.copyWith(color: palette.textPrimary),
        titleLarge: AppTextStyles.h4.copyWith(color: palette.textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: palette.textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: palette.textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: palette.textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: palette.textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: palette.textPrimary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: palette.textSecondary),
      ),

      // ── Icon ───────────────────────────────────────────
      iconTheme: IconThemeData(
        color: palette.textSecondary,
        size: AppSizes.iconLg,
      ),

      // ── Snack Bar ──────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceVariant,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: palette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Keep darkTheme for initial or static fallback if needed, but updated to use one of the palettes
  static ThemeData get darkTheme => themeFromPalette(ThemePalette.apple);
}
