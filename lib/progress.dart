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

  static final Map<String, Map<int, int>> levelStars = {};

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

  static int getTotalCompletedAll() {
    return completedLessons.values.fold(0, (a, b) => a + b);
  }

  static bool isCategoryCompleted(String category) {
    final done = completedLessons[category] ?? 0;
    final total = totalLessons[category] ?? 1;

    return done >= total;
  }

  static int getTotalInProgress() {
    int count = 0;

    for (final category in totalLessons.keys) {
      final completed = completedLessons[category] ?? 0;
      final total = totalLessons[category] ?? 0;

      // Started but not finished
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

    for (final category in levelStars.values) {
      total += category.values.fold(0, (a, b) => a + b);
    }

    return total;
  }

  static int getPerfectScores() {
    int count = 0;

    for (final category in levelStars.values) {
      for (final stars in category.values) {
        if (stars == 3) {
          count++;
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
    // Replace with real streak tracking later
    return getTotalInProgress() >= 7;
  }

  // =========================
  // ACHIEVEMENTS
  // =========================

  static int getAchievementsUnlockedCount() {
    int count = 0;

    // Achievement 1:
    // Complete at least one lesson
    if (hasCompletedAtLeastOneLesson()) {
      count++;
    }

    // Achievement 2:
    // Get one perfect score
    if (getPerfectScores() >= 1) {
      count++;
    }

    // Achievement 3:
    // Maintain a week streak
    if (hasWeekStreak()) {
      count++;
    }

    // Achievement 4:
    // Complete 3 categories
    if (getCategoriesCompleted() >= 3) {
      count++;
    }

    return count;
  }
}