import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';

class MultipleChoiceScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const MultipleChoiceScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<MultipleChoiceScreen> createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String? _selectedAnswer;
  List<String> _currentOptions = [];
  bool _quizFinished = false;

  late List<Flashcard> _cards;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    _cards = provider.getCardsByCategory(widget.categoryId)
      ..shuffle(); // Shuffle the deck for a fresh quiz each time
    _generateOptions();
  }

  void _generateOptions() {
    if (_currentIndex >= _cards.length) {
      setState(() => _quizFinished = true);
      return;
    }

    final currentCard = _cards[_currentIndex];
    final allCards = Provider.of<FlashcardProvider>(context, listen: false).getCardsByCategory(widget.categoryId);
    
    // Get wrong answers safely
    final wrongAnswers = allCards
        .where((c) => c.id != currentCard.id)
        .map((c) => c.answer)
        .toSet() 
        .toList()
      ..shuffle();

    // Pick as many distractors as possible up to 3
    final distractors = wrongAnswers.take(3).toList();
    
    _currentOptions = [...distractors, currentCard.answer]..shuffle();
  }

  void _selectAnswer(String option) {
    if (_answered) return;

    final isCorrect = option == _cards[_currentIndex].answer;

    setState(() {
      _selectedAnswer = option;
      _answered = true;
      if (isCorrect) {
        _score++;
      }
    });

    final currentCardId = _cards[_currentIndex].id;
    if (isCorrect) {
       Provider.of<FlashcardProvider>(context, listen: false).incrementMastery(currentCardId);
    }
    Provider.of<SettingsProvider>(context, listen: false).logCardReview();
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _answered = false;
      _selectedAnswer = null;
      _generateOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName}: Multiple Choice', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: _quizFinished ? _buildResults() : _buildQuiz(),
    );
  }

  Widget _buildResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars, size: 100, color: Colors.orangeAccent),
          const SizedBox(height: 24),
          Text("Quiz Complete!", style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Text("You scored $_score / ${_cards.length}", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back to Subjects", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final card = _cards[_currentIndex];
    final hasImage = card.imagePath != null && card.imagePath!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Question ${_currentIndex + 1} of ${_cards.length}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasImage) ...[
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: kIsWeb
                            ? Image.network(card.imagePath!, fit: BoxFit.contain)
                            : Image.file(File(card.imagePath!), fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    card.question,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ..._currentOptions.map((option) => _buildOptionButton(option, card.answer)).toList(),
          const SizedBox(height: 16),
          if (_answered)
            FilledButton(
               onPressed: _nextQuestion,
               style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
               ),
               child: Text(_currentIndex == _cards.length - 1 ? "Finish" : "Next", style: const TextStyle(fontSize: 16)),
            )
          else
            const SizedBox(height: 56), 
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option, String correctAnswer) {
    bool isSelected = _selectedAnswer == option;
    bool isCorrect = option == correctAnswer;
    
    Color backgroundColor = Theme.of(context).colorScheme.surface;
    Color borderColor = Theme.of(context).colorScheme.outline.withAlpha(50);
    
    if (_answered) {
      if (isCorrect) {
        backgroundColor = Colors.green.withAlpha(50);
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withAlpha(50);
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _selectAnswer(option),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                _answered && isCorrect ? Icons.check_circle : 
                (_answered && isSelected && !isCorrect ? Icons.cancel : Icons.circle_outlined),
                color: _answered && isCorrect ? Colors.green :
                       (_answered && isSelected && !isCorrect ? Colors.red : Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(option, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
