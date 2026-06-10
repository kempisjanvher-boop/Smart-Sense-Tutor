import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:smart_sense_tutor/account/profile.dart';
import 'homescreen.dart';
import 'lessondata.dart';
import 'smartlookupresult.dart';
import 'analyzer/polysemy_analyzer.dart';

class SmartLookup extends StatefulWidget {
  const SmartLookup({super.key});

  @override
  State<SmartLookup> createState() => _SmartLookupState();
}

class _SmartLookupState extends State<SmartLookup> {
  final TextEditingController _searchController = TextEditingController();
  final int _currentIndex = 2; // Matches 'Smart Lookup' highlighted tab
  bool _isDatasetLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnalyzer();
  }

  /// Ensures data is fully resident in memory before allowing input matches
  Future<void> _initializeAnalyzer() async {
    if (PolysemyAnalyzer.excelDataset.isEmpty) {
      await PolysemyAnalyzer.loadDataset();
    }
    if (mounted) {
      setState(() {
        _isDatasetLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Centralized logic to analyze input text and navigate to the result screen
  void _processSearchAnalysis() {
    String textInput = _searchController.text.trim();

    if (textInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a word or sentence to analyze!')),
      );
      return;
    }

    List<String> inputTokens = textInput
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .toList();

    String detectedKeyword = "";

    Set<String> validKeywordsInExcel = PolysemyAnalyzer.excelDataset
        .map((row) => (row["word"] ?? "").toLowerCase().trim())
        .where((word) => word.isNotEmpty)
        .toSet();

    for (var token in inputTokens) {
      if (validKeywordsInExcel.contains(token)) {
        detectedKeyword = token;
        break;
      }
    }

    if (detectedKeyword.isEmpty && inputTokens.isNotEmpty) {
      detectedKeyword = inputTokens.first;
    }

    // Generate context results array parameters from your engine
    List<WordMeaning> computedMeanings = PolysemyAnalyzer.analyzeContext(detectedKeyword, textInput);

    // SAFETY FALLBACK: If your analyzer completely bypasses the mock list mapping or returns nothing,
    // explicitly inject the "Database Alert" title object so both screens are aligned.
    if (computedMeanings.isEmpty) {
      computedMeanings = [
        WordMeaning(
          title: "Database Alert",
          definition: "No matching rows found for '$detectedKeyword'.",
          example: detectedKeyword,
          confidenceScore: 0.0,
        )
      ];
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartLookupResult(
          searchedWord: detectedKeyword,
          dynamicMeanings: computedMeanings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF70D3F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Smart Lookup",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isDatasetLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF70D3F4)),
            SizedBox(height: 16),
            Text(
              "Loading vocabulary engine...",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            )
          ],
        ),
      )
          : Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F7FF),
              Color(0xFFF3F8FB),
              Color(0xFFFFFFFF),
            ],
            stops: [0.0, 0.4, 0.8],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Experience\nSmarter\nVocabulary\nLearning with AI.",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                  color: Color(0xFF2C4379),
                ),
              ),
              const SizedBox(height: 35),

              SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 30,
                      left: 24,
                      child: Transform.rotate(
                        angle: -0.08,
                        child: const Text(
                          "Try these examples",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 50,
                      left: 40,
                      right: 100,
                      child: Transform.rotate(
                        angle: -0.08,
                        child: _buildExampleBubble(
                          textBefore: "The ",
                          keyword: "ring",
                          textAfter: " is made out of gold.",
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 100,
                      right: 20,
                      child: Transform.rotate(
                        angle: 0.02,
                        child: _buildExampleBubble(
                          textBefore: "The ",
                          keyword: "bank",
                          textAfter: " approved his loan request.",
                        ),
                      ),
                    ),

                    Positioned(
                      right: 16,
                      top: 4,
                      child: SizedBox(
                        width: 130,
                        height: 150,
                        child: Image.asset(
                          'asset/smartlookup.png',
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_nature_rounded,
                              size: 85,
                              color: Color(0xFF2C4379),
                            );
                          },
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // Search Bar Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 18),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _processSearchAnalysis(),
                  decoration: InputDecoration(
                    hintText: "Enter a word or sentence to learn...",
                    hintStyle: const TextStyle(color: Colors.black38, fontSize: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    border: InputBorder.none,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: InkWell(
                        onTap: _processSearchAnalysis,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF62D275),
                              width: 3,
                            ),
                            gradient: const SweepGradient(
                              colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.red],
                              stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Analyze Processing Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _processSearchAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF70D3F4),
                    elevation: 2,
                    shadowColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Analyze",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

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
            case 3:
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              break;
          }
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

  Widget _buildExampleBubble({
    required String textBefore,
    required String keyword,
    required String textAfter,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 17, color: Colors.black, height: 1.35),
          children: [
            TextSpan(text: textBefore),
            TextSpan(
              text: keyword,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    _searchController.text = keyword.trim();
                  });
                },
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8A5B),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFFF8A5B),
                decorationThickness: 2,
              ),
            ),
            TextSpan(text: textAfter),
          ],
        ),
      ),
    );
  }
}