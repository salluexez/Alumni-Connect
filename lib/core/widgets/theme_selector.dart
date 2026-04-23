import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_config.dart';
import '../theme/theme_cubit.dart';
import '../constants/app_text_styles.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ThemeType.values.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final type = ThemeType.values[index];
              final palette = ThemePalette.fromType(type);
              final isSelected = state.themeType == type;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => context.read<ThemeCubit>().setTheme(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: palette.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected 
                              ? palette.primary 
                              : palette.textSecondary.withValues(alpha: 0.2),
                          width: isSelected ? 3 : 1.5,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: palette.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: palette.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              width: 30,
                              height: 8,
                              decoration: BoxDecoration(
                                color: palette.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Center(
                              child: Icon(Icons.check_circle, 
                                  color: Colors.white, size: 24),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getName(type),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary 
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _getName(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return 'Light';
      case ThemeType.dark:
        return 'Dark';
      case ThemeType.monkey:
        return 'Monkey';
      case ThemeType.dracula:
        return 'Dracula';
      case ThemeType.nord:
        return 'Nord';
      case ThemeType.solarizedDark:
        return 'Solarized';
      case ThemeType.midnight:
        return 'Midnight';
      case ThemeType.cyberpunk:
        return 'Cyberpunk';
      case ThemeType.ocean:
        return 'Ocean';
      case ThemeType.espresso:
        return 'Espresso';
      case ThemeType.sunset:
        return 'Sunset';
      case ThemeType.forest:
        return 'Forest';
      case ThemeType.lavender:
        return 'Lavender';
      case ThemeType.rosePine:
        return 'Rose Pine';
      case ThemeType.matrix:
        return 'Matrix';
      case ThemeType.sakura:
        return 'Sakura';
    }
  }
}
