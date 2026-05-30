import '../models/difficulty.dart';

/// Unified level rules for every category.
class LevelManager {
  LevelManager._();

  static const int levelsPerCategory = 3;
  static const int questionsPerLevel = 3;
  static const int questionsPerCategory = levelsPerCategory * questionsPerLevel;

  static bool isValidLevel(int level) =>
      level >= 1 && level <= levelsPerCategory;

  static String levelLabel(int level) => 'Level $level';

  static const List<Difficulty> difficultiesPerLevel = [
    Difficulty.easy,
    Difficulty.moderate,
    Difficulty.hard,
  ];

  /// Timer duration scales with difficulty (seconds).
  static int timerSecondsForDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 20;
      case Difficulty.moderate:
        return 15;
      case Difficulty.hard:
        return 12;
    }
  }
}
