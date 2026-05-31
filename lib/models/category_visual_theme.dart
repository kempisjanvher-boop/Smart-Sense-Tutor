import 'package:flutter/material.dart';

import '../core/app_categories.dart';
import '../core/app_palette.dart';

/// Visual palette for lesson categories — unified whitish style.
class CategoryVisualTheme {
  const CategoryVisualTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.titleText,
    required this.levelNodeColors,
    this.starColor = AppPalette.star,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color titleText;
  final List<Color> levelNodeColors;
  final Color starColor;

  Color get onPrimary => Colors.white;

  Color levelNodeColor(int level) {
    final index = (level - 1).clamp(0, levelNodeColors.length - 1);
    return levelNodeColors[index];
  }

  static CategoryVisualTheme forCategory(String category) {
    return _themes[AppCategories.normalize(category)] ?? _default;
  }

  static const CategoryVisualTheme _default = CategoryVisualTheme(
    primary: AppPalette.navy,
    secondary: AppPalette.navyDark,
    accent: AppPalette.accent,
    surface: AppPalette.surface,
    titleText: AppPalette.navy,
    levelNodeColors: [
      AppPalette.navyDark,
      AppPalette.navy,
      AppPalette.accent,
    ],
  );

  static final Map<String, CategoryVisualTheme> _themes = {
    for (final name in AppCategories.all) name: _default,
  };
}
