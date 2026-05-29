import 'package:flutter/material.dart';
import 'core/app_categories.dart';
import 'levelmap.dart';
import 'lessondata.dart';
import 'models/category_visual_theme.dart';
import 'progress.dart';
import 'smartlookup.dart';
import 'achievement.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF70D3F4),
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        titleSpacing: 0,
        title: const Text(
          "Overview",
          style: TextStyle(
            fontSize: 28, // Slightly reduced size to fit perfectly alongside the button
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  ProgressService.getLessonsInProgressCount().toString(),
                  "Lesson(s)\nin progress",
                  const Color(0xFFFFDDD7),
                  Image.asset("asset/lessonicon.png", width: 40, height: 40),
                ),
                _buildStatCard(
                  ProgressService.getTotalCompletedAll().toString(),
                  "Lessons\ncompleted",
                  const Color(0xFFE8FFE8),
                  Image.asset("asset/completedicon.png", width: 40, height: 40),
                ),
                _buildStatCard(
                  ProgressService.getCategoriesCompleted().toString(),
                  "Categories\ncompleted",
                  const Color(0xFFEAEDFF),
                  Image.asset("asset/categoriesicon.png", width: 40, height: 40),
                ),

                // Wrap this 4th Achievement card to navigate on click!
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AchievementsScreen()),
                    );
                  },
                  child: _buildStatCard(
                    ProgressService.getAchievementsUnlockedCount().toString(), // Dynamic unlocked number
                    "Achievement",
                    const Color(0xFFFFFADD),
                    Image.asset(
                      "asset/achievementicon.png",
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Lessons",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Color(0xFF2C3E6B)),
                  onPressed: () {},
                ),
              ],
            ),
            const Text(
              "Choose a category to begin a lesson.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._buildCategorySections(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LessonData(),
                ),
              );
              break;

            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SmartLookup(),
                ),
              );
              break;

            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C3E6B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Lessons",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: "Smart Lookup",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: "More",
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategorySections() {
    final categories = AppCategories.all;
    if (categories.isEmpty) return const [];

    final sections = <Widget>[
      _buildCategoryCard(categories.first, isFullWidth: true),
      const SizedBox(height: 30),
    ];

    for (var i = 1; i < categories.length; i += 2) {
      final left = categories[i];
      final right = i + 1 < categories.length ? categories[i + 1] : null;

      sections.add(
        Row(
          children: [
            Expanded(child: _buildCategoryCard(left)),
            if (right != null) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryCard(right)),
            ],
          ],
        ),
      );
      if (i + 2 < categories.length) {
        sections.add(const SizedBox(height: 30));
      }
    }

    return sections;
  }

  Widget _buildStatCard(String count, String label, Color iconBgColor, Widget icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFE2E8F0),
          width: 1
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.2)),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)),
              child: icon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, {bool isFullWidth = false}) {
    final theme = CategoryVisualTheme.forCategory(title);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LevelMap(category: title)),
        );
      },
      child: Container(
        height: isFullWidth ? 100 : 110,
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Container(
              width: 6,
              height: 48,
              decoration: BoxDecoration(
                color: theme.accent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.titleText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}