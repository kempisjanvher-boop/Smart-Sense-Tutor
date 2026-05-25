import 'package:flutter/material.dart';
import 'levelmap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
                _buildStatCard("nth", "Lesson(s)\nin progress", const Color(0xFFFFEAEA), Icons.face_outlined),
                _buildStatCard("nth", "Lessons\ncompleted", const Color(0xFFE8F9EE), Icons.pets_outlined),
                _buildStatCard("nth", "Categories\ncompleted", const Color(0xFFEAEAFF), Icons.apps_outlined),
                _buildStatCard("nth", "Achievements", const Color(0xFFFFF7E0),
                  Icons.emoji_events_outlined),
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
            _buildCategoryCard("Tech & Tradition", isFullWidth: true),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("Finance &\nPhysics")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Objects &\nIdeas")),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("All About\nMe...")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Feelings")),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildCategoryCard("Greetings")),
                const SizedBox(width: 12),
                Expanded(child: _buildCategoryCard("Settings")),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C3E6B),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Lessons"),
          BottomNavigationBarItem(icon: Icon(Icons.send), label: "Smart Lookup"),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: "More"),
        ],
      ),
    );
  }

  Widget _buildStatCard(String count, String label, Color iconBgColor, IconData fallback) {
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
              child: Icon(fallback, size: 20, color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String title, {bool isFullWidth = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LevelMap()),
        );
      },
    child: Container(
      height: isFullWidth ? 100 : 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:  const Color(0xFFE2E8F0),
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C3E6B),
          )
        ),
      ),
    );
  }
}