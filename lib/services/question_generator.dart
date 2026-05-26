import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_categories.dart';
import '../models/quiz_option.dart';
import '../models/quiz_question.dart';
import '../models/wsd_record.dart';
import 'category_theme_registry.dart';
import 'level_manager.dart';
import 'wsd_dataset_loader.dart';

/// Central engine: produces exactly [LevelManager.questionsPerLevel] unique,
/// randomized questions for any category + level (1–3).
class QuestionGenerator {
  QuestionGenerator({WsdDatasetLoader? loader})
      : _loader = loader ?? WsdDatasetLoader.instance;

  final WsdDatasetLoader _loader;

  Future<List<QuizQuestion>> generate({
    required String category,
    required int level,
    int? seed,
  }) async {
    if (!LevelManager.isValidLevel(level)) {
      throw ArgumentError('Level must be 1–3, got $level');
    }

    final normalizedCategory = AppCategories.normalize(category);
    final allRecords = await _loader.loadAll();
    final byWord = <String, List<WsdRecord>>{};
    for (final r in allRecords) {
      byWord.putIfAbsent(r.word, () => []).add(r);
    }

    final poolWords = CategoryThemeRegistry.wordsForCategory(normalizedCategory);
    final senseHints = CategoryThemeRegistry.senseHintsForCategory(normalizedCategory);

    var candidates = allRecords.where((r) => poolWords.contains(r.word)).toList();

    if (senseHints.isNotEmpty) {
      final themed = candidates.where((r) {
        final sense = r.correctSense.toLowerCase();
        return senseHints.any((hint) => sense.contains(hint.toLowerCase()));
      }).toList();
      if (themed.length >= LevelManager.questionsPerLevel * 2) {
        candidates = themed;
      }
    }

    candidates = _filterByDifficulty(candidates, level);
    if (candidates.length < LevelManager.questionsPerLevel) {
      candidates = _filterByDifficulty(
        allRecords.where((r) => poolWords.contains(r.word)).toList(),
        level,
      );
    }
    if (candidates.isEmpty) {
      candidates = List<WsdRecord>.from(allRecords);
    }

    final random = Random(
      seed ??
          DateTime.now().microsecondsSinceEpoch ^
              normalizedCategory.hashCode ^
              level.hashCode,
    );

    candidates.shuffle(random);

    final usedRecordIds = <int>{};
    final usedWords = <String>{};
    final questions = <QuizQuestion>[];

    for (final record in candidates) {
      if (questions.length >= LevelManager.questionsPerLevel) break;
      if (usedRecordIds.contains(record.id)) continue;

      // Prefer unique words per session when possible.
      if (usedWords.contains(record.word) && usedWords.length < poolWords.length) {
        continue;
      }

      final wordRecords = byWord[record.word] ?? [record];
      final senses = <String, String>{};
      for (final wr in wordRecords) {
        senses[wr.correctSense] = wr.definition;
      }
      if (senses.length < 2) continue;

      final question = _buildQuestion(
        record: record,
        senses: senses,
        category: normalizedCategory,
        level: level,
        random: random,
      );
      if (question == null) continue;

      usedRecordIds.add(record.id);
      usedWords.add(record.word);
      questions.add(question);
    }

    // Fallback: relax unique-word rule.
    if (questions.length < LevelManager.questionsPerLevel) {
      final fallback = List<WsdRecord>.from(candidates)..shuffle(random);
      for (final record in fallback) {
        if (questions.length >= LevelManager.questionsPerLevel) break;
        if (usedRecordIds.contains(record.id)) continue;

        final wordRecords = byWord[record.word] ?? [record];
        final senses = <String, String>{};
        for (final wr in wordRecords) {
          senses[wr.correctSense] = wr.definition;
        }
        if (senses.length < 2) continue;

        final question = _buildQuestion(
          record: record,
          senses: senses,
          category: normalizedCategory,
          level: level,
          random: random,
        );
        if (question == null) continue;

        usedRecordIds.add(record.id);
        questions.add(question);
      }
    }

    if (questions.length < LevelManager.questionsPerLevel) {
      throw StateError(
        'Could not generate ${LevelManager.questionsPerLevel} questions for '
        '$normalizedCategory level $level',
      );
    }

    questions.shuffle(random);
    return questions;
  }

  List<WsdRecord> _filterByDifficulty(List<WsdRecord> records, int level) {
    final sorted = List<WsdRecord>.from(records)
      ..sort((a, b) => a.sentence.length.compareTo(b.sentence.length));

    if (sorted.isEmpty) return sorted;

    final third = (sorted.length / 3).ceil().clamp(1, sorted.length);

    switch (level) {
      case 1:
        return sorted.take(third).toList();
      case 2:
        final start = third.clamp(0, sorted.length - 1);
        final end = (third * 2).clamp(start + 1, sorted.length);
        return sorted.sublist(start, end);
      case 3:
        final hardStart = (third * 2).clamp(0, sorted.length - 1);
        return sorted.sublist(hardStart);
      default:
        return sorted;
    }
  }

  QuizQuestion? _buildQuestion({
    required WsdRecord record,
    required Map<String, String> senses,
    required String category,
    required int level,
    required Random random,
  }) {
    final split = _splitSentence(record.sentence, record.word);
    if (split == null) return null;

    final correctDefinition = senses[record.correctSense];
    if (correctDefinition == null || correctDefinition.isEmpty) return null;

    final distractors = senses.entries
        .where((e) => e.key != record.correctSense)
        .map((e) => e.value)
        .toSet()
        .toList();
    distractors.shuffle(random);

    if (distractors.isEmpty) return null;

    final correctText = _formatDefinition(correctDefinition, level);
    final optionEntries = <({String text, IconData icon, bool isCorrect})>[
      (text: correctText, icon: _iconForSense(record.correctSense), isCorrect: true),
      (
        text: _formatDefinition(distractors[0], level),
        icon: _iconForSense(distractors[0]),
        isCorrect: false,
      ),
      (
        text: _formatDefinition(
          distractors.length > 1 ? distractors[1] : distractors[0],
          level,
          variant: distractors.length <= 1,
        ),
        icon: _iconForSense(
          distractors.length > 1 ? distractors[1] : distractors[0],
        ),
        isCorrect: false,
      ),
    ];

    optionEntries.shuffle(random);
    final options = optionEntries
        .map((e) => QuizOption(text: e.text, icon: e.icon))
        .toList();
    final idx = optionEntries.indexWhere((e) => e.isCorrect);

    return QuizQuestion(
      word: split.displayWord,
      sentenceBefore: split.before,
      sentenceAfter: split.after,
      category: category,
      level: level,
      correctIndex: idx,
      options: options,
      sourceRecordId: record.id,
    );
  }

  String _formatDefinition(String definition, int level, {bool variant = false}) {
    final base = definition.trim();
    if (variant) return base;
    switch (level) {
      case 1:
        return base;
      case 2:
        return 'In this context: $base';
      case 3:
        return 'Critical reading — $base';
      default:
        return base;
    }
  }

  _SentenceSplit? _splitSentence(String sentence, String word) {
    final pattern = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
    final match = pattern.firstMatch(sentence);
    if (match == null) return null;

    return _SentenceSplit(
      before: sentence.substring(0, match.start),
      displayWord: sentence.substring(match.start, match.end),
      after: sentence.substring(match.end),
    );
  }

  IconData _iconForSense(String senseOrDefinition) {
    final s = senseOrDefinition.toLowerCase();
    if (s.contains('financial') || s.contains('money') || s.contains('bank')) {
      return Icons.account_balance;
    }
    if (s.contains('river') || s.contains('water')) return Icons.water;
    if (s.contains('machine') || s.contains('construction') || s.contains('crane')) {
      return Icons.precision_manufacturing;
    }
    if (s.contains('animal') || s.contains('dog') || s.contains('bear')) {
      return Icons.pets;
    }
    if (s.contains('music') || s.contains('note')) return Icons.music_note_rounded;
    if (s.contains('move') || s.contains('run') || s.contains('fast')) {
      return Icons.directions_run;
    }
    if (s.contains('fly') || s.contains('air')) return Icons.flight;
    if (s.contains('fire')) return Icons.local_fire_department;
    if (s.contains('legal') || s.contains('law') || s.contains('fine')) {
      return Icons.gavel_rounded;
    }
    if (s.contains('plant') || s.contains('organism')) return Icons.eco;
    return Icons.lightbulb_outline;
  }
}

class _SentenceSplit {
  final String before;
  final String displayWord;
  final String after;

  _SentenceSplit({
    required this.before,
    required this.displayWord,
    required this.after,
  });
}
