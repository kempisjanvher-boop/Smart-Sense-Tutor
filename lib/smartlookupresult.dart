import 'dart:core';
import 'package:flutter/material.dart';
import 'package:smart_sense_tutor/account/profile.dart';
import 'homescreen.dart';
import 'lessondata.dart';
import 'smartlookup.dart';
import 'analyzer/polysemy_analyzer.dart';

class SmartLookupResult extends StatefulWidget {
  final String searchedWord;
  final List<WordMeaning> dynamicMeanings;

  const SmartLookupResult({
    super.key,
    required this.searchedWord,
    required this.dynamicMeanings,
  });

  @override
  State<SmartLookupResult> createState() => _SmartLookupResultState();
}

class _SmartLookupResultState extends State<SmartLookupResult> {
  final int _currentIndex = 2;

  // ─── FLOATING INLINE CONTROLLER STATE PROPERTIES ───
  bool _isInlineSearchVisible = false;
  final TextEditingController _inlineSearchController = TextEditingController();

  @override
  void dispose() {
    _inlineSearchController.dispose();
    super.dispose();
  }

  // Triggered when a user executes a brand new query from this screen
  void _executeNewSearch(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final newMeanings = PolysemyAnalyzer.getMeaningsForWord(cleanQuery);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SmartLookupResult(
          searchedWord: cleanQuery,
          dynamicMeanings: newMeanings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // UNIFIED CHECK: Securely catches "Database Alert", "Not Found", and definition fragment anomalies
    final bool isWordMissing = widget.dynamicMeanings.isEmpty ||
        (widget.dynamicMeanings.length == 1 &&
            (widget.dynamicMeanings.first.title == "Database Alert" ||
                widget.dynamicMeanings.first.title == "Not Found" ||
                widget.dynamicMeanings.first.definition.contains("No matching rows")));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF70D3F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Smart Lookup",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 4.0),
            child: Image.asset(
              'asset/smartlookup.png',
              width: 44,
              height: 44,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.emoji_nature_rounded, color: Colors.white, size: 30);
              },
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F7FF), Color(0xFFF3F8FB), Color(0xFFFFFFFF)],
            stops: [0.0, 0.3, 0.7],
          ),
        ),
        child: Column(
          children: [
            // 1. Alert Banner Subheader
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7),
                border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Color(0xFF4A4A4A)),
                  children: [
                    if (isWordMissing) ...[
                      const TextSpan(text: "Not found: "),
                      TextSpan(
                        text: '"${widget.searchedWord}"',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                      ),
                    ] else ...[
                      const TextSpan(text: "Multiple meanings detected for "),
                      TextSpan(
                        text: '"${widget.searchedWord}"',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A5B)),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 2. Main Scrolling Card Area
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFBF9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.7), width: 1.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
                              child: Text(
                                "Polysemy Explorer",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C4379)),
                              ),
                            ),

                            // Explanatory Paragraph
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 15.5, color: Color(0xFF4A4A4A), height: 1.4),
                                  children: [
                                    if (isWordMissing) ...[
                                      const TextSpan(text: "The word "),
                                      TextSpan(
                                        text: '"${widget.searchedWord}"',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE53935)),
                                      ),
                                      const TextSpan(
                                        text: " was not found in our lesson database. This means it either has a single literal meaning or hasn't been added to our vocabulary tracks yet.",
                                      ),
                                    ] else ...[
                                      const TextSpan(text: "The AI detected that "),
                                      TextSpan(
                                        text: '"${widget.searchedWord}"',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A5B)),
                                      ),
                                      const TextSpan(text: " is a polysemous word. Explore its different meanings and usage examples below:"),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Display entries or clear placeholder graphic layout block
                            if (!isWordMissing)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.dynamicMeanings.length,
                                itemBuilder: (context, index) {
                                  final meaning = widget.dynamicMeanings[index];
                                  return _buildMeaningSection(
                                    title: meaning.title,
                                    definition: meaning.definition,
                                    example: meaning.example,
                                    keyword: widget.searchedWord,
                                    isLast: index == widget.dynamicMeanings.length - 1,
                                  );
                                },
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.find_in_page_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text(
                                      "Not Found in Database",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. FLOATING COMPONENT AREA (Morphic Search Field Wrapped Around Colorful Circle)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOutCubic,
                      width: _isInlineSearchVisible ? (MediaQuery.of(context).size.width - 32) : 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          if (_isInlineSearchVisible)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: TextField(
                                  controller: _inlineSearchController,
                                  autofocus: true,
                                  style: const TextStyle(fontSize: 17),
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: _executeNewSearch,
                                  decoration: const InputDecoration(
                                    hintText: "Search another word...",
                                    hintStyle: TextStyle(color: Colors.black38, fontSize: 17),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),

                          // The Exact AI Anchor Button Action Container
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_isInlineSearchVisible) {
                                    if (_inlineSearchController.text.trim().isNotEmpty) {
                                      _executeNewSearch(_inlineSearchController.text);
                                    } else {
                                      _isInlineSearchVisible = false;
                                    }
                                  } else {
                                    _isInlineSearchVisible = true;
                                  }
                                });
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF62D275), width: 3.5),
                                  gradient: const SweepGradient(
                                    colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.red],
                                  ),
                                ),
                                child: Icon(
                                  _isInlineSearchVisible ? Icons.search : Icons.psychology_alt_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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

  Widget _buildMeaningSection({
    required String title,
    required String definition,
    required String example,
    required String keyword,
    bool isLast = false,
  }) {
    List<TextSpan> parseExampleSpans(String fullExample, String targetWord) {
      final cleanTarget = targetWord.toLowerCase().trim();
      final escapedTarget = RegExp.escape(cleanTarget);
      final regex = RegExp('($escapedTarget)', caseSensitive: false);
      final matches = regex.allMatches(fullExample);

      if (matches.isEmpty) {
        return [TextSpan(text: fullExample, style: const TextStyle(fontStyle: FontStyle.italic))];
      }

      List<TextSpan> spans = [];
      int lastMatchEnd = 0;

      for (var match in matches) {
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: fullExample.substring(lastMatchEnd, match.start),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ));
        }
        spans.add(TextSpan(
          text: fullExample.substring(match.start, match.end),
          style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Color(0xFF2C3E50)),
        ));
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < fullExample.length) {
        spans.add(TextSpan(
          text: fullExample.substring(lastMatchEnd),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ));
      }

      return spans;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black26, width: 1.5)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0, right: 8.0),
                child: Text("📖", style: TextStyle(fontSize: 14)),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF4A4A4A), height: 1.35),
                    children: [
                      const TextSpan(text: "Definition: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEBBB3A))),
                      TextSpan(text: definition),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2.0, right: 8.0),
                child: Text("💬", style: TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Color(0xFF555555), height: 1.35),
                    children: [
                      const TextSpan(text: "Example: ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF81C281))),
                      ...parseExampleSpans(example, keyword),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isLast) const SizedBox(height: 4),
        ],
      ),
    );
  }
}