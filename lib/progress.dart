import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/difficulty.dart';

class ProgressService {
  // Singleton pattern instantiation to keep state persistent across screens
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================
  // COMPLETION DATA
  // =========================
  final Map<String, int> completedLessons = {};

  final Map<String, int> totalLessons = {
    "Objects & Ideas": 3,
    "Tech & Tradition": 3,
    "Finance & Physics": 3,
    "All About Me...": 3,
    "Feelings": 3,
    "Greetings": 3,
    "Settings": 3,
    "Law & Structures": 3,
    "Attributes & Evaluation": 3,
    "Action & Movement": 3,
    "Directions & Space": 3,
  };

  // =========================
  // STARS DATA
  // =========================
  /// category -> level -> difficulty -> stars
  final Map<String, Map<int, Map<Difficulty, int>>> levelStars = {};

  // =========================
  // LEVEL UNLOCK SYSTEM
  // =========================
  final Map<String, int> unlockedLevel = {
    "Objects & Ideas": 1,
    "Tech & Tradition": 1,
    "Finance & Physics": 1,
    "All About Me...": 1,
    "Feelings": 1,
    "Greetings": 1,
    "Settings": 1,
    "Law & Structures": 1,
    "Attributes & Evaluation": 1,
    "Action & Movement": 1,
    "Directions & Space": 1,
  };

  // =========================
  // FIREBASE CLOUD SYNC LOGIC
  // =========================

  /// Converts the current instance game save metrics into a Firestore compatible Map
  Map<String, dynamic> toMap() {
    Map<String, dynamic> serializedStars = {};

    levelStars.forEach((category, levelMap) {
      Map<String, dynamic> serializedLevels = {};
      levelMap.forEach((levelNumber, difficultyMap) {
        Map<String, int> serializedDifficulties = {};
        difficultyMap.forEach((difficultyEnum, starValue) {
          // Uses the built-in .name property ('easy', 'moderate', 'hard')
          serializedDifficulties[difficultyEnum.name] = starValue;
        });
        serializedLevels[levelNumber.toString()] = serializedDifficulties;
      });
      serializedStars[category] = serializedLevels;
    });

    return {
      'completedLessons': completedLessons,
      'unlockedLevel': unlockedLevel,
      'levelStars': serializedStars,
      'lastSavedTimestamp': FieldValue.serverTimestamp(),
    };
  }

  /// Populates the instance game save memory indices from a Firestore Document Map
  void fromMap(Map<String, dynamic> map) {
    // 1. Restore completed lessons list
    completedLessons.clear();
    if (map['completedLessons'] != null) {
      (map['completedLessons'] as Map<String, dynamic>).forEach((key, value) {
        completedLessons[key] = (value as num).toInt();
      });
    }

    // 2. Restore unlocked levels data
    if (map['unlockedLevel'] != null) {
      (map['unlockedLevel'] as Map<String, dynamic>).forEach((key, value) {
        unlockedLevel[key] = (value as num).toInt();
      });
    }

    // 3. Restore heavily nested star system maps
    levelStars.clear();
    if (map['levelStars'] != null) {
      (map['levelStars'] as Map<String, dynamic>).forEach((categoryKey, levelMapData) {
        Map<int, Map<Difficulty, int>> levelMap = {};

        (levelMapData as Map<String, dynamic>).forEach((levelStrKey, difficultyMapData) {
          int? levelInt = int.tryParse(levelStrKey);
          if (levelInt != null) {
            Map<Difficulty, int> difficultyMap = {};
            (difficultyMapData as Map<String, dynamic>).forEach((diffStrKey, starValue) {

              // Matches string key back to the specific enum variant safely
              Difficulty diffEnum = Difficulty.values.firstWhere(
                    (d) => d.name == diffStrKey,
                orElse: () => Difficulty.easy,
              );

              difficultyMap[diffEnum] = (starValue as num).toInt();
            });
            levelMap[levelInt] = difficultyMap;
          }
        });

        levelStars[categoryKey] = levelMap;
      });
    }
  }

  /// Pushes local game variables up to the user's explicit profile document ID matching their UID
  Future<void> uploadProgressToCloud() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _db.collection('users').doc(currentUser.uid).set(
        toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error cloud saving progress data: $e");
    }
  }

  /// Pulls remote game data down from Firestore and overrides local memory indices
  Future<void> downloadProgressFromCloud() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      DocumentSnapshot snapshot = await _db.collection('users').doc(currentUser.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        fromMap(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching online save record: $e");
    }
  }

  // =========================
  // COMPLETION LOGIC
  // =========================

  int getCompleted(String category) => completedLessons[category] ?? 0;

  void addCompletion(String category) {
    final total = totalLessons[category] ?? 3;
    final current = completedLessons[category] ?? 0;
    if (current < total) {
      completedLessons[category] = current + 1;
      uploadProgressToCloud(); // Auto-saves to database
    }
  }

  int getTotalCompletedAll() => completedLessons.values.fold(0, (a, b) => a + b);

  bool isCategoryCompleted(String category) {
    final done = completedLessons[category] ?? 0;
    final total = totalLessons[category] ?? 1;
    return done >= total;
  }

  int getTotalInProgress() {
    int count = 0;
    for (final category in totalLessons.keys) {
      final completed = completedLessons[category] ?? 0;
      final total = totalLessons[category] ?? 0;
      if (completed > 0 && completed < total) count++;
    }
    return count;
  }

  int getCategoriesCompleted() {
    int count = 0;
    for (final category in totalLessons.keys) {
      if (isCategoryCompleted(category)) count++;
    }
    return count;
  }

  bool hasCompletedAtLeastOneLesson() => completedLessons.values.any((value) => value > 0);

  // =========================
  // LEVEL SYSTEM
  // =========================

  int getUnlockedLevel(String category) => unlockedLevel[category] ?? 1;

  void unlockNext(String category, int level) {
    final current = unlockedLevel[category] ?? 1;
    if (level < current || current >= 3) return;

    if (completedDifficultiesCount(category, level) >= 3) {
      unlockedLevel[category] = current + 1;
      uploadProgressToCloud();
    }
  }

  // =========================
  // STARS SYSTEM
  // =========================

  int getStars(String category, int level, Difficulty difficulty) {
    return levelStars[category]?[level]?[difficulty] ?? 0;
  }

  void setStars(String category, int level, Difficulty difficulty, int stars) {
    levelStars.putIfAbsent(category, () => {});
    levelStars[category]!.putIfAbsent(level, () => {});

    final current = levelStars[category]![level]![difficulty] ?? 0;

    if (stars > current) {
      levelStars[category]![level]![difficulty] = stars;
      uploadProgressToCloud();
    }
  }

  int completedDifficultiesCount(String category, int level) {
    final byDifficulty = levelStars[category]?[level];
    if (byDifficulty == null) return 0;
    return byDifficulty.values.where((stars) => stars >= 1).length;
  }

  bool isDifficultyUnlocked(String category, int level, Difficulty difficulty) {
    if (level > getUnlockedLevel(category)) return false;

    switch (difficulty) {
      case Difficulty.easy:
        return true;
      case Difficulty.moderate:
        return getStars(category, level, Difficulty.easy) >= 1;
      case Difficulty.hard:
        return getStars(category, level, Difficulty.moderate) >= 1;
    }
  }

  int getTotalStars() {
    int total = 0;
    for (final levels in levelStars.values) {
      for (final difficulties in levels.values) {
        total += difficulties.values.fold(0, (a, b) => a + b);
      }
    }
    return total;
  }

  int getPerfectScores() {
    int count = 0;
    for (final levels in levelStars.values) {
      for (final difficulties in levels.values) {
        for (final stars in difficulties.values) {
          if (stars == 3) count++;
        }
      }
    }
    return count;
  }

  // =========================
  // STREAK SYSTEM
  // =========================

  bool hasWeekStreak() => getTotalInProgress() >= 7;

  // =========================
  // ACHIEVEMENTS
  // =========================

  int getAchievementsUnlockedCount() {
    int count = 0;
    if (hasCompletedAtLeastOneLesson()) count++;
    if (getPerfectScores() >= 1) count++;
    if (hasWeekStreak()) count++;
    if (getCategoriesCompleted() >= 3) count++;
    return count;
  }
}