import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../services/gemini_grader_service.dart';

class TypingQuizScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const TypingQuizScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<TypingQuizScreen> createState() => _TypingQuizScreenState();
}

class _TypingQuizScreenState extends State<TypingQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  bool _isGrading = false;
  bool _quizFinished = false;
  GradingResult? _gradingResult;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late List<Flashcard> _cards;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    _cards = provider.getCardsByCategory(widget.categoryId)..shuffle();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAnswer() async {
    if (_answered || _inputController.text.trim().isEmpty) return;

    setState(() => _isGrading = true);
    _focusNode.unfocus();

    // Cache providers before async gap
    final flashcardProvider = Provider.of<FlashcardProvider>(
      context,
      listen: false,
    );
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    final card = _cards[_currentIndex];
    final result = await GeminiGraderService.gradeAnswer(
      question: card.question,
      correctAnswer: card.answer,
      studentAnswer: _inputController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isGrading = false;
      _answered = true;
      _gradingResult = result;
      if (result.isPassing) {
        _score++;
      }
    });

    if (result.isPassing) {
      flashcardProvider.incrementMastery(card.id);
    }
    settingsProvider.logCardReview();
  }

  void _nextQuestion() {
    setState(() {
      if (_currentIndex >= _cards.length - 1) {
        _quizFinished = true;
      } else {
        _currentIndex++;
        _answered = false;
        _gradingResult = null;
        _inputController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.categoryName}: Typing',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: _quizFinished ? _buildResults() : _buildQuiz(),
    );
  }

  Widget _buildResults() {
    final percentage = (_score / _cards.length * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              percentage >= 70 ? Icons.emoji_events : Icons.school,
              size: 100,
              color: percentage >= 70 ? Colors.amber : Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            Text(
              "Typing Quiz Complete!",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "$_score / ${_cards.length}",
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$percentage% Score",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text(
                "Back to Subjects",
                style: TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final card = _cards[_currentIndex];
    final hasImage = card.imagePath != null && card.imagePath!.isNotEmpty;
    final result = _gradingResult;

    // Determine answer field tint color based on grading result
    Color? fieldFill;
    if (_answered && result != null) {
      if (result.score >= 70) {
        fieldFill = Colors.green.withAlpha(40);
      } else if (result.score >= 40) {
        fieldFill = Colors.orange.withAlpha(40);
      } else {
        fieldFill = Colors.red.withAlpha(40);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          Row(
            children: [
              Text(
                "${_currentIndex + 1} / ${_cards.length}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / _cards.length,
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question Card
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withAlpha(80),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(
                            card.imagePath!,
                            height: 150,
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(card.imagePath!),
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  card.question,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Answer Input
          TextField(
            controller: _inputController,
            focusNode: _focusNode,
            enabled: !_answered && !_isGrading,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Type your answer here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: fieldFill,
              alignLabelWithHint: true,
            ),
            onSubmitted: (_) => _checkAnswer(),
          ),
          const SizedBox(height: 16),

          // AI Grading Result Card
          if (_answered && result != null) ...[
            _buildGradingResultCard(result, card.answer),
            const SizedBox(height: 16),
          ],

          // Submit / Next Button
          if (_isGrading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    "Wait for grading your answer...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            FilledButton(
              onPressed: _answered ? _nextQuestion : _checkAnswer,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _answered
                    ? (result != null && result.isPassing
                          ? Colors.green
                          : Colors.redAccent)
                    : null,
              ),
              child: Text(
                _answered
                    ? (_currentIndex == _cards.length - 1
                          ? "Finish Quiz"
                          : "Next Question →")
                    : "Submit Answer",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradingResultCard(GradingResult result, String correctAnswer) {
    Color cardColor;
    Color scoreColor;
    IconData scoreIcon;
    String verdict;

    if (result.score >= 90) {
      cardColor = Colors.green.withAlpha(30);
      scoreColor = Colors.green;
      scoreIcon = Icons.check_circle;
      verdict = "Excellent! ✨";
    } else if (result.score >= 70) {
      cardColor = Colors.green.withAlpha(20);
      scoreColor = Colors.green;
      scoreIcon = Icons.check_circle_outline;
      verdict = "Mostly Correct 👍";
    } else if (result.score >= 40) {
      cardColor = Colors.orange.withAlpha(30);
      scoreColor = Colors.orange;
      scoreIcon = Icons.warning_amber_rounded;
      verdict = "Partially Correct 🤔";
    } else {
      cardColor = Colors.red.withAlpha(25);
      scoreColor = Colors.redAccent;
      scoreIcon = Icons.cancel_outlined;
      verdict = "Needs Improvement 📚";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withAlpha(80), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Score Row
          Row(
            children: [
              Icon(scoreIcon, color: scoreColor, size: 28),
              const SizedBox(width: 10),
              Text(
                verdict,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: scoreColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${result.score}/100",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Correct Answer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Model Answer:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(correctAnswer, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // AI Feedback
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: scoreColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.isAiGraded ? "Gemini AI Feedback:" : "Feedback:",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(result.feedback, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
