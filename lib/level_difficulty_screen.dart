import 'package:flutter/material.dart';

import 'difficulty_theme.dart';
import 'gameplayscreen.dart';
import 'models/category_visual_theme.dart';
import 'models/difficulty.dart';
import 'progress.dart';
import 'services/level_manager.dart';
import 'services/quiz_engine.dart';

/// Pick Easy / Moderate / Hard before starting a level (per mockups).
class LevelDifficultyScreen extends StatefulWidget {
  final String category;
  final int levelNumber;
  final String levelName;

  const LevelDifficultyScreen({
    super.key,
    required this.category,
    required this.levelNumber,
    required this.levelName,
  });

  @override
  State<LevelDifficultyScreen> createState() => _LevelDifficultyScreenState();
}

class _LevelDifficultyScreenState extends State<LevelDifficultyScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = CategoryVisualTheme.forCategory(widget.category);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('asset/gameplayscreen.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.cancel_rounded, color: theme.secondary, size: 36),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              widget.levelName,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: theme.titleText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Category: ${widget.category}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.titleText.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Choose a difficulty',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.titleText.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    children: [
                      for (final difficulty in LevelManager.difficultiesPerLevel)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _DifficultyTile(
                            theme: theme,
                            category: widget.category,
                            levelNumber: widget.levelNumber,
                            levelName: widget.levelName,
                            difficulty: difficulty,
                            onCompleted: () => setState(() {}),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final CategoryVisualTheme theme;
  final String category;
  final int levelNumber;
  final String levelName;
  final Difficulty difficulty;
  final VoidCallback onCompleted;

  const _DifficultyTile({
    required this.theme,
    required this.category,
    required this.levelNumber,
    required this.levelName,
    required this.difficulty,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = ProgressService().isDifficultyUnlocked(
      category,
      levelNumber,
      difficulty,
    );
    final stars = ProgressService().getStars(category, levelNumber, difficulty);
    final badgeColor = DifficultyTheme.badgeColor(difficulty);

    return Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (!unlocked) {
              final need = difficulty == Difficulty.moderate
                  ? 'Easy'
                  : 'Moderate';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Complete $need first to unlock ${difficulty.label}.',
                  ),
                ),
              );
              return;
            }

            final result = await Navigator.push<int>(
              context,
              MaterialPageRoute(
                builder: (context) => GameplayScreen(
                  category: category,
                  levelNumber: levelNumber,
                  levelName: levelName,
                  difficulty: difficulty,
                ),
              ),
            );

            if (result != null && context.mounted) {
              ProgressService().setStars(
                category,
                levelNumber,
                difficulty,
                result,
              );

              // Only increment progress when all 3 difficulties in the level are completed
              if (ProgressService().completedDifficultiesCount(category, levelNumber) >= 3) {
                ProgressService().addCompletion(category);
              }
              ProgressService().unlockNext(category, levelNumber);

              // ─── NEW: TRIGGER ACHIEVEMENT EVALUATION ───
              // Adjust userWantsNotifs and userIsUsingDarkMode tracking if you want to pull dynamically
              const bool userWantsNotifs = true;
              const bool userIsUsingDarkMode = false;

              // Define how many maximum matching points equal a perfect clear profile
              const int maxQuestionsPerRound = 3;

              // Get actual historical values to check milestone limits
              final int totalPerfectScoresRecorded = ProgressService().getUnlockedLevel(category);

              QuizEngine.instance.evaluateAndTriggerAchievements(
                context: context,
                correctAnswers: result,
                totalQuestions: maxQuestionsPerRound,
                totalPerfectScoresFromStorage: totalPerfectScoresRecorded,
                notificationsEnabled: userWantsNotifs,
                isDarkMode: userIsUsingDarkMode,
              );
              // ───────────────────────────────────────────

              onCompleted();
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: DifficultyTheme.badgeShadow(difficulty),
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Text(
                  difficulty.headerLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!unlocked)
                    Icon(Icons.lock, size: 18, color: theme.titleText.withValues(alpha: 0.5))
                  else
                    ...List.generate(3, (i) {
                      return Icon(
                        Icons.star_rounded,
                        size: 22,
                        color: i < stars ? theme.starColor : Colors.grey[350],
                      );
                    }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}