// lib/analyzer/polysemy_analyzer.dart
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordMeaning {
  final String title;
  final String definition;
  final String example;
  final double confidenceScore;

  WordMeaning({
    required this.title,
    required this.definition,
    required this.example,
    required this.confidenceScore,
  });
}

class PolysemyAnalyzer {
  static List<Map<String, String>> excelDataset = [];

  /// Parses a single CSV line while safely handling commas inside quotation markers.
  static List<String> _parseCsvLine(String line) {
    List<String> result = [];
    StringBuffer currentField = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      String char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(_cleanQuotes(currentField.toString()));
        currentField.clear();
      } else {
        currentField.write(char);
      }
    }
    result.add(_cleanQuotes(currentField.toString()));
    return result;
  }

  static String _cleanQuotes(String value) {
    String text = value.trim();
    if (text.startsWith('"') && text.endsWith('"')) {
      if (text.length > 1) {
        text = text.substring(1, text.length - 1).trim();
      }
    }
    return text.replaceAll('""', '"');
  }

  /// Loads your 4-column WSD-dataset.csv asset file
  static Future<void> loadDataset() async {
    try {
      final String rawCsvContent = await rootBundle.loadString('asset/WSD-dataset.csv');
      final List<String> lines = const LineSplitter().convert(rawCsvContent);
      if (lines.isEmpty) return;

      List<Map<String, String>> temporaryDataset = [];

      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> columns = _parseCsvLine(line);
        if (columns.length < 4) continue;

        Map<String, String> rowMap = {
          "word": columns[0].toLowerCase().trim(),
          "sentence": columns[1].trim(),
          "correct sense": columns[2].trim(),
          "definition": columns[3].trim(),
        };

        if (rowMap["word"]!.isNotEmpty) {
          temporaryDataset.add(rowMap);
        }
      }

      excelDataset = temporaryDataset;
      debugPrint("PolysemyAnalyzer: Successfully loaded ${excelDataset.length} rows from WSD-dataset.csv!");
    } catch (e) {
      debugPrint("PolysemyAnalyzer Critical Error: $e");
    }
  }

  /// ─── NEW: ADDED FOR THE INLINE SEARCH BAR SUPPORT ───
  /// Returns all distinct meanings for a single keyword without context weights.
  static List<WordMeaning> getMeaningsForWord(String searchWord) {
    final cleanSearchWord = searchWord.trim().toLowerCase();
    final matchingRows = excelDataset.where((row) => row["word"] == cleanSearchWord).toList();

    if (matchingRows.isEmpty) {
      return [
        WordMeaning(
          title: "Not Found",
          definition: "No vocabulary definitions matched '$searchWord' in the database archive.",
          example: "Try searching another polysemous word example like 'ring' or 'bank'.",
          confidenceScore: 0.0,
        )
      ];
    }

    Map<String, WordMeaning> uniqueMeaningsMap = {};

    for (var row in matchingRows) {
      String definition = row["definition"]?.trim() ?? 'No definition provided.';
      if (!uniqueMeaningsMap.containsKey(definition)) {
        uniqueMeaningsMap[definition] = WordMeaning(
          title: row["correct sense"] ?? 'General Meaning',
          definition: definition,
          example: row["sentence"] ?? '',
          confidenceScore: 1.0,
        );
      }
    }

    return uniqueMeaningsMap.values.toList();
  }

  /// Evaluates context matches using TF-IDF, grouping identical definitions
  /// together to completely eliminate repetitive cards in the UI.
  static List<WordMeaning> analyzeContext(String searchWord, String userSentence) {
    final cleanSearchWord = searchWord.trim().toLowerCase();
    final matchingRows = excelDataset.where((row) => row["word"] == cleanSearchWord).toList();

    if (matchingRows.isEmpty) {
      return [
        WordMeaning(
          title: "Database Alert",
          definition: "No matching rows found for '$searchWord'. Count: ${excelDataset.length}.",
          example: userSentence.isNotEmpty ? userSentence : "Type an example sentence to evaluate.",
          confidenceScore: 1.0,
        )
      ];
    }

    // 1. Prepare global TF-IDF space vectors
    List<List<String>> globalCorpus = excelDataset.map((row) => _tokenize(row["sentence"] ?? '')).toList();
    globalCorpus.add(_tokenize(userSentence));

    Map<String, double> globalIdf = _inverseDocumentFrequency(globalCorpus);
    List<String> userTokens = _tokenize(userSentence);
    Map<String, double> userTf = _termFrequency(userTokens);
    Map<String, double> userTfidfVector = _tfidfVector(userTf, globalIdf);

    // Grouping map where Key: Unique Definition String, Value: Highest-scoring WordMeaning
    Map<String, WordMeaning> uniqueMeaningsMap = {};

    // 2. Loop through all matches and aggregate duplicate word senses
    for (var row in matchingRows) {
      String definition = row["definition"]?.trim() ?? 'No definition provided.';
      String clearSentence = row["sentence"] ?? '';
      String senseTitle = row["correct sense"] ?? 'General Meaning';

      List<String> excelTokens = _tokenize(clearSentence);
      Map<String, double> excelTf = _termFrequency(excelTokens);
      Map<String, double> excelTfidfVector = _tfidfVector(excelTf, globalIdf);

      double similarity = _cosineSimilarity(userTfidfVector, excelTfidfVector);

      // If we haven't encountered this exact definition yet, OR if this sentence
      // matches the user's conversational context better, track it!
      if (!uniqueMeaningsMap.containsKey(definition) ||
          similarity > uniqueMeaningsMap[definition]!.confidenceScore) {

        uniqueMeaningsMap[definition] = WordMeaning(
          title: senseTitle,
          definition: definition,
          example: clearSentence,
          confidenceScore: similarity,
        );
      }
    }

    // 3. Convert grouped entries back into a list and sort by highest similarity
    List<WordMeaning> aggregatedResults = uniqueMeaningsMap.values.toList();
    aggregatedResults.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

    return aggregatedResults;
  }

  static List<String> _tokenize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '').split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  }

  static Map<String, double> _termFrequency(List<String> words) {
    Map<String, double> tf = {};
    for (var word in words) {
      tf[word] = (tf[word] ?? 0) + 1;
    }
    int totalWords = words.length;
    if (totalWords > 0) {
      tf.updateAll((key, value) => value / totalWords);
    }
    return tf;
  }

  static Map<String, double> _inverseDocumentFrequency(List<List<String>> documents) {
    Map<String, double> idf = {};
    int totalDocs = documents.length;
    Set<String> allWords = documents.expand((doc) => doc).toSet();

    for (var word in allWords) {
      int docsContainingWord = 0;
      for (var doc in documents) {
        if (doc.contains(word)) docsContainingWord++;
      }
      idf[word] = log((totalDocs + 1) / (1 + docsContainingWord));
    }
    return idf;
  }

  static Map<String, double> _tfidfVector(Map<String, double> tf, Map<String, double> idf) {
    Map<String, double> vector = {};
    tf.forEach((word, tfValue) {
      vector[word] = tfValue * (idf[word] ?? 0);
    });
    return vector;
  }

  static double _cosineSimilarity(Map<String, double> vec1, Map<String, double> vec2) {
    Set<String> allWords = {...vec1.keys, ...vec2.keys};
    double dotProduct = 0, norm1 = 0, norm2 = 0;

    for (var word in allWords) {
      double v1 = vec1[word] ?? 0;
      double v2 = vec2[word] ?? 0;
      dotProduct += v1 * v2;
      norm1 += v1 * v2; // Note: Dot product sum aggregation
      norm1 += v1 * v1;
      norm2 += v2 * v2;
    }

    if (norm1 == 0 || norm2 == 0) return 0;
    return dotProduct / (sqrt(norm1) * sqrt(norm2));
  }
}