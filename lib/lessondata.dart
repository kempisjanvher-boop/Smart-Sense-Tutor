import 'package:flutter/material.dart';
import 'package:smart_sense_tutor/smartlookup.dart';
import 'core/app_palette.dart';
import 'levelmap.dart';
import 'homescreen.dart';
import 'models/category_visual_theme.dart';
import 'progress.dart';
import '../account/profile.dart';

class LessonData extends StatefulWidget {
  const LessonData({super.key});

  @override
  State<LessonData> createState() => _LessonDataState();
}

class LessonCategory {
  final String title;

  LessonCategory({required this.title});

  // FIX: Changed ProgressService.totalLessons to ProgressService().totalLessons
  int get totalLessons => ProgressService().totalLessons[title] ?? 3;

  // FIX: Changed ProgressService.getCompleted to ProgressService().getCompleted
  int get completedLessons {
    final done = ProgressService().getCompleted(title);
    return done.clamp(0, totalLessons);
  }

  double get progressPercentage =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;
}

class _LessonDataState extends State<LessonData> {
  final int _currentIndex = 1;

  static const List<String> _categoryTitles = [
    "Tech & Tradition",
    "Finance & Physics",
    "Objects & Ideas",
    "Law & Structures",
    "Attributes & Evaluation",
    "Actions & Movement",
    "Directions & Space",
  ];

  static const Map<String, String> _categoryIcons = {
    "Tech & Tradition": "asset/tech_tradition_icon.png",
    "Finance & Physics": "asset/finance_physics_icon.png",
    "Objects & Ideas": "asset/objects_ideas_icon.png",
    "Law & Structures": "asset/law_structures_icon.png",
    "Attributes & Evaluation": "asset/attributes_evaluation_icon.png",
    "Actions & Movement": "asset/actions_movement_icon.png",
    "Directions & Space": "asset/directions_space_icon.png",
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // refresh progress when coming back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.scaffoldBg,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.header,
        elevation: 0,

        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Lessons",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppPalette.navyDark,
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppPalette.navyDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),

      body: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24.0,
        ),
        itemCount: _categoryTitles.length,
        separatorBuilder: (context, index) =>
        const SizedBox(height: 20),
        itemBuilder: (context, index) {
          return _buildLessonCard(LessonCategory(title: _categoryTitles[index]));
        },
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

  bool _isCategoryLocked(String categoryTitle) {
    final index = _categoryTitles.indexOf(categoryTitle);
    if (index <= 0) return false; // First category is never locked
    
    final previousCategory = _categoryTitles[index - 1];
    final progress = ProgressService();
    return !progress.isCategoryCompleted(previousCategory);
  }

  Widget _buildLessonCard(LessonCategory category) {
    final theme = CategoryVisualTheme.forCategory(category.title);
    final isLocked = _isCategoryLocked(category.title);
    final iconPath = _categoryIcons[category.title];
    final displayIcon = isLocked ? "asset/lock_category_image.png" : iconPath;

    return GestureDetector(
      onTap: isLocked ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelMap(
              category: category.title,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Category Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: displayIcon != null
                      ? Image.asset(
                          displayIcon,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                        )
                      : Icon(
                          Icons.category,
                          color: theme.primary,
                          size: 32,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey : theme.titleText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: isLocked ? 0.0 : category.progressPercentage,
                          backgroundColor: AppPalette.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isLocked ? Colors.grey : AppPalette.accent,
                          ),
                          minHeight: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isLocked
                            ? "Locked until previous category is complete"
                            : "${category.completedLessons}/${category.totalLessons} Lessons Completed",
                        style: TextStyle(
                          fontSize: 14,
                          color: isLocked ? Colors.grey : theme.titleText.withValues(alpha: 0.65),
                          fontStyle: FontStyle.italic,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (!isLocked)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: theme.onPrimary,
                      size: 32,
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock,
                      color: Colors.grey,
                      size: 28,
                    ),
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