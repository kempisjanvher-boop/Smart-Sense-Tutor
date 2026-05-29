import '../core/app_categories.dart';

/// Maps each category to thematic word pools and sense hints for filtering.
class CategoryThemeRegistry {
  CategoryThemeRegistry._();

  static const Map<String, List<String>> _wordPools = {
    AppCategories.techAndTradition: [
      'plant',
      'crane',
      'post',
      'set',
      'fire',
      'train',
      'scale',
      'table',
    ],
    AppCategories.financeAndPhysics: [
      'bank',
      'charge',
      'change',
      'fine',
      'fair',
      'scale',
      'pool',
      'run',
    ],
    AppCategories.objectsAndIdeas: [
      'rock',
      'table',
      'seal',
      'bat',
      'kind',
      'spring',
      'sound',
      'star',
    ],
    AppCategories.lawAndStructures: [
      'fine',
      'charge',
      'cross',
      'tie',
      'post',
      'fair',
      'set',
      'table',
    ],
    AppCategories.attributesAndEvaluation: [
      'fair',
      'fine',
      'kind',
      'sound',
      'bear',
      'star',
      'date',
      'change',
    ],
    AppCategories.actionsAndMovement: [
      'run',
      'fly',
      'fall',
      'wave',
      'pitch',
      'bark',
      'train',
      'fire',
    ],
    AppCategories.directionsAndSpace: [
      'bank',
      'cross',
      'wave',
      'fall',
      'spring',
      'pitch',
      'fly',
      'pool',
    ],
  };

  /// Keywords matched against [WsdRecord.correctSense] for thematic relevance.
  static const Map<String, List<String>> _senseHints = {
    AppCategories.techAndTradition: [
      'machine',
      'device',
      'construction',
      'factory',
      'industrial',
      'equipment',
      'tool',
      'technology',
      'living organism',
      'plant',
    ],
    AppCategories.financeAndPhysics: [
      'financial',
      'money',
      'institution',
      'loan',
      'interest',
      'payment',
      'energy',
      'motion',
      'physics',
      'charge',
      'river bank',
    ],
    AppCategories.objectsAndIdeas: [
      'object',
      'material',
      'animal',
      'musical',
      'concept',
      'idea',
      'organism',
      'rock',
      'table',
    ],
    AppCategories.lawAndStructures: [
      'legal',
      'law',
      'penalty',
      'fine',
      'structure',
      'cross',
      'tie',
      'post',
      'rule',
    ],
    AppCategories.attributesAndEvaluation: [
      'quality',
      'fair',
      'fine',
      'kind',
      'sound',
      'evaluation',
      'attribute',
      'appearance',
    ],
    AppCategories.actionsAndMovement: [
      'move',
      'run',
      'fly',
      'fall',
      'wave',
      'pitch',
      'bark',
      'action',
      'fast',
    ],
    AppCategories.directionsAndSpace: [
      'direction',
      'space',
      'bank',
      'cross',
      'wave',
      'fall',
      'spring',
      'position',
      'area',
    ],
  };

  static List<String> wordsForCategory(String category) {
    final key = AppCategories.normalize(category);
    return _wordPools[key] ?? _wordPools[AppCategories.objectsAndIdeas]!;
  }

  static List<String> senseHintsForCategory(String category) {
    final key = AppCategories.normalize(category);
    return _senseHints[key] ?? [];
  }

  static String themeDescription(String category) {
    switch (AppCategories.normalize(category)) {
      case AppCategories.techAndTradition:
        return 'innovation, inventions, and cultural-tech evolution';
      case AppCategories.financeAndPhysics:
        return 'financial logic and physics principles';
      case AppCategories.objectsAndIdeas:
        return 'abstract reasoning and conceptual thinking';
      case AppCategories.lawAndStructures:
        return 'legal systems, rules, and structural logic';
      case AppCategories.attributesAndEvaluation:
        return 'qualities, traits, and evaluative judgment';
      case AppCategories.actionsAndMovement:
        return 'verbs of motion, force, and physical action';
      case AppCategories.directionsAndSpace:
        return 'spatial orientation and positional meaning';
      default:
        return 'vocabulary in context';
    }
  }
}
