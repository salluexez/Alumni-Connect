import 'package:flutter/material.dart';

enum ThemeType { light, dark, monkey, dracula, nord, solarizedDark, midnight, cyberpunk, ocean, espresso, sunset, forest, lavender, rosePine, matrix, sakura, amoled, tokyoNight, carbon, serika, retro, nautical, deepSea, marsh, neon, gruvbox }

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

  static const ThemePalette rosePine = ThemePalette(
    primary: Color(0xFFEBBCBA),
    background: Color(0xFF191724),
    surface: Color(0xFF1F1D2E),
    surfaceVariant: Color(0xFF26233A),
    textPrimary: Color(0xFFE0DEF4),
    textSecondary: Color(0xFF908CAA),
    accent: Color(0xFFEB6F92),
    border: Color(0xFF26233A),
    error: Color(0xFFEB6F92),
    success: Color(0xFF31748F),
    warning: Color(0xFFF6C177),
    info: Color(0xFF9CCFD8),
    brightness: Brightness.dark,
  );

  static const ThemePalette matrix = ThemePalette(
    primary: Color(0xFF00FF41),
    background: Color(0xFF000000),
    surface: Color(0xFF0D0D0D),
    surfaceVariant: Color(0xFF1A1A1A),
    textPrimary: Color(0xFF00FF41),
    textSecondary: Color(0xFF008F11),
    accent: Color(0xFF008F11),
    border: Color(0xFF1A1A1A),
    error: Color(0xFFFF0000),
    success: Color(0xFF00FF41),
    warning: Color(0xFFADFF2F),
    info: Color(0xFF00FF41),
    brightness: Brightness.dark,
  );

  static const ThemePalette sakura = ThemePalette(
    primary: Color(0xFFFFB7C5),
    background: Color(0xFFFFF5F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFEE1E8),
    textPrimary: Color(0xFF5D576B),
    textSecondary: Color(0xFF9D95B0),
    accent: Color(0xFFF28482),
    border: Color(0xFFFEE1E8),
    error: Color(0xFFF28482),
    success: Color(0xFF84A59D),
    warning: Color(0xFFF6BD60),
    info: Color(0xFFF5CAC3),
    brightness: Brightness.light,
  );

  static const ThemePalette amoled = ThemePalette(
    primary: Color(0xFF007AFF),
    background: Color(0xFF000000),
    surface: Color(0xFF000000),
    surfaceVariant: Color(0xFF121212),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    accent: Color(0xFF32D74B),
    border: Color(0xFF1C1C1E),
    error: Color(0xFFFF453A),
    success: Color(0xFF32D74B),
    warning: Color(0xFFFF9F0A),
    info: Color(0xFF64D2FF),
    brightness: Brightness.dark,
  );

  static const ThemePalette carbon = ThemePalette(
    primary: Color(0xFFF2F2F2),
    background: Color(0xFF2B2B2B),
    surface: Color(0xFF333333),
    surfaceVariant: Color(0xFF3D3D3D),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFF919191),
    accent: Color(0xFF616161),
    border: Color(0xFF3D3D3D),
    error: Color(0xFFB00020),
    success: Color(0xFF00C853),
    warning: Color(0xFFFFAB00),
    info: Color(0xFF2979FF),
    brightness: Brightness.dark,
  );

  static const ThemePalette retro = ThemePalette(
    primary: Color(0xFFD4A373),
    background: Color(0xFFFAEDCD),
    surface: Color(0xFFFEFAE0),
    surfaceVariant: Color(0xFFE9EDC9),
    textPrimary: Color(0xFF606C38),
    textSecondary: Color(0xFF283618),
    accent: Color(0xFFBC6C25),
    border: Color(0xFFE9EDC9),
    error: Color(0xFFD62828),
    success: Color(0xFF386641),
    warning: Color(0xFFF77F00),
    info: Color(0xFF003049),
    brightness: Brightness.light,
  );

  static const ThemePalette deepSea = ThemePalette(
    primary: Color(0xFF0077B6),
    background: Color(0xFF03045E),
    surface: Color(0xFF023E8A),
    surfaceVariant: Color(0xFF0096C7),
    textPrimary: Color(0xFFCAF0F8),
    textSecondary: Color(0xFF90E0EF),
    accent: Color(0xFF48CAE4),
    border: Color(0xFF0096C7),
    error: Color(0xFFD00000),
    success: Color(0xFF40916C),
    warning: Color(0xFFFFB703),
    info: Color(0xFF00B4D8),
    brightness: Brightness.dark,
  );

  static const ThemePalette marsh = ThemePalette(
    primary: Color(0xFF6B705C),
    background: Color(0xFFCB997E),
    surface: Color(0xFFDDBEA9),
    surfaceVariant: Color(0xFFFFE8D6),
    textPrimary: Color(0xFF3F4238),
    textSecondary: Color(0xFF6B705C),
    accent: Color(0xFFA5A58D),
    border: Color(0xFFFFE8D6),
    error: Color(0xFF9B2226),
    success: Color(0xFF2D6A4F),
    warning: Color(0xFFF9A825),
    info: Color(0xFF457B9D),
    brightness: Brightness.light,
  );

  static const ThemePalette nautical = ThemePalette(
    primary: Color(0xFF003049),
    background: Color(0xFFFDF0D5),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFC1121F),
    textPrimary: Color(0xFF003049),
    textSecondary: Color(0xFF669BBC),
    accent: Color(0xFFC1121F),
    border: Color(0xFFFDF0D5),
    error: Color(0xFF780000),
    success: Color(0xFF386641),
    warning: Color(0xFFF77F00),
    info: Color(0xFF669BBC),
    brightness: Brightness.light,
  );

  static const ThemePalette serika = ThemePalette(
    primary: Color(0xFFE2B714),
    background: Color(0xFF323437),
    surface: Color(0xFF2C2E31),
    surfaceVariant: Color(0xFF3E4144),
    textPrimary: Color(0xFFD1D0C5),
    textSecondary: Color(0xFF646669),
    accent: Color(0xFFE2B714),
    border: Color(0xFF3E4144),
    error: Color(0xFFCA4754),
    success: Color(0xFF79A617),
    warning: Color(0xFFD1B000),
    info: Color(0xFF1793D1),
    brightness: Brightness.dark,
  );

  static const ThemePalette tokyoNight = ThemePalette(
    primary: Color(0xFF7AA2F7),
    background: Color(0xFF1A1B26),
    surface: Color(0xFF24283B),
    surfaceVariant: Color(0xFF414868),
    textPrimary: Color(0xFFC0CAF5),
    textSecondary: Color(0xFF9ECE6A),
    accent: Color(0xFFBB9AF7),
    border: Color(0xFF414868),
    error: Color(0xFFF7768E),
    success: Color(0xFF9ECE6A),
    warning: Color(0xFFE0AF68),
    info: Color(0xFF7DCFFF),
    brightness: Brightness.dark,
  );

  static const ThemePalette neon = ThemePalette(
    primary: Color(0xFF00FF00),
    background: Color(0xFF000000),
    surface: Color(0xFF111111),
    surfaceVariant: Color(0xFF222222),
    textPrimary: Color(0xFF00FF00),
    textSecondary: Color(0xFFFF00FF),
    accent: Color(0xFF00FFFF),
    border: Color(0xFF222222),
    error: Color(0xFFFF0000),
    success: Color(0xFF00FF00),
    warning: Color(0xFFFFFF00),
    info: Color(0xFF00FFFF),
    brightness: Brightness.dark,
  );

  static const ThemePalette gruvbox = ThemePalette(
    primary: Color(0xFFFABD2F),
    background: Color(0xFF282828),
    surface: Color(0xFF3C3836),
    surfaceVariant: Color(0xFF504945),
    textPrimary: Color(0xFFEBDBB2),
    textSecondary: Color(0xFFA89984),
    accent: Color(0xFF8EC07C),
    border: Color(0xFF504945),
    error: Color(0xFFFB4934),
    success: Color(0xFFB8BB26),
    warning: Color(0xFFFABD2F),
    info: Color(0xFF83A598),
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
      case ThemeType.rosePine:
        return rosePine;
      case ThemeType.matrix:
        return matrix;
      case ThemeType.sakura:
        return sakura;
      case ThemeType.amoled:
        return amoled;
      case ThemeType.tokyoNight:
        return tokyoNight;
      case ThemeType.carbon:
        return carbon;
      case ThemeType.serika:
        return serika;
      case ThemeType.retro:
        return retro;
      case ThemeType.nautical:
        return nautical;
      case ThemeType.deepSea:
        return deepSea;
      case ThemeType.marsh:
        return marsh;
      case ThemeType.neon:
        return neon;
      case ThemeType.gruvbox:
        return gruvbox;
    }
  }
}
