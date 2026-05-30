import '../core/app_categories.dart';
import '../models/difficulty.dart';
import '../models/quiz_question.dart';
import 'level_manager.dart';
import 'question_generator.dart';
import 'wsd_dataset_loader.dart';

/// Facade for the centralized quiz system. Initialize once at app start.
class QuizEngine {
  QuizEngine._();

  static final QuizEngine instance = QuizEngine._();

  final QuestionGenerator _generator = QuestionGenerator();
  bool _initialized = false;
  final int _sessionSeed = DateTime.now().microsecondsSinceEpoch;
  final Map<String, _CategorySessionState> _categorySessions = {};

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

    List<QuizQuestion> questions;
    try {
      questions = await _generator.generate(
        category: normalized,
        level: level,
        difficulty: difficulty,
        excludeRecordIds: session.usedRecordIdsFor(difficulty),
        avoidWord: session.lastWord,
        seed: _sessionSeed ^ normalized.hashCode ^ difficulty.hashCode ^ level.hashCode,
      );
    } on StateError {
      // Pool exhausted (or too small) under the current exclude set.
      // Reset this difficulty pool and try again.
      session.reset(difficulty);
      questions = await _generator.generate(
        category: normalized,
        level: level,
        difficulty: difficulty,
        excludeRecordIds: session.usedRecordIdsFor(difficulty),
        avoidWord: session.lastWord,
        seed: _sessionSeed ^ normalized.hashCode ^ difficulty.hashCode ^ level.hashCode,
      );
    }

    for (final q in questions) {
      session.markUsed(difficulty, q.sourceRecordId);
      session.lastWord = q.word.toLowerCase();
    }

    // If we still ended up generating from a tiny pool and repeated within the
    // same level (rare), keep the "no consecutive duplicate word" invariant.
    // Generator already avoids this; this is just a final safety check.
    for (var i = 1; i < questions.length; i++) {
      if (questions[i].word.toLowerCase() == questions[i - 1].word.toLowerCase()) {
        questions.shuffle();
        break;
      }
    }

    return questions;
  }

  List<String> get allCategories => AppCategories.all;
}

class _CategorySessionState {
  final Map<Difficulty, Set<int>> _usedByDifficulty = {
    Difficulty.easy: <int>{},
    Difficulty.moderate: <int>{},
    Difficulty.hard: <int>{},
  };

  String? lastWord;

  Set<int> usedRecordIdsFor(Difficulty difficulty) => _usedByDifficulty[difficulty]!;

  void markUsed(Difficulty difficulty, int recordId) {
    _usedByDifficulty[difficulty]!.add(recordId);
  }

  void reset(Difficulty difficulty) {
    _usedByDifficulty[difficulty]!.clear();
  }
}
