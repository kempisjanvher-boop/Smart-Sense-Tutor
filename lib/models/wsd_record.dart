/// One row from [English_WSD_Dataset.csv].
class WsdRecord {
  final int id;
  final String word;
  final String sentence;
  final String correctSense;
  final String definition;

  const WsdRecord({
    required this.id,
    required this.word,
    required this.sentence,
    required this.correctSense,
    required this.definition,
  });

  factory WsdRecord.fromCsvRow(Map<String, String> row) {
    return WsdRecord(
      id: int.tryParse(row['ID'] ?? '') ?? 0,
      word: (row['Word'] ?? '').trim().toLowerCase(),
      sentence: (row['Sentence'] ?? '').trim(),
      correctSense: (row['Correct Sense'] ?? '').trim(),
      definition: (row['Definition'] ?? '').trim(),
    );
  }
}
