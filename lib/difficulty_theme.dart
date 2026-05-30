import 'package:flutter/material.dart';

import 'models/difficulty.dart';

/// Visual styling for difficulty badges (matches design mockups).
class DifficultyTheme {
  DifficultyTheme._();

  static Color badgeColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
      case Difficulty.moderate:
        return const Color(0xFFFF8A00);
      case Difficulty.hard:
        return const Color(0xFFE53935);
    }
  }

  static Color badgeTextColor(Difficulty difficulty) => Colors.white;

  static List<BoxShadow> badgeShadow(Difficulty difficulty) => [
        BoxShadow(
          color: badgeColor(difficulty).withValues(alpha: 0.45),
          blurRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];
}
