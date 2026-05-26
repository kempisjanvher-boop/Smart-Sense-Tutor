import '../core/app_categories.dart';
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

  Future<void> initialize() async {
    if (_initialized) return;
    await WsdDatasetLoader.instance.loadAll();
    _initialized = true;
  }

  /// Generates exactly [LevelManager.questionsPerLevel] questions for a level run.
  Future<List<QuizQuestion>> questionsForLevel({
    required String category,
    required int level,
  }) async {
    await initialize();
    final normalized = AppCategories.normalize(category);
    return _generator.generate(category: normalized, level: level);
  }

  List<String> get allCategories => AppCategories.all;
}
