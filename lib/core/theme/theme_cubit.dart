import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_config.dart';

class ThemeState {
  final ThemeType themeType;
  final ThemePalette palette;

  const ThemeState({
    required this.themeType,
    required this.palette,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      themeType: ThemeType.dark,
      palette: ThemePalette.dark,
    );
  }

  ThemeState copyWith({ThemeType? themeType, ThemePalette? palette}) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      palette: palette ?? this.palette,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'pref_theme_type';

  ThemeCubit() : super(ThemeState.initial()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < ThemeType.values.length) {
        final themeType = ThemeType.values[themeIndex];
        emit(ThemeState(
          themeType: themeType,
          palette: ThemePalette.fromType(themeType),
        ));
      }
    } catch (_) {
      // Fallback to initial if failed
    }
  }

  Future<void> setTheme(ThemeType themeType) async {
    emit(ThemeState(
      themeType: themeType,
      palette: ThemePalette.fromType(themeType),
    ));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, themeType.index);
    } catch (_) {}
  }
}
