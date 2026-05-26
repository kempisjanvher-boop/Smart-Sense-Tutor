import 'package:flutter_test/flutter_test.dart';
import 'package:smart_sense_tutor/core/app_categories.dart';
import 'package:smart_sense_tutor/services/level_manager.dart';
import 'package:smart_sense_tutor/services/question_generator.dart';
import 'package:smart_sense_tutor/services/wsd_dataset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WsdDatasetLoader.instance.loadAll();
  });

  test('generates exactly 3 unique questions per category and level', () async {
    final generator = QuestionGenerator();

    for (final category in AppCategories.all) {
      for (var level = 1; level <= LevelManager.levelsPerCategory; level++) {
        final questions = await generator.generate(
          category: category,
          level: level,
          seed: category.hashCode + level,
        );

        expect(questions.length, LevelManager.questionsPerLevel);
        expect(
          questions.map((q) => q.sourceRecordId).toSet().length,
          LevelManager.questionsPerLevel,
          reason: '$category level $level should have unique records',
        );
        for (final q in questions) {
          expect(q.options.length, 3);
          expect(q.correctIndex, inInclusiveRange(0, 2));
        }
      }
    }
  });
}
