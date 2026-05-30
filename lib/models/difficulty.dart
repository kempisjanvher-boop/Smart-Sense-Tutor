/// Difficulty tiers within each level (Easy / Moderate / Hard).
enum Difficulty {
  easy('Easy', 'EASY'),
  moderate('Moderate', 'MODERATE'),
  hard('Hard', 'HARD');

  const Difficulty(this.label, this.headerLabel);
  final String label;
  final String headerLabel;

  /// Order used for unlock progression inside a level.
  int get order => index;
}

