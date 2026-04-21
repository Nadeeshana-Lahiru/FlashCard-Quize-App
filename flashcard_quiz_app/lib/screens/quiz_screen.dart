import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/flippable_card.dart';
import 'manage_flashcards_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const QuizScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;

  void _nextCard(int totalCards) {
    setState(() {
      _showAnswer = false;
      if (_currentIndex < totalCards - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
    });
  }

  void _previousCard(int totalCards) {
    setState(() {
      _showAnswer = false;
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = totalCards - 1;
      }
    });
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
      if (_showAnswer) {
          Provider.of<SettingsProvider>(context, listen: false).logCardReview();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageFlashcardsScreen(categoryId: widget.categoryId)),
              );
            },
            tooltip: "Manage Flashcards",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final categoryCards = provider.getCardsByCategory(widget.categoryId);

          if (categoryCards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 80, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 24),
                  Text('Empty Category', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add Flashcards to study this subject', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManageFlashcardsScreen(categoryId: widget.categoryId)),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Flashcards'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  )
                ],
              ),
            );
          }

          if (_currentIndex >= categoryCards.length) {
            _currentIndex = 0;
          }

          final currentCard = categoryCards[_currentIndex];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_currentIndex + 1} / ${categoryCards.length}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: Center(
                      child: FlippableCard(
                        flashcard: currentCard,
                        showAnswer: _showAnswer,
                        onTap: _toggleAnswer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _toggleAnswer,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _showAnswer ? "Show Question" : "Show Answer",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _previousCard(categoryCards.length),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                        label: const Text("Previous"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                         onPressed: () => _nextCard(categoryCards.length),
                        icon: const Text("Next"),
                        label: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
