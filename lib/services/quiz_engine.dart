import '../core/app_categories.dart';
import '../models/difficulty.dart';
import '../models/quiz_question.dart';
import 'level_manager.dart';
import 'question_generator.dart';
import 'wsd_dataset_loader.dart';
import 'package:flutter/material.dart';
import '../progress.dart';
import '../account/profile.dart';

/// Facade for the centralized quiz system. Initialize once at app start.
class QuizEngine {
  QuizEngine._();

  static final QuizEngine instance = QuizEngine._();

  final QuestionGenerator _generator = QuestionGenerator();
  bool _initialized = false;
  final int _sessionSeed = DateTime.now().microsecondsSinceEpoch;
  final Map<String, _CategorySessionState> _categorySessions = {};

  // Global used words set - tracks ALL words used across the entire session
  // This ensures no word is repeated across any category, level, or difficulty
  final Set<String> _globalUsedWords = {};

  Future<void> initialize() async {
    if (_initialized) return;
    await WsdDatasetLoader.instance.loadAll();
    _initialized = true;
  }

  /// Generates exactly [LevelManager.questionsPerLevel] questions for a level run.
  Future<List<QuizQuestion>> questionsForLevel({
    required String category,
    required int level,
    required Difficulty difficulty,
  }) async {
    await initialize();
    final normalized = AppCategories.normalize(category);
    final session = _categorySessions.putIfAbsent(
      normalized,
          () => _CategorySessionState(),
    );

    List<QuizQuestion> questions = [];
    int attempts = 0;
    const maxAttempts = 5;

    while (attempts < maxAttempts) {
      try {
        // Pass global used words to ensure no repetition across entire session
        questions = await _generator.generate(
          category: normalized,
          level: level,
          difficulty: difficulty,
          globalUsedWords: _globalUsedWords,
          seed: _sessionSeed ^ normalized.hashCode ^ difficulty.hashCode ^ level.hashCode ^ attempts,
        );

        // Deduplicate within the generated questions (keep first occurrence of each word)
        final uniqueQuestions = <QuizQuestion>[];
        final seenWords = <String>{};
        for (final q in questions) {
          final wordLower = q.word.toLowerCase();
          if (!seenWords.contains(wordLower)) {
            seenWords.add(wordLower);
            uniqueQuestions.add(q);
          }
        }
        questions = uniqueQuestions;

        // Check word count - if we have enough unique questions, we're good
        if (questions.length >= LevelManager.questionsPerLevel) {
          // Trim to exact count if we have more
          questions = questions.take(LevelManager.questionsPerLevel).toList();

          // Mark words as used
          for (final q in questions) {
            _globalUsedWords.add(q.word.toLowerCase());
            session.markUsed(level, difficulty, q.sourceRecordId);
            session.lastWord = q.word.toLowerCase();
          }
          break;
        }

        // Not enough unique questions, retry
        attempts++;
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) {
          rethrow;
        }
      }
    }

    // If we still ended up generating from a tiny pool and repeated within the
    // same level (rare), keep the "no consecutive duplicate word" invariant.
    for (var i = 1; i < questions.length; i++) {
      if (questions[i].word.toLowerCase() == questions[i - 1].word.toLowerCase()) {
        questions.shuffle();
        break;
      }
    }

    return questions;
  }

  // ─── NEW METHOD added to fix your compile error ───
  /// Evaluates game results immediately upon quiz completion to trigger achievement banners
  void evaluateAndTriggerAchievements({
    required BuildContext context,
    required String category,
    required int level,
    required int correctAnswers,
    required int totalQuestions,
    required int totalPerfectScoresFromStorage,
    required bool notificationsEnabled,
  }) {
    if (!notificationsEnabled) return;

    final progress = ProgressService();

    // =========================
    // CONQUEROR (FULL LEVEL COMPLETE)
    // =========================
    if (progress.isLevelCompleted(category, level)) {
      NotificationManager.showAchievement(
        context: context,
        title: "Conqueror",
        description: "Completed Level $level",
        badgePath: "asset/gold.png",
        avatarPath: "asset/conqueror.png",
      );
    }

    // =========================
    // ROYAL (PERFECT SCORE MILESTONE)
    // =========================
    if (correctAnswers == totalQuestions) {
      if (totalPerfectScoresFromStorage == 10) {
        Future.delayed(const Duration(milliseconds: 4500), () {
          if (context.mounted) {
            NotificationManager.showAchievement(
              context: context,
              title: "Royal",
              description: "10/10 perfect scores achieved!",
              badgePath: "asset/bronze.png",
              avatarPath: "asset/perfectscore.png",
            );
          }
        });
      }
    }
  }

  List<String> get allCategories => AppCategories.all;

  /// Reset the global used words set (for testing or starting a new game session)
  void resetGlobalUsedWords() {
    _globalUsedWords.clear();
  }

  /// Get the count of globally used words (for debugging/monitoring)
  int get globalUsedWordsCount => _globalUsedWords.length;
}

class _CategorySessionState {
  String? lastWord;

  void markUsed(int level, Difficulty difficulty, int recordId) {}
}