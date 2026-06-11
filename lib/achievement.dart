import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'lessondata.dart';
import 'smartlookup.dart';
import 'progress.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Using ProgressService(). to access instance variables through the Singleton pattern
    int perfectScoresCount = ProgressService().getPerfectScores();
    bool hasCompletedALesson = ProgressService().hasCompletedAtLeastOneLesson();
    bool perfectWeekStreak = ProgressService().hasWeekStreak();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF70D3F4),
        elevation: 0,
        title: const Text(
          "Achievements",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4379),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Image.asset(
                "asset/achievement.png",
                width: 150,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Here's your collection",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Card 1: Legend (Week Streak Achievement)
            _buildAchievementCard(
              title: "Legend",
              subtitle: "🔥 Completed the Lessons",
              progressValue: perfectWeekStreak ? 1.0 : 0.0,
              progressPercentText: perfectWeekStreak ? "100 %" : "0 %",
              badgePath: "asset/silver.png",
              avatarPath: "asset/legend.png",
            ),
            const SizedBox(height: 16),

            // Card 2: Royal (10 Perfect Scores Tracker)
            _buildAchievementCard(
              title: "Royal",
              subtitle: "$perfectScoresCount/10 perfect score",
              progressValue: (perfectScoresCount / 10).clamp(0.0, 1.0),
              progressPercentText: "${((perfectScoresCount / 10).clamp(0.0, 1.0) * 100).toInt()} %",
              badgePath: "asset/bronze.png",
              avatarPath: "asset/perfectscore.png",
            ),
            const SizedBox(height: 16),

            // Card 3: Conqueror (Complete a lesson)
            _buildAchievementCard(
              title: "Conqueror",
              subtitle: "You completed a lesson",
              progressValue: hasCompletedALesson ? 1.0 : 0.0,
              progressPercentText: hasCompletedALesson ? "100 %" : "0 %",
              badgePath: "asset/gold.png",
              avatarPath: "asset/conqueror.png",
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C3E6B),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              break;
            case 1:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LessonData()));
              break;
            case 2:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SmartLookup()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Lessons"),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: "Smart Lookup"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String subtitle,
    required double progressValue,
    required String progressPercentText,
    required String badgePath,
    required String avatarPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Adjusted opacity slightly so shadows look clean
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: const Color(0xFFE3F7FF),
              width: 75,
              height: 75,
              child: Image.asset(avatarPath, errorBuilder: (c, e, s) => const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Image.asset(badgePath, width: 24, height: 24, errorBuilder: (c, e, s) => const Icon(Icons.star, color: Colors.amber)),
                  ],
                ),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progressValue,
                          backgroundColor: const Color(0xFFE5E5E5),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF7A50)),
                          minHeight: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(progressPercentText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}