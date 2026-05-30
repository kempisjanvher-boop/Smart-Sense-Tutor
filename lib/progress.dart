import 'models/difficulty.dart';

class ProgressService {
  // =========================
  // COMPLETION DATA
  // =========================

  static final Map<String, int> completedLessons = {};

  static final Map<String, int> totalLessons = {
    "Objects & Ideas": 3,
    "Tech & Tradition": 3,
    "Finance & Physics": 3,
    "All About Me...": 3,
    "Feelings": 3,
    "Greetings": 3,
    "Settings": 3,
    "Law & Structures": 3,
    "Attributes & Evaluation": 3,
    "Actions & Movement": 3,
    "Directions & Space": 3,
  };

  // =========================
  // STARS DATA
  // =========================

  /// category -> level -> difficulty -> stars
  static final Map<String, Map<int, Map<Difficulty, int>>> levelStars = {};

  // =========================
  // LEVEL UNLOCK SYSTEM
  // =========================

  static final Map<String, int> unlockedLevel = {
    "Objects & Ideas": 1,
    "Tech & Tradition": 1,
    "Finance & Physics": 1,
    "All About Me...": 1,
    "Feelings": 1,
    "Greetings": 1,
    "Settings": 1,
    "Law & Structures": 1,
    "Attributes & Evaluation": 1,
    "Actions & Movement": 1,
    "Directions & Space": 1,
  };

  // =========================
  // COMPLETION LOGIC
  // =========================

  static int getCompleted(String category) {
    return completedLessons[category] ?? 0;
  }

  static void addCompletion(String category) {
    completedLessons[category] =
        (completedLessons[category] ?? 0) + 1;
  }

  /// Total lessons completed across all categories
  static int getTotalCompletedAll() {
    return completedLessons.values.fold(0, (a, b) => a + b);
  }

  static bool isCategoryCompleted(String category) {
    final done = completedLessons[category] ?? 0;
    final total = totalLessons[category] ?? 1;

    return done >= total;
  }

  /// Categories that have been started but not completed
  static int getTotalInProgress() {
    int count = 0;

    for (final category in totalLessons.keys) {
      final completed = completedLessons[category] ?? 0;
      final total = totalLessons[category] ?? 0;

      if (completed > 0 && completed < total) {
        count++;
      }
    }

    return count;
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

  static bool hasCompletedAtLeastOneLesson() {
    return completedLessons.values.any((value) => value > 0);
  }

  // =========================
  // LEVEL SYSTEM
  // =========================

  static int getUnlockedLevel(String category) {
    return unlockedLevel[category] ?? 1;
  }

  /// Unlock next level only when all 3 difficulties
  /// in the current level have at least 1 star.
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

  static int getStars(
      String category,
      int level,
      Difficulty difficulty,
      ) {
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

    final current =
        levelStars[category]![level]![difficulty] ?? 0;

    // Keep highest score only
    if (stars > current) {
      levelStars[category]![level]![difficulty] = stars;
    }
  }

  /// Number of completed difficulties in a level
  static int completedDifficultiesCount(
      String category,
      int level,
      ) {
    final byDifficulty = levelStars[category]?[level];

    if (byDifficulty == null) return 0;

    return byDifficulty.values
        .where((stars) => stars >= 1)
        .length;
  }

  static bool isDifficultyUnlocked(
      String category,
      int level,
      Difficulty difficulty,
      ) {
    if (level > getUnlockedLevel(category)) {
      return false;
    }

    switch (difficulty) {
      case Difficulty.easy:
        return true;

      case Difficulty.moderate:
        return getStars(
          category,
          level,
          Difficulty.easy,
        ) >=
            1;

      case Difficulty.hard:
        return getStars(
          category,
          level,
          Difficulty.moderate,
        ) >=
            1;
    }
  }

  static int getTotalStars() {
    int total = 0;

    for (final levels in levelStars.values) {
      for (final difficulties in levels.values) {
        total += difficulties.values.fold(
          0,
              (a, b) => a + b,
        );
      }
    }

    return total;
  }

  /// Count every difficulty that earned 3 stars
  static int getPerfectScores() {
    int count = 0;

    for (final levels in levelStars.values) {
      for (final difficulties in levels.values) {
        for (final stars in difficulties.values) {
          if (stars == 3) {
            count++;
          }
        }
      }
    }

    return count;
  }

  // =========================
  // STREAK SYSTEM
  // =========================

  static bool hasWeekStreak() {
    // Placeholder logic
    // Replace with actual streak tracking later
    return getTotalInProgress() >= 7;
  }

  // =========================
  // ACHIEVEMENTS
  // =========================

  static int getAchievementsUnlockedCount() {
    int count = 0;

    if (hasCompletedAtLeastOneLesson()) {
      count++;
    }

    if (getPerfectScores() >= 1) {
      count++;
    }

    if (hasWeekStreak()) {
      count++;
    }

    if (getCategoriesCompleted() >= 3) {
      count++;
    }

    return count;
  }
}