import 'models/difficulty.dart';

class ProgressService {
  static final Map<String, int> completedLessons = {};

  static final Map<String, int> totalLessons = {
    "Objects & Ideas": 3,
    "Tech & Tradition": 3,
    "Finance & Physics": 3,
    "All About Me...": 3,
    "Feelings": 3,
    "Greetings": 3,
    "Settings": 3,
  };

  /// Stars per category → level → difficulty (easy / moderate / hard).
  static final Map<String, Map<int, Map<Difficulty, int>>> levelStars = {};

  // =========================
  // COMPLETION LOGIC
  // =========================

  static int getCompleted(String category) {
    return completedLessons[category] ?? 0;
  }

  static int getTotalInProgress() {
    return completedLessons.values.fold(0, (a, b) => a + b);
  }

  static void addCompletion(String category) {
    completedLessons[category] =
        (completedLessons[category] ?? 0) + 1;
  }

  static bool isCategoryCompleted(String category) {
    final done = completedLessons[category] ?? 0;
    final total = totalLessons[category] ?? 1;
    return done >= total;
  }

  static int getTotalCompletedAll() {
    int total = 0;

    for (final category in totalLessons.keys) {
      if (isCategoryCompleted(category)) {
        total++;
      }
    }

    return total;
  }

  static int getCategoriesCompleted() {
    int count = 0;

    for (final category in totalLessons.keys) {
      if (isCategoryCompleted(category)) {
        count++;
      }
    }

    return count;
  }

  // =========================
  // LEVEL SYSTEM
  // =========================

  static final Map<String, int> unlockedLevel = {
    "Objects & Ideas": 1,
    "Tech & Tradition": 1,
    "Finance & Physics": 1,
    "All About Me...": 1,
    "Feelings": 1,
    "Greetings": 1,
    "Settings": 1,
  };

  static int getUnlockedLevel(String category) {
    return unlockedLevel[category] ?? 1;
  }

  static void unlockNext(String category, int level) {
    final current = unlockedLevel[category] ?? 1;
    if (level < current || current >= 3) return;
    if (completedDifficultiesCount(category, level) >= 3) {
      unlockedLevel[category] = current + 1;
    }
  }

  // =========================
  // STARS SYSTEM
  // =========================

  static int getStars(String category, int level, Difficulty difficulty) {
    return levelStars[category]?[level]?[difficulty] ?? 0;
  }

  static void setStars(
    String category,
    int level,
    Difficulty difficulty,
    int stars,
  ) {
    levelStars.putIfAbsent(category, () => {});
    levelStars[category]!.putIfAbsent(level, () => {});
    final current = levelStars[category]![level]![difficulty] ?? 0;
    if (stars > current) {
      levelStars[category]![level]![difficulty] = stars;
    }
  }

  /// How many difficulties (0–3) have been completed for this level.
  static int completedDifficultiesCount(String category, int level) {
    final byDifficulty = levelStars[category]?[level];
    if (byDifficulty == null) return 0;
    return byDifficulty.values.where((s) => s >= 1).length;
  }

  static bool isDifficultyUnlocked(
    String category,
    int level,
    Difficulty difficulty,
  ) {
    if (level > getUnlockedLevel(category)) return false;
    if (difficulty == Difficulty.easy) return true;
    if (difficulty == Difficulty.moderate) {
      return getStars(category, level, Difficulty.easy) >= 1;
    }
    return getStars(category, level, Difficulty.moderate) >= 1;
  }

  static int getTotalStars() {
    int total = 0;

    for (final levels in levelStars.values) {
      for (final difficulties in levels.values) {
        total += difficulties.values.fold(0, (a, b) => a + b);
      }
    }

    return total;
  }

  // =========================
  // ACHIEVEMENTS
  // =========================

  static int _perfectScores = 0;

  static int getPerfectScores() => _perfectScores;

  static void recordPerfectScore() {
    _perfectScores++;
  }

  static bool hasCompletedAtLeastOneLesson() {
    return completedLessons.values.any((count) => count > 0);
  }

  static bool hasWeekStreak() => false;

  static int getAchievementsUnlockedCount() {
    int unlocked = 0;
    if (hasWeekStreak()) unlocked++;
    if (getPerfectScores() >= 10) unlocked++;
    if (hasCompletedAtLeastOneLesson()) unlocked++;
    return unlocked;
  }
}