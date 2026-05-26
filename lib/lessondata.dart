import 'package:flutter/material.dart';
import 'package:smart_sense_tutor/smartlookup.dart';
import 'levelmap.dart';
import 'homescreen.dart';
import 'progress.dart';

class LessonData extends StatefulWidget {
  const LessonData({super.key});

  @override
  State<LessonData> createState() => _LessonDataState();


}

class LessonCategory {
  final String title;
  final int totalLessons;
  final int completedLessons;

  LessonCategory({
    required this.title,
    required this.totalLessons,
    required this.completedLessons,
  });

  double get progressPercentage =>
      totalLessons > 0 ? completedLessons / totalLessons : 0.0;
}

class _LessonDataState extends State<LessonData> {
  int _currentIndex = 1;

  final List<LessonCategory> _categories = [
    LessonCategory(
      title: "Tech & Tradition",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Tech & Tradition"),
    ),
    LessonCategory(
      title: "Finance & Physics",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Finance & Physics"),
    ),
    LessonCategory(
      title: "Objects & Ideas",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Objects & Ideas"),
    ),
    LessonCategory(
      title: "Law & Structure",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Law & Structure"),
    ),
    LessonCategory(
      title: "Attributes & Evaluation",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Attributes & Evaluation"),
    ),
    LessonCategory(
      title: "Actions & Movement",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Actions & Movement"),
    ),
    LessonCategory(
      title: "Directions & Space",
      totalLessons: 3,
      completedLessons: ProgressService.getCompleted("Directions & Space"),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // refresh progress when coming back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF70D3F4),
        elevation: 0,

        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            "Lessons",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C4379),
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C4379),
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
        itemCount: _categories.length,
        separatorBuilder: (context, index) =>
        const SizedBox(height: 20),
        itemBuilder: (context, index) {
          return _buildLessonCard(_categories[index]);
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

  Widget _buildLessonCard(LessonCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelMap(
              category: category.title, // ✅ FIXED HERE
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: category.progressPercentage,
                      backgroundColor: const Color(0xFFE5E5E5),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFF8A5B),
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${category.completedLessons}/${category.totalLessons} Lessons Completed",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF62D275),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}