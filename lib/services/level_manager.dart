/// Unified level rules for every category.
class LevelManager {
  LevelManager._();

  static const int levelsPerCategory = 3;
  static const int questionsPerLevel = 3;
  static const int questionsPerCategory = levelsPerCategory * questionsPerLevel;

  static bool isValidLevel(int level) =>
      level >= 1 && level <= levelsPerCategory;

  static String levelLabel(int level) => 'Level $level';

  /// Timer duration scales with difficulty (seconds).
  static int timerSecondsForLevel(int level) {
    switch (level) {
      case 1:
        return 20;
      case 2:
        return 15;
      case 3:
        return 12;
      default:
        return 15;
    }
  }
}
