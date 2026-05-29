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

  /// Difficulty progression.
  ///
  /// Note: the current UI exposes only 3 levels per category, so we map them
  /// to a clear progression (Easy → Moderate → Hard). If you later expand the
  /// number of levels, this already supports 1–3 Easy, 4–6 Moderate, 7+ Hard.
  static Difficulty difficultyForLevel(int level) {
    if (level <= 0) return Difficulty.easy;
    if (level <= 3) {
      // With 3-level UI, progress within the first block.
      return switch (level) {
        1 => Difficulty.easy,
        2 => Difficulty.moderate,
        _ => Difficulty.hard,
      };
    }
    if (level <= 6) return Difficulty.moderate;
    return Difficulty.hard;
  }

  /// Timer duration scales with difficulty (seconds).
  static int timerSecondsForLevel(int level) {
    switch (difficultyForLevel(level)) {
      case Difficulty.easy:
        return 20;
      case Difficulty.moderate:
        return 15;
      case Difficulty.hard:
        return 12;
    }
  }
}
