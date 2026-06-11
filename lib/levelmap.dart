import 'package:flutter/material.dart';
import 'package:smart_sense_tutor/homescreen.dart';
import 'package:smart_sense_tutor/smartlookup.dart';
import 'level_difficulty_screen.dart';
import 'services/level_manager.dart';
import 'lessondata.dart';
import 'models/category_visual_theme.dart';
import 'progress.dart';

class LevelMap extends StatefulWidget {
  final String category;

  const LevelMap({super.key, required this.category});

  @override
  State<LevelMap> createState() => LevelMapState();
}

class LevelMapState extends State<LevelMap> {
  int get _unlockedLevel =>
      ProgressService().getUnlockedLevel(widget.category);

  // 🔥 REAL AUTO-UPDATING VALUE
  int get _streakCount =>
      ProgressService().getTotalCompletedAll();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final theme = CategoryVisualTheme.forCategory(widget.category);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/level.png',
              fit: BoxFit.fill,
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.secondary.withValues(alpha: 0.25),
                    theme.primary.withValues(alpha: 0.18),
                  ],
                ),
              ),
            ),
          ),

          // CATEGORY HEADER
          Positioned(
            top: 60,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Category:",
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.onPrimary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.category,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: theme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // LEVEL 3
          Positioned(
            right: 110,
            top: screenHeight * 0.20,
            child: _buildLevelNode(
              theme: theme,
              levelNumber: 3,
              label: "Level 3",
              imagePath: 'asset/level3.png',
            ),
          ),

          // LEVEL 2
          Positioned(
            right: 25,
            top: screenHeight * 0.40,
            child: _buildLevelNode(
              theme: theme,
              levelNumber: 2,
              label: "Level 2",
              imagePath: 'asset/level2.png',
            ),
          ),

          // LEVEL 1
          Positioned(
            right: 150,
            bottom: screenHeight * 0.26,
            child: _buildLevelNode(
              theme: theme,
              levelNumber: 1,
              label: "Level 1",
              imagePath: 'asset/level1.png',
            ),
          ),

          // 🔥 STREAK BUTTON (AUTO UPDATED)
          Positioned(
            bottom: 30,
            right: 40,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {}); // just refresh UI
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: _streakCount > 0
                          ? const LinearGradient(
                        colors: [
                          Color(0xFFFFCE56),
                          Color(0xFFFF705D),
                          Color(0xFF92B3F3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                if (_streakCount > 0)
                  Transform.translate(
                    offset: const Offset(0, -9),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCCE772),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        "$_streakCount",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),

          // BOTTOM NAV
          Positioned(
            bottom: 30,
            left: 24,
            right: 150,
            child: Container(
              height: 74,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(37),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_book,
                        color: Colors.grey, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LessonData(),
                        ),
                      );
                    },
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.primary,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.grey, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SmartLookup(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode({
    required CategoryVisualTheme theme,
    required int levelNumber,
    required String label,
    required String imagePath,
  }) {
    final characterBaseColor = theme.levelNodeColor(levelNumber);
    bool isLevelLocked = levelNumber > _unlockedLevel;


    int totalEarnedStars = 0;
    final difficulties = LevelManager.difficultiesPerLevel;

    for (var diff in difficulties) {
      totalEarnedStars +=
          ProgressService().getStars(widget.category, levelNumber, diff);
    }

    int averageStars = difficulties.isNotEmpty
        ? (totalEarnedStars / difficulties.length).round()
        : 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLevelLocked && averageStars > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                bool isFilled = index < averageStars;
                return Icon(
                  Icons.star_rounded,
                  color: isFilled ? theme.starColor : Colors.grey[300],
                  size: 22,
                );
              }),
            ),
          ),

        GestureDetector(
          onTap: () async {
            if (isLevelLocked) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Complete previous levels to unlock $label!",
                  ),
                ),
              );
            } else {
              final bool? refreshed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => LevelDifficultyScreen(
                    category: widget.category,
                    levelNumber: levelNumber,
                    levelName: label,
                  ),
                ),
              );

              if (refreshed == true && mounted) {
                setState(() {});
              }
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color:
                  isLevelLocked ? Colors.grey[300] : characterBaseColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: isLevelLocked
                    ? Icon(Icons.lock,
                    color: Colors.grey[600], size: 32)
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(imagePath),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: theme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}