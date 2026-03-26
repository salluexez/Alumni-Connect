import 'package:flutter/material.dart';

enum ThemeType { vscode, midnight, solarized, cyberpunk, dark }

class ThemePalette {
  final Color primary;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color border;

  const ThemePalette({
    required this.primary,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.border,
  });

  static const ThemePalette vscode = ThemePalette(
    primary: Color(0xFF007ACC),
    background: Color(0xFF1E1E1E),
    surface: Color(0xFF252526),
    surfaceVariant: Color(0xFF2D2D2D),
    textPrimary: Color(0xFFD4D4D4),
    textSecondary: Color(0xFF9D9D9D),
    accent: Color(0xFF3794FF),
    border: Color(0xFF333333),
  );

  static const ThemePalette midnight = ThemePalette(
    primary: Color(0xFF6366F1),
    background: Color(0xFF020617),
    surface: Color(0xFF0F172A),
    surfaceVariant: Color(0xFF1E293B),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    accent: Color(0xFF818CF8),
    border: Color(0xFF1E293B),
  );

  static const ThemePalette solarized = ThemePalette(
    primary: Color(0xFF268BD2),
    background: Color(0xFF002B36),
    surface: Color(0xFF073642),
    surfaceVariant: Color(0xFF586E75),
    textPrimary: Color(0xFF839496),
    textSecondary: Color(0xFF93A1A1),
    accent: Color(0xFF2AA198),
    border: Color(0xFF073642),
  );

  static const ThemePalette cyberpunk = ThemePalette(
    primary: Color(0xFFF305FF),
    background: Color(0xFF0D0221),
    surface: Color(0xFF1B065E),
    surfaceVariant: Color(0xFF2F0A99),
    textPrimary: Color(0xFF00FBFF),
    textSecondary: Color(0xFFFF0055),
    accent: Color(0xFFFFD300),
    border: Color(0xFF1B065E),
  );

  static const ThemePalette apple = ThemePalette(
    primary: Color(0xFF0A84FF), // iOS Blue
    background: Color(0xFF000000), // True black
    surface: Color(0xFF1C1C1E), // Dark gray
    surfaceVariant: Color(0xFF2C2C2E), // Lighter gray
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFEBEBF5), // iOS secondary text (vibrancy-like)
    accent: Color(0xFF30D158), // iOS Green
    border: Color(0xFF38383A),
  );

  static const ThemePalette originalDark = apple;

  static ThemePalette fromType(ThemeType type) {
    switch (type) {
      case ThemeType.vscode:
        return vscode;
      case ThemeType.midnight:
        return midnight;
      case ThemeType.solarized:
        return solarized;
      case ThemeType.cyberpunk:
        return cyberpunk;
      case ThemeType.dark:
        return apple;
    }
  }
}
