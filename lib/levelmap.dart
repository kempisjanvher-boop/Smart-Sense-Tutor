import 'package:flutter/material.dart';
import 'gameplayscreen.dart';
import 'lessondata.dart';
import 'progress.dart';

class LevelMap extends StatefulWidget {
  final String category;

  const LevelMap({super.key, required this.category});

  @override
  State<LevelMap> createState() => LevelMapState();
}

class LevelMapState extends State<LevelMap> {
  bool _hasPlayedGame = false;
  int _streakCount = 0;
  int get _unlockedLevel =>
      ProgressService.getUnlockedLevel(widget.category);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/level.png',
              fit: BoxFit.fill,
            ),
          ),

          // CATEGORY HEADER
          Positioned(
            top: 60,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Category:",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
              3,
              "Level 3",
              const Color(0xFF5CC2E6),
              'asset/level3.png',
            ),
          ),

          // LEVEL 2
          Positioned(
            right: 25,
            top: screenHeight * 0.40,
            child: _buildLevelNode(
              2,
              "Level 2",
              const Color(0xFFF2A3B3),
              'asset/level2.png',
            ),
          ),

          // LEVEL 1
          Positioned(
            right: 150,
            bottom: screenHeight * 0.26,
            child: _buildLevelNode(
              1,
              "Level 1",
              const Color(0xFF4A5568),
              'asset/level1.png',
            ),
          ),

          // STREAK BUTTON
          Positioned(
            bottom: 30,
            right: 40,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasPlayedGame = true;
                      _streakCount = 1;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _hasPlayedGame
                          ? const Color(0xFFFF7A45)
                          : Colors.grey[400],
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: _hasPlayedGame ? Colors.yellow : Colors.white70,
                      size: 40,
                    ),
                  ),
                ),
                if (_hasPlayedGame)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFA0E050),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$_streakCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
                    backgroundColor: const Color(0xFF70D3F4),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
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
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelNode(
      int levelNumber,
      String label,
      Color characterBaseColor,
      String imagePath,
      ) {
    bool isLevelLocked = levelNumber > _unlockedLevel;
    int starsEarned =
    ProgressService.getStars(widget.category, levelNumber);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isLevelLocked && starsEarned > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Icon(
                  Icons.star_rounded,
                  color: index < starsEarned
                      ? const Color(0xFFFFD026)
                      : Colors.grey[300],
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
              final int? averageStarsResult =
              await Navigator.push<int>(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GameplayScreen(levelName: label),
                ),
              );

              if (averageStarsResult != null && mounted) {
                setState(() {
                  ProgressService.setStars(
                    widget.category,
                    levelNumber,
                    averageStarsResult,
                  );

                  ProgressService.addCompletion(widget.category);
                  ProgressService.unlockNext(widget.category, levelNumber);

                  _hasPlayedGame = true;
                  _streakCount = 1;
                });
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
                  color: isLevelLocked
                      ? Colors.grey[300]
                      : characterBaseColor,
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
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.black26,
                      );
                    },
                  ),
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
            color: const Color(0xFF2C3E6B),
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