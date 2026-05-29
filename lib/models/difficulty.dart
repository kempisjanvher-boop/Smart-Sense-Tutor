/// Difficulty tiers for gameplay progression.
enum Difficulty {
  easy('Easy'),
  moderate('Moderate'),
  hard('Hard');

  const Difficulty(this.label);
  final String label;
}

