import 'package:flutter/material.dart';
import 'package:smart_sense_tutor/account/profile.dart';
import 'core/app_palette.dart';
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
      backgroundColor: AppPalette.scaffoldBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.header,
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
                // FIX: Changed ProgressService. to ProgressService().
                _buildStatCard(
                  ProgressService().getTotalInProgress().toString(),
                  "Lesson(s)\nin progress",
                  AppPalette.statPink,
                  Image.asset("asset/lessonicon.png", width: 40, height: 40),
                ),

                // FIX: Changed ProgressService. to ProgressService().
                _buildStatCard(
                  ProgressService().getTotalCompletedAll().toString(),
                  "Lessons\ncompleted",
                  AppPalette.statGreen,
                  Image.asset("asset/completedicon.png", width: 40, height: 40),
                ),

                // FIX: Changed ProgressService. to ProgressService().
                _buildStatCard(
                  ProgressService().getCategoriesCompleted().toString(),
                  "Categories\ncompleted",
                  AppPalette.statBlue,
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
                  // FIX: Changed ProgressService. to ProgressService().
                  child: _buildStatCard(
                    ProgressService().getAchievementsUnlockedCount().toString(),
                    "Achievement",
                    AppPalette.statYellow,
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
                  icon: const Icon(Icons.menu, color: AppPalette.navy),
                  onPressed: () {},
                ),
              ],
            ),
            const Text(
              "Choose a category to begin a lesson.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildCategoryCard("Tech & Tradition", isFullWidth: true),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("Finance & Physics")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Objects & Ideas")),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("Law & Structures")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Attributes & Evaluation")),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("Actions & Movement")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Directions & Space")),
              ],
            ),
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
                  builder: (context) => const ProfileScreen(),
                ),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppPalette.navy,
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

  Widget _buildStatCard(String count, String label, Color iconBgColor, Widget icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border, width: 1),
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

  static const Map<String, String> _categoryIcons = {
    "Tech & Tradition": "asset/tech_tradition_icon.png",
    "Finance & Physics": "asset/finance_physics_icon.png",
    "Objects & Ideas": "asset/objects_ideas_icon.png",
    "Law & Structures": "asset/law_structures_icon.png",
    "Attributes & Evaluation": "asset/attributes_evaluation_icon.png",
    "Actions & Movement": "asset/actions_movement_icon.png",
    "Directions & Space": "asset/directions_space_icon.png",
  };

  static const List<String> _categoryOrder = [
    "Tech & Tradition",
    "Finance & Physics",
    "Objects & Ideas",
    "Law & Structures",
    "Attributes & Evaluation",
    "Actions & Movement",
    "Directions & Space",
  ];

  bool _isCategoryLocked(String categoryTitle) {
    final index = _categoryOrder.indexOf(categoryTitle);
    if (index <= 0) return false;
    
    final previousCategory = _categoryOrder[index - 1];
    return !ProgressService().isCategoryCompleted(previousCategory);
  }

  Widget _buildCategoryCard(String title, {bool isFullWidth = false}) {
    final theme = CategoryVisualTheme.forCategory(title);
    final isLocked = _isCategoryLocked(title);
    final iconPath = _categoryIcons[title];
    final displayIcon = isLocked ? "asset/lock_category_image.png" : iconPath;

    return GestureDetector(
      onTap: isLocked ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LevelMap(category: title)),
        );
      },
      child: Stack(
        children: [
          Container(
            height: isFullWidth ? 100 : 110,
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isLocked ? Colors.grey : theme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: isLocked 
                      ? Colors.grey.withValues(alpha: 0.15)
                      : theme.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
                    color: isLocked ? Colors.grey : theme.accent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 14),
                if (displayIcon != null)
                  Image.asset(
                    displayIcon,
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  )
                else
                  const SizedBox(width: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLocked ? Colors.grey : theme.titleText,
                    ),
                  ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
          if (isLocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ),
        ],
      ),
    );
  }
}