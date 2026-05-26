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
    int total = 0;

    for (final cat in levelStars.values) {
      total += cat.values.fold(0, (a, b) => a + b);
    }

    return total;
  }
}