import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_config.dart';
import '../theme/theme_cubit.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ThemeType.values.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final type = ThemeType.values[index];
                  final palette = ThemePalette.fromType(type);
                  final isSelected = state.themeType == type;

                  return GestureDetector(
                    onTap: () => context.read<ThemeCubit>().setTheme(type),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? palette.primary : palette.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: palette.primary,
                              shape: BoxShape.circle,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 20, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getName(type),
                            style: TextStyle(
                              fontSize: 12,
                              color: palette.textPrimary,
                              fontWeight:
                                  isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _getName(ThemeType type) {
    switch (type) {
      case ThemeType.vscode:
        return 'VS Code';
      case ThemeType.midnight:
        return 'Midnight';
      case ThemeType.solarized:
        return 'Solarized';
      case ThemeType.cyberpunk:
        return 'Cyberpunk';
      case ThemeType.dark:
        return 'Standard';
    }
  }
}
