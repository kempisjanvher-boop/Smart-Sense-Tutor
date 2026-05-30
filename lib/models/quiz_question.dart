import 'quiz_option.dart';
import 'difficulty.dart';

/// Runtime question presented in [GameplayScreen].
class QuizQuestion {
  final String word;
  final String sentenceBefore;
  final String sentenceAfter;
  final String category;
  final int level;
  final Difficulty difficulty;
  final int correctIndex;
  final List<QuizOption> options;
  final int sourceRecordId;

  const QuizQuestion({
    required this.word,
    required this.sentenceBefore,
    required this.sentenceAfter,
    required this.category,
    required this.level,
    required this.difficulty,
    required this.correctIndex,
    required this.options,
    required this.sourceRecordId,
  });

  Map<String, dynamic> toLegacyMap() => {
        'word': word,
        'sentenceBefore': sentenceBefore,
        'sentenceAfter': sentenceAfter,
        'category': category,
        'difficulty': difficulty.label,
        'correctIndex': correctIndex,
        'options': options.map((o) => o.toMap()).toList(),
        'sourceRecordId': sourceRecordId,
      };
}
