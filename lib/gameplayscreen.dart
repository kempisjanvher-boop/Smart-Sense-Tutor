import 'dart:ui';

import 'package:flutter/material.dart';

import 'core/app_categories.dart';
import 'core/app_palette.dart';
import 'difficulty_theme.dart';
import 'models/category_visual_theme.dart';
import 'models/difficulty.dart';
import 'models/quiz_question.dart';
import 'services/level_manager.dart';
import 'services/quiz_engine.dart';
import 'progress.dart';

class GameplayScreen extends StatefulWidget {
  final String category;
  final int levelNumber;
  final String levelName;
  final Difficulty difficulty;

  const GameplayScreen({
    super.key,
    required this.category,
    required this.levelNumber,
    required this.levelName,
    required this.difficulty,
  });

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> with SingleTickerProviderStateMixin {
  // Step tracker: 0 = Sentence view, 1 = Choice List, 2 = Question Result, 3 = Final Level Summary
  int _currentStep = 0;

  int _currentQuestionIndex = 0;
  int _starsEarnedThisQuestion = 3;
  int? _selectedOptionIndex;
  bool? _isSelectionCorrect;

  final Set<int> _wrongAttempts = {};

  // Tracks stars captured in each distinct question round
  final List<int> _scoreHistoryList = [];

  AnimationController? _timerController;

  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  String? _loadError;

  List<Map<String, dynamic>> get _questionBank =>
      _questions.map((q) => q.toLegacyMap()).toList();

  CategoryVisualTheme get _theme =>
      CategoryVisualTheme.forCategory(widget.category);

  Difficulty get _difficulty => widget.difficulty;

  // 🔥 REAL AUTO-UPDATING VALUE
  int get _streakCount =>
      ProgressService().getTotalCompletedAll();


  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final generated = await QuizEngine.instance.questionsForLevel(
        category: AppCategories.normalize(widget.category),
        level: widget.levelNumber,
        difficulty: widget.difficulty,
      );
      if (!mounted) return;
      setState(() {
        _questions = generated;
        _isLoading = false;
      });
      _initTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  void _initTimer() {
    _timerController?.dispose();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: LevelManager.timerSecondsForDifficulty(widget.difficulty),
      ),
    )..addListener(() {
      setState(() {});
    });

    _startTimer();
  }

  void _startTimer() {
    final controller = _timerController;
    if (controller == null) return;
    controller.reset();
    controller.forward().then((value) {
      if (mounted && _currentStep < 2 && _selectedOptionIndex == null) {
        setState(() {
          _starsEarnedThisQuestion = 0;
          _isSelectionCorrect = false;
          _scoreHistoryList.add(0); // Timed out gives 0 stars
          _currentStep = 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController?.dispose();
    super.dispose();
  }

  void _handleOptionSelection(int index, int correctIndex) {
    if (_wrongAttempts.contains(index) || _selectedOptionIndex != null) return;

    if (index == correctIndex) {
      setState(() {
        _selectedOptionIndex = index;
        _isSelectionCorrect = true;
      });
      _timerController?.stop();
      _scoreHistoryList.add(_starsEarnedThisQuestion);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _currentStep = 2;
          });
        }
      });
    } else {
      setState(() {
        _wrongAttempts.add(index);
        if (_starsEarnedThisQuestion > 1) {
          _starsEarnedThisQuestion--;
        }
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Not quite! One star deducted. Try another definition! 🌟",
          ),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: _theme.secondary,
        ),
      );
    }
  }

  void _handleNextAction() {
    if (_questions.isEmpty) return;
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _currentStep = 0;
        _selectedOptionIndex = null;
        _isSelectionCorrect = null;
        _starsEarnedThisQuestion = 3;
        _wrongAttempts.clear();
      });
      _startTimer();
    } else {
      setState(() {
        _currentStep = 3;
      });
    }
  }

  int _calculateAverageStars() {
    if (_scoreHistoryList.isEmpty) return 0;
    final double rawAverage = _scoreHistoryList.reduce((a, b) => a + b) / _scoreHistoryList.length;
    return rawAverage.round();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _theme.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _theme.primary),
              const SizedBox(height: 16),
              Text(
                'Generating your quiz...',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _theme.titleText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_loadError != null || _questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.levelName)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _loadError ?? 'No questions available for this level.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questionBank[_currentQuestionIndex];

    if (_currentStep == 2) {
      return _buildSummaryScreen(currentQuestion);
    }
    if (_currentStep == 3) {
      return _buildFinalLevelCompletionScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/gameplayscreen.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          color: _theme.secondary,
                          size: 36,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: DifficultyTheme.badgeColor(_difficulty),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2.5),
                                boxShadow: DifficultyTheme.badgeShadow(_difficulty),
                              ),
                              child: Text(
                                _difficulty.headerLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Category: ${currentQuestion['category']}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: _theme.titleText.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(3, (index) {
                          return Icon(
                            Icons.star_rounded,
                            color: index < _starsEarnedThisQuestion
                                ? _theme.starColor
                                : Colors.grey[400],
                            size: 22,
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Stack(
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      ),
                      FractionallySizedBox(
                        widthFactor: 1.0 - (_timerController?.value ?? 0),
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppPalette.timerFill,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _currentStep == 0
                        ? _buildSentenceView(currentQuestion)
                        : _buildMultipleChoiceView(currentQuestion),
                  ),
                ),

                Positioned(
                  bottom: 30,
                  right: 40,
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {});
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: _streakCount > 0
                                ? const LinearGradient(
                              colors: [
                                Color(0xFFFFCE56),
                                Color(0xFFFF705D),
                                Color(0xFF92B3F3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                                : LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),

                      if (_streakCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "$_streakCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceView(Map<String, dynamic> question) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start, // Moved up to layout from the top
      children: [
        const SizedBox(height: 16), // Breathability gap right below the bar layout
        Text(
          widget.levelName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppPalette.navy,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Click the highlighted word to choose the correct definition.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppPalette.mutedText),
        ),
        const SizedBox(height: 24), // Adjusted gap sizing to pull container higher up
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppPalette.gameplayCard,
                  AppPalette.gameplayCard2,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(28),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: question["sentenceBefore"]),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: GestureDetector(
                      onTap: () => setState(() => _currentStep = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppPalette.sentenceHighlight,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          question["word"],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.sentenceHighlight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: question["sentenceAfter"]),
                ],
              ),
            ),
          ),
        ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceView(Map<String, dynamic> question) {
    final List<dynamic> options = question["options"];
    final int correctIndex = question["correctIndex"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: _theme.titleText, size: 24),
          onPressed: () => setState(() => _currentStep = 0),
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            question["word"].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _theme.titleText,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const Align(
          alignment: Alignment.center,
          child: Text(
            "Choose the correct definition based on the sentence.",
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];

              bool isCorrectAnswer = (index == correctIndex);
              bool isSelectedCorrectly = (_selectedOptionIndex == index && isCorrectAnswer);
              bool hasAttemptedWrong = _wrongAttempts.contains(index);

              Color cardBgColor = Colors.white;
              Color borderColor = Colors.white;

              if (isSelectedCorrectly) {
                cardBgColor = const Color(0xFFC6F6D5);
                borderColor = Colors.green;
              } else if (hasAttemptedWrong) {
                cardBgColor = const Color(0xFFFED7D7);
                borderColor = Colors.red;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () => _handleOptionSelection(index, correctIndex),
                  child: Container(
                    padding: EdgeInsets.all(_difficulty == Difficulty.hard ? 14 : 16),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: borderColor,
                        width: _difficulty == Difficulty.hard ? 1.6 : 2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _theme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(option["icon"], color: _theme.onPrimary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            option["text"],
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryScreen(Map<String, dynamic> _) {
    final showNiceTry =
        !(_isSelectionCorrect ?? false) || _starsEarnedThisQuestion == 1;

    final String titleText = showNiceTry ? 'Nice Try' : 'GREAT JOB!';

    final String imageAsset = showNiceTry
        ? 'asset/nicetrylogo.png'
        : 'asset/greatjoblogo.png';

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset('asset/gameplayscreen.png', fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.80,
              constraints: const BoxConstraints(maxWidth: 360),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 75),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Image.asset(imageAsset, fit: BoxFit.contain),
                          ),
                        ),
                        if (!showNiceTry) ...[
                          const Text(
                            "You've completed a lesson!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.bodyText,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: Row(
                            children: [
                              Expanded(
                                child: _summaryActionButton(
                                  label: 'DONE',
                                  color: AppPalette.doneButton,
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _summaryActionButton(
                                  label: _currentQuestionIndex <
                                          _questionBank.length - 1
                                      ? 'NEXT'
                                      : 'FINISH',
                                  color: AppPalette.nextButton,
                                  onPressed: _starsEarnedThisQuestion < 1
                                      ? null
                                      : _handleNextAction,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'asset/ribbon.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 36,
                          child: Text(
                            titleText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -50,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Transform.translate(
                          offset: const Offset(12, 12),
                          child: Transform.rotate(
                            angle: -0.25,
                            child: Icon(
                              Icons.star_rounded,
                              color: _starsEarnedThisQuestion >= 2
                                  ? AppPalette.star
                                  : Colors.grey[300],
                              size: 64,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(3, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(5, 15),
                          child: Icon(
                            Icons.star_rounded,
                            color: _starsEarnedThisQuestion >= 1
                                ? AppPalette.star
                                : Colors.grey[300],
                            size: 96,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(2, 4),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-12, 12),
                          child: Transform.rotate(
                            angle: 0.25,
                            child: Icon(
                              Icons.star_rounded,
                              color: _starsEarnedThisQuestion == 3
                                  ? AppPalette.star
                                  : Colors.grey[300],
                              size: 64,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(2, 4),
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
          ),
        ],
      ),
    );
  }

  Widget _summaryActionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withValues(alpha: 0.45),
        disabledForegroundColor: Colors.white70,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white24, width: 1.5),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFinalLevelCompletionScreen() {
    final int averageStars = _calculateAverageStars();
    final showNiceTry = averageStars <= 1;
    final titleText = showNiceTry ? 'Nice Try' : 'GREAT JOB!';
    final imageAsset = showNiceTry
        ? 'asset/nicetrylogo.png'
        : 'asset/greatjoblogo.png';

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset('asset/gameplayscreen.png', fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 360),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 75),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Image.asset(imageAsset, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return Icon(
                              Icons.star_rounded,
                              color: index < averageStars
                                  ? AppPalette.star
                                  : Colors.grey[300],
                              size: 44,
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Average Score: $averageStars / 3 Stars',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _theme.titleText,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
                          child: SizedBox(
                            width: double.infinity,
                            child: _summaryActionButton(
                              label: 'Level Complete',
                              color: AppPalette.levelCompleteButton,
                              onPressed: () =>
                                  Navigator.pop(context, averageStars),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'asset/ribbon.png',
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                        Positioned(
                          top: 36,
                          child: Text(
                            titleText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
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
          ),
        ],
      ),
    );
  }
}