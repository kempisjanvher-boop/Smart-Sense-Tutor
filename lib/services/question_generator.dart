import 'dart:math';

import 'package:flutter/material.dart';

import '../core/app_categories.dart';
import '../models/difficulty.dart';
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
    required Difficulty difficulty,
    Set<int>? excludeRecordIds,
    String? avoidWord,
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

    // Filter into a difficulty-appropriate slice, but don't over-prune small pools.
    final baseCandidates = List<WsdRecord>.from(candidates);
    candidates = _filterByDifficulty(candidates, difficulty);
    if (candidates.length < LevelManager.questionsPerLevel * 4) {
      candidates = baseCandidates;
    }
    if (candidates.length < LevelManager.questionsPerLevel) {
      final fallbackBase =
          allRecords.where((r) => poolWords.contains(r.word)).toList();
      candidates = _filterByDifficulty(fallbackBase, difficulty);
      if (candidates.length < LevelManager.questionsPerLevel * 4) {
        candidates = fallbackBase;
      }
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

    final excluded = excludeRecordIds ?? const <int>{};
    final usedRecordIds = <int>{...excluded};
    final usedWords = <String>{};
    final questions = <QuizQuestion>[];
    String? lastWord = avoidWord;

    for (final record in candidates) {
      if (questions.length >= LevelManager.questionsPerLevel) break;
      if (usedRecordIds.contains(record.id)) continue;
      if (lastWord != null && record.word == lastWord) continue;

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
        difficulty: difficulty,
        random: random,
      );
      if (question == null) continue;

      usedRecordIds.add(record.id);
      usedWords.add(record.word);
      questions.add(question);
      lastWord = record.word;
    }

    // Fallback: relax unique-word rule.
    if (questions.length < LevelManager.questionsPerLevel) {
      final fallback = List<WsdRecord>.from(candidates)..shuffle(random);
      for (final record in fallback) {
        if (questions.length >= LevelManager.questionsPerLevel) break;
        if (usedRecordIds.contains(record.id)) continue;
        if (lastWord != null && record.word == lastWord) continue;

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
          difficulty: difficulty,
          random: random,
        );
        if (question == null) continue;

        usedRecordIds.add(record.id);
        questions.add(question);
        lastWord = record.word;
      }
    }

    // Last resort: ignore category theming and difficulty slicing.
    // This prevents hard failures when a themed pool is too small or too sparse
    // (e.g., many words in the pool only have one sense in the dataset).
    if (questions.length < LevelManager.questionsPerLevel) {
      final fallbackAll = List<WsdRecord>.from(allRecords)..shuffle(random);
      for (final record in fallbackAll) {
        if (questions.length >= LevelManager.questionsPerLevel) break;
        if (usedRecordIds.contains(record.id)) continue;
        if (lastWord != null && record.word == lastWord) continue;

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
          difficulty: difficulty,
          random: random,
        );
        if (question == null) continue;

        usedRecordIds.add(record.id);
        questions.add(question);
        lastWord = record.word;
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

  List<WsdRecord> _filterByDifficulty(List<WsdRecord> records, Difficulty difficulty) {
    final sorted = List<WsdRecord>.from(records)
      ..sort((a, b) {
        final cmp = a.sentence.length.compareTo(b.sentence.length);
        if (cmp != 0) return cmp;
        return a.definition.length.compareTo(b.definition.length);
      });

    if (sorted.isEmpty) return sorted;

    final third = (sorted.length / 3).ceil().clamp(1, sorted.length);

    switch (difficulty) {
      case Difficulty.easy:
        return sorted.take(third).toList();
      case Difficulty.moderate:
        final start = third.clamp(0, sorted.length - 1);
        final end = (third * 2).clamp(start + 1, sorted.length);
        return sorted.sublist(start, end);
      case Difficulty.hard:
        final hardStart = (third * 2).clamp(0, sorted.length - 1);
        return sorted.sublist(hardStart);
    }
  }

  QuizQuestion? _buildQuestion({
    required WsdRecord record,
    required Map<String, String> senses,
    required String category,
    required int level,
    required Difficulty difficulty,
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
    distractors.sort((a, b) => _definitionSimilarityScore(record.definition, b)
        .compareTo(_definitionSimilarityScore(record.definition, a)));
    // For easy, pick least similar distractors. For hard, pick most similar.
    final ordered = List<String>.from(distractors);
    if (difficulty == Difficulty.easy) {
      ordered.sort((a, b) => _definitionSimilarityScore(record.definition, a)
          .compareTo(_definitionSimilarityScore(record.definition, b)));
    } else if (difficulty == Difficulty.hard) {
      ordered.sort((a, b) => _definitionSimilarityScore(record.definition, b)
          .compareTo(_definitionSimilarityScore(record.definition, a)));
    } else {
      ordered.shuffle(random);
    }

    if (ordered.isEmpty) return null;

    final correctText = _formatDefinition(correctDefinition, difficulty);
    final optionEntries = <({String text, IconData icon, bool isCorrect})>[
      (text: correctText, icon: _iconForSense(record.correctSense), isCorrect: true),
      (
        text: _formatDefinition(ordered[0], difficulty),
        icon: _iconForSense(ordered[0]),
        isCorrect: false,
      ),
      (
        text: _formatDefinition(
          ordered.length > 1 ? ordered[1] : ordered[0],
          difficulty,
          variant: ordered.length <= 1,
        ),
        icon: _iconForSense(
          ordered.length > 1 ? ordered[1] : ordered[0],
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
      difficulty: difficulty,
      correctIndex: idx,
      options: options,
      sourceRecordId: record.id,
    );
  }

  String _formatDefinition(
    String definition,
    Difficulty difficulty, {
    bool variant = false,
  }) {
    final base = definition.trim();
    if (variant) return base;
    switch (difficulty) {
      case Difficulty.easy:
        return base;
      case Difficulty.moderate:
        return base;
      case Difficulty.hard:
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

  int _definitionSimilarityScore(String a, String b) {
    final aTokens = _tokens(a);
    final bTokens = _tokens(b);
    if (aTokens.isEmpty || bTokens.isEmpty) return 0;
    var overlap = 0;
    for (final t in aTokens) {
      if (bTokens.contains(t)) overlap++;
    }
    return overlap;
  }

  Set<String> _tokens(String s) {
    final cleaned = s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z\\s]'), ' ')
        .trim();
    if (cleaned.isEmpty) return const {};
    final parts = cleaned.split(RegExp(r'\\s+'));
    return parts.where((p) => p.length >= 4).toSet();
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
