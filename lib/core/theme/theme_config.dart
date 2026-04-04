import 'package:flutter/material.dart';

enum ThemeType { light, dark, monkey }

class ThemePalette {
  final Color primary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color border;
  final Color error;
  final Brightness brightness;

  const ThemePalette({
    required this.primary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.border,
    required this.error,
    required this.brightness,
  });

  static const ThemePalette light = ThemePalette(
    primary: Color(0xFF0A84FF),
    background: Color(0xFFF2F2F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFE5E5EA),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF3C3C43),
    accent: Color(0xFF5E5CE6),
    border: Color(0xFFC6C6C8),
    error: Color(0xFFFF3B30),
    brightness: Brightness.light,
  );

  static const ThemePalette dark = ThemePalette(
    primary: Color(0xFF0A84FF),
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1E),
    surfaceVariant: Color(0xFF2C2C2E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    accent: Color(0xFF30D158),
    border: Color(0xFF38383A),
    error: Color(0xFFFF453A),
    brightness: Brightness.dark,
  );

  static const ThemePalette monkey = ThemePalette(
    primary: Color(0xFF22C55E),
    background: Color(0xFF0F172A),
    surface: Color(0xFF020617),
    surfaceVariant: Color(0xFF1E293B),
    textPrimary: Color(0xFFE2E8F0),
    textSecondary: Color(0xFF64748B),
    accent: Color(0xFF38BDF8),
    border: Color(0xFF1E293B),
    error: Color(0xFFEF4444),
    brightness: Brightness.dark,
  );

  static ThemePalette fromType(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return light;
      case ThemeType.dark:
        return dark;
      case ThemeType.monkey:
        return monkey;
    }
  }
}
