/// Canonical category names used across the entire app.
class AppCategories {
  AppCategories._();

  static const String techAndTradition = 'Tech & Tradition';
  static const String financeAndPhysics = 'Finance & Physics';
  static const String objectsAndIdeas = 'Objects & Ideas';
  static const String lawAndStructures = 'Law & Structures';
  static const String attributesAndEvaluation = 'Attributes & Evaluation';
  static const String actionsAndMovement = 'Actions & Movement';
  static const String directionsAndSpace = 'Directions & Space';

  static const List<String> all = [
    techAndTradition,
    financeAndPhysics,
    objectsAndIdeas,
    lawAndStructures,
    attributesAndEvaluation,
    actionsAndMovement,
    directionsAndSpace,
  ];

  /// Resolves legacy or alternate spellings to the canonical name.
  static String normalize(String category) {
    final trimmed = category.trim();
    switch (trimmed) {
      case 'Law & Structure':
      case 'Law & Structures':
        return lawAndStructures;
      default:
        return trimmed;
    }
  }
}
