import 'core/app_categories.dart';

class ProgressService {
  static final Map<String, int> completedLessons = {};

  static final Map<String, int> totalLessons = {
    for (final category in AppCategories.all) category: 3,
  };

  static final Map<String, Map<int, int>> levelStars = {};

  // =========================
  // COMPLETION LOGIC
  // =========================

  static int getCompleted(String category) {
    return completedLessons[category] ?? 0;
  }

  static int getTotalInProgress() {
    return completedLessons.values.fold(0, (a, b) => a + b);
  }

  static int getLessonsInProgressCount() {
    var count = 0;
    for (final category in AppCategories.all) {
      final done = getCompleted(category);
      final total = totalLessons[category] ?? 3;
      if (done > 0 && done < total) {
        count++;
      }
    }
    return count;
  }

  static void addCompletion(String category) {
    completedLessons[category] =
        (completedLessons[category] ?? 0) + 1;
  }

  static bool isCategoryCompleted(String category) {
    final done = completedLessons[category] ?? 0;
    final total = totalLessons[category] ?? 3;
    return done >= total;
  }

  static int getTotalCompletedAll() {
    return getTotalInProgress();
  }

  static int getCategoriesCompleted() {
    var count = 0;

    for (final category in AppCategories.all) {
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
    for (final category in AppCategories.all) category: 1,
  };

  static int getUnlockedLevel(String category) {
    return unlockedLevel[category] ?? 1;
  }

  static void unlockNext(String category, int level) {
    final current = unlockedLevel[category] ?? 1;

    if (level >= current && current < 3) {
      unlockedLevel[category] = current + 1;
    }
  }

  // =========================
  // STARS SYSTEM
  // =========================

  static int getStars(String category, int level) {
    return levelStars[category]?[level] ?? 0;
  }

  static void setStars(String category, int level, int stars) {
    levelStars.putIfAbsent(category, () => {});
    levelStars[category]![level] = stars;
  }

  static int getTotalStars() {
    var total = 0;

    for (final cat in levelStars.values) {
      total += cat.values.fold(0, (a, b) => a + b);
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
    var unlocked = 0;
    if (hasWeekStreak()) unlocked++;
    if (getPerfectScores() >= 10) unlocked++;
    if (hasCompletedAtLeastOneLesson()) unlocked++;
    return unlocked;
  }
}
