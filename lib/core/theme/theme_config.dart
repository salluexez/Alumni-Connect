import 'package:flutter/material.dart';

enum ThemeType { light, dark, monkey, dracula, nord, solarizedDark, midnight, cyberpunk, ocean, espresso, sunset, forest, lavender }

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
  final Color success;
  final Color warning;
  final Color info;
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
    required this.success,
    required this.warning,
    required this.info,
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
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    info: Color(0xFF0A84FF),
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
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    info: Color(0xFF0A84FF),
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
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF38BDF8),
    brightness: Brightness.dark,
  );

  static const ThemePalette dracula = ThemePalette(
    primary: Color(0xFFBD93F9),
    background: Color(0xFF282A36),
    surface: Color(0xFF1E1F29),
    surfaceVariant: Color(0xFF44475A),
    textPrimary: Color(0xFFF8F8F2),
    textSecondary: Color(0xFF6272A4),
    accent: Color(0xFFFF79C6),
    border: Color(0xFF44475A),
    error: Color(0xFFFF5555),
    success: Color(0xFF50FA7B),
    warning: Color(0xFFFFB86C),
    info: Color(0xFF8BE9FD),
    brightness: Brightness.dark,
  );

  static const ThemePalette nord = ThemePalette(
    primary: Color(0xFF88C0D0),
    background: Color(0xFF2E3440),
    surface: Color(0xFF3B4252),
    surfaceVariant: Color(0xFF434C5E),
    textPrimary: Color(0xFFD8DEE9),
    textSecondary: Color(0xFF81A1C1),
    accent: Color(0xFF8FBCBB),
    border: Color(0xFF434C5E),
    error: Color(0xFFBF616A),
    success: Color(0xFFA3BE8C),
    warning: Color(0xFFEBCB8B),
    info: Color(0xFF81A1C1),
    brightness: Brightness.dark,
  );

  static const ThemePalette solarizedDark = ThemePalette(
    primary: Color(0xFF268BD2),
    background: Color(0xFF002B36),
    surface: Color(0xFF073642),
    surfaceVariant: Color(0xFF586E75),
    textPrimary: Color(0xFF839496),
    textSecondary: Color(0xFF93A1A1),
    accent: Color(0xFF859900),
    border: Color(0xFF073642),
    error: Color(0xFFDC322F),
    success: Color(0xFF2AA198),
    warning: Color(0xFFB58900),
    info: Color(0xFF268BD2),
    brightness: Brightness.dark,
  );

  static const ThemePalette midnight = ThemePalette(
    primary: Color(0xFFBB86FC),
    background: Color(0xFF000000),
    surface: Color(0xFF121212),
    surfaceVariant: Color(0xFF1F1F1F),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B0B0),
    accent: Color(0xFF03DAC6),
    border: Color(0xFF1F1F1F),
    error: Color(0xFFCF6679),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFC107),
    info: Color(0xFF2196F3),
    brightness: Brightness.dark,
  );

  static const ThemePalette cyberpunk = ThemePalette(
    primary: Color(0xFFFF00FF),
    background: Color(0xFF120458),
    surface: Color(0xFF1A096D),
    surfaceVariant: Color(0xFF241082),
    textPrimary: Color(0xFFF1F1F1),
    textSecondary: Color(0xFFE000FF),
    accent: Color(0xFF00FFFF),
    border: Color(0xFF241082),
    error: Color(0xFFFF0055),
    success: Color(0xFF00FF9F),
    warning: Color(0xFFFAE100),
    info: Color(0xFF00B8FF),
    brightness: Brightness.dark,
  );

  static const ThemePalette ocean = ThemePalette(
    primary: Color(0xFF0EA5E9),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFF334155),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    accent: Color(0xFF2DD4BF),
    border: Color(0xFF334155),
    error: Color(0xFFEF4444),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    info: Color(0xFF38BDF8),
    brightness: Brightness.dark,
  );

  static const ThemePalette espresso = ThemePalette(
    primary: Color(0xFFD2B48C),
    background: Color(0xFF2C2420),
    surface: Color(0xFF3D322C),
    surfaceVariant: Color(0xFF4E4039),
    textPrimary: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA09088),
    accent: Color(0xFF8B4513),
    border: Color(0xFF4E4039),
    error: Color(0xFFFF6347),
    success: Color(0xFF90EE90),
    warning: Color(0xFFFFA500),
    info: Color(0xFF87CEEB),
    brightness: Brightness.dark,
  );

  static const ThemePalette sunset = ThemePalette(
    primary: Color(0xFFFF7E5F),
    background: Color(0xFF1A1C2C),
    surface: Color(0xFF292B3D),
    surfaceVariant: Color(0xFF3D3F5C),
    textPrimary: Color(0xFFF4F4F4),
    textSecondary: Color(0xFF9495A5),
    accent: Color(0xFFFEB47B),
    border: Color(0xFF3D3F5C),
    error: Color(0xFFFF4D4D),
    success: Color(0xFF50C878),
    warning: Color(0xFFFFD700),
    info: Color(0xFF6495ED),
    brightness: Brightness.dark,
  );

  static const ThemePalette forest = ThemePalette(
    primary: Color(0xFF4B6F44),
    background: Color(0xFF1B261A),
    surface: Color(0xFF243023),
    surfaceVariant: Color(0xFF324031),
    textPrimary: Color(0xFFE0E0E0),
    textSecondary: Color(0xFF8FA18E),
    accent: Color(0xFF98FB98),
    border: Color(0xFF324031),
    error: Color(0xFFB22222),
    success: Color(0xFF7FFF00),
    warning: Color(0xFFDAA520),
    info: Color(0xFF8FBC8F),
    brightness: Brightness.dark,
  );

  static const ThemePalette lavender = ThemePalette(
    primary: Color(0xFFB19CD9),
    background: Color(0xFF2E2B3D),
    surface: Color(0xFF3C394F),
    surfaceVariant: Color(0xFF4D4966),
    textPrimary: Color(0xFFF0F0F5),
    textSecondary: Color(0xFFA6A3C2),
    accent: Color(0xFFE6E6FA),
    border: Color(0xFF4D4966),
    error: Color(0xFFFF6961),
    success: Color(0xFF77DD77),
    warning: Color(0xFFFDFD96),
    info: Color(0xFFAEC6CF),
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
      case ThemeType.dracula:
        return dracula;
      case ThemeType.nord:
        return nord;
      case ThemeType.solarizedDark:
        return solarizedDark;
      case ThemeType.midnight:
        return midnight;
      case ThemeType.cyberpunk:
        return cyberpunk;
      case ThemeType.ocean:
        return ocean;
      case ThemeType.espresso:
        return espresso;
      case ThemeType.sunset:
        return sunset;
      case ThemeType.forest:
        return forest;
      case ThemeType.lavender:
        return lavender;
    }
  }
}
