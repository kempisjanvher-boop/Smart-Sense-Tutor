import 'core/app_categories.dart';

class ProgressService {
  static final Map<String, int> completedLessons = {};

  static final Map<String, int> totalLessons = {
    for (final c in AppCategories.all) c: 3,
  };

  static final Map<String, Map<int, int>> levelStars = {};

  static String _key(String category) => AppCategories.normalize(category);

  // =========================
  // COMPLETION LOGIC
  // =========================

  static int getCompleted(String category) {
    return completedLessons[_key(category)] ?? 0;
  }

  static int getTotalInProgress() {
    return completedLessons.values.fold(0, (a, b) => a + b);
  }

  static void addCompletion(String category) {
    final key = _key(category);
    final cap = totalLessons[key] ?? 3;
    final current = completedLessons[key] ?? 0;
    if (current < cap) {
      completedLessons[key] = current + 1;
    }
  }

  static bool isCategoryCompleted(String category) {
    final done = getCompleted(category);
    final total = totalLessons[_key(category)] ?? 3;
    return done >= total;
  }

  static int getTotalCompletedAll() {
    int total = 0;
    for (final category in totalLessons.keys) {
      total += getCompleted(category);
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
  // LEVEL SYSTEM — 3 levels per category
  // =========================

  static final Map<String, int> unlockedLevel = {
    for (final c in AppCategories.all) c: 1,
  };

  static int getUnlockedLevel(String category) {
    return unlockedLevel[_key(category)] ?? 1;
  }

  static void unlockNext(String category, int level) {
    final key = _key(category);
    final current = unlockedLevel[key] ?? 1;
    if (level >= current && current < 3) {
      unlockedLevel[key] = current + 1;
    }
  }

  // =========================
  // STARS SYSTEM
  // =========================

  static int getStars(String category, int level) {
    return levelStars[_key(category)]?[level] ?? 0;
  }

  static void setStars(String category, int level, int stars) {
    final key = _key(category);
    levelStars.putIfAbsent(key, () => {});
    levelStars[key]![level] = stars;
  }

  static int getTotalStars() {
    int total = 0;
    for (final cat in levelStars.values) {
      total += cat.values.fold(0, (a, b) => a + b);
    }
    return total;
  }
}
