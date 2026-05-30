import 'package:flutter/services.dart';

import '../models/wsd_record.dart';

/// Loads and caches the bundled WSD CSV dataset.
class WsdDatasetLoader {
  WsdDatasetLoader._();

  static final WsdDatasetLoader instance = WsdDatasetLoader._();

  static const String assetPath = 'asset/English_WSD_Dataset.csv';

  List<WsdRecord>? _cache;

  Future<List<WsdRecord>> loadAll() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) {
      _cache = [];
      return _cache!;
    }

    final records = <WsdRecord>[];
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final row = _parseCsvLine(line);
      if (row.length < 5) continue;
      records.add(
        WsdRecord(
          id: int.tryParse(row[0]) ?? i,
          word: row[1].trim().toLowerCase(),
          sentence: row[2].trim(),
          correctSense: row[3].trim(),
          definition: row[4].trim(),
        ),
      );
    }

    _cache = records;
    return _cache!;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    result.add(buffer.toString());
    return result;
  }

  Future<Map<String, List<WsdRecord>>> groupByWord() async {
    final all = await loadAll();
    final map = <String, List<WsdRecord>>{};
    for (final record in all) {
      map.putIfAbsent(record.word, () => []).add(record);
    }
    return map;
  }
}
