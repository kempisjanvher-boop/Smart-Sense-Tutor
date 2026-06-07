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

  // ─── NEW: INLINE CONTROLLER STATE PROPERTIES ───
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

    // Use your engine framework to resolve the new dataset array parameters
    final newMeanings = PolysemyAnalyzer.getMeaningsForWord(cleanQuery);

    // Push right back into a fresh instance viewport state cleanly
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
                    const TextSpan(text: "Multiple meanings detected for "),
                    TextSpan(
                      text: '"${widget.searchedWord}"',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A5B)),
                    ),
                  ],
                ),
              ),
            ),

            // 2. NEW: DYNAMIC INLINE SEARCH INPUT COMPONENT
            if (_isInlineSearchVisible)
              Container(
                color: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inlineSearchController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _executeNewSearch,
                        decoration: InputDecoration(
                          hintText: "Search another word...",
                          hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF2C4379)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () => _inlineSearchController.clear(),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Color(0xFF70D3F4), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isInlineSearchVisible = false;
                          _inlineSearchController.clear();
                        });
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
                    )
                  ],
                ),
              ),

            // 3. Main Scrolling Card Area
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(fontSize: 15.5, color: Color(0xFF4A4A4A), height: 1.4),
                                  children: [
                                    const TextSpan(text: "The AI detected that "),
                                    TextSpan(
                                      text: '"${widget.searchedWord}"',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8A5B)),
                                    ),
                                    const TextSpan(text: " is a polysemous word. Explore its different meanings and usage examples below:"),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 4. FLOATING AI ACTION RAINBOW RING ACCENT (NOW INTERACTIVE BUTTON)
                  Positioned(
                    right: 24,
                    bottom: 24,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isInlineSearchVisible = !_isInlineSearchVisible;
                          if (!_isInlineSearchVisible) {
                            _inlineSearchController.clear();
                          }
                        });
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF62D275), width: 3.5),
                              gradient: const SweepGradient(
                                colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.red],
                              ),
                            ),
                            child: Icon(
                              _isInlineSearchVisible ? Icons.close : Icons.psychology_alt_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
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