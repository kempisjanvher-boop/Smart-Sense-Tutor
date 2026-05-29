import 'package:flutter/material.dart';

import '../core/app_categories.dart';

/// Visual palette for each lesson category (headers, cards, level map, gameplay).
class CategoryVisualTheme {
  const CategoryVisualTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.titleText,
    required this.levelNodeColors,
    this.starColor = const Color(0xFFFFD026),
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
    return _themes[AppCategories.normalize(category)] ??
        _themes[AppCategories.objectsAndIdeas]!;
  }

  static const Map<String, CategoryVisualTheme> _themes = {
    AppCategories.techAndTradition: CategoryVisualTheme(
      primary: Color(0xFF0096C7),
      secondary: Color(0xFF023E8A),
      accent: Color(0xFF48CAE4),
      surface: Color(0xFFE8F8FC),
      titleText: Color(0xFF023E8A),
      levelNodeColors: [
        Color(0xFF023E8A),
        Color(0xFF0096C7),
        Color(0xFF48CAE4),
      ],
    ),
    AppCategories.financeAndPhysics: CategoryVisualTheme(
      primary: Color(0xFF1B7A4E),
      secondary: Color(0xFF0D3320),
      accent: Color(0xFFD4AF37),
      surface: Color(0xFFE8F5EE),
      titleText: Color(0xFF0D3320),
      levelNodeColors: [
        Color(0xFF0D3320),
        Color(0xFF1B7A4E),
        Color(0xFFD4AF37),
      ],
      starColor: Color(0xFFD4AF37),
    ),
    AppCategories.objectsAndIdeas: CategoryVisualTheme(
      primary: Color(0xFF7B5EBF),
      secondary: Color(0xFF5B3F9E),
      accent: Color(0xFFC4B5FD),
      surface: Color(0xFFF3EFFF),
      titleText: Color(0xFF3D2A6E),
      levelNodeColors: [
        Color(0xFF5B3F9E),
        Color(0xFF7B5EBF),
        Color(0xFFC4B5FD),
      ],
    ),
    AppCategories.lawAndStructures: CategoryVisualTheme(
      primary: Color(0xFF6B4423),
      secondary: Color(0xFF4A2F18),
      accent: Color(0xFFC9A227),
      surface: Color(0xFFF5E6C8),
      titleText: Color(0xFF3D2914),
      levelNodeColors: [
        Color(0xFF4A2F18),
        Color(0xFF6B4423),
        Color(0xFFC9A227),
      ],
      starColor: Color(0xFFC9A227),
    ),
    AppCategories.attributesAndEvaluation: CategoryVisualTheme(
      primary: Color(0xFFE85D75),
      secondary: Color(0xFFB83B52),
      accent: Color(0xFFFFB4C0),
      surface: Color(0xFFFFF0F3),
      titleText: Color(0xFF7A1F32),
      levelNodeColors: [
        Color(0xFFB83B52),
        Color(0xFFE85D75),
        Color(0xFFFFB4C0),
      ],
    ),
    AppCategories.actionsAndMovement: CategoryVisualTheme(
      primary: Color(0xFFE85D04),
      secondary: Color(0xFFC2410C),
      accent: Color(0xFFFDBA74),
      surface: Color(0xFFFFF7ED),
      titleText: Color(0xFF7C2D12),
      levelNodeColors: [
        Color(0xFFC2410C),
        Color(0xFFE85D04),
        Color(0xFFFB923C),
      ],
    ),
    AppCategories.directionsAndSpace: CategoryVisualTheme(
      primary: Color(0xFF4F46E5),
      secondary: Color(0xFF3730A3),
      accent: Color(0xFF818CF8),
      surface: Color(0xFFEEF2FF),
      titleText: Color(0xFF312E81),
      levelNodeColors: [
        Color(0xFF3730A3),
        Color(0xFF4F46E5),
        Color(0xFF93C5FD),
      ],
    ),
  };
}
