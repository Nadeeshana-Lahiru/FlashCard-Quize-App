import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/tts_service.dart';

class FlippableCard extends StatefulWidget {
  final Flashcard flashcard;
  final bool showAnswer;
  final VoidCallback onTap;

  const FlippableCard({
    Key? key,
    required this.flashcard,
    required this.showAnswer,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FlippableCard> createState() => _FlippableCardState();
}

class _FlippableCardState extends State<FlippableCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final shadowColor = isDark ? Colors.black45 : Colors.black12;

    return GestureDetector(
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: widget.showAnswer ? pi : 0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutBack,
        builder: (context, val, child) {
          bool isFrontVisible = val < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(val),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              constraints: const BoxConstraints(minHeight: 350, maxHeight: 550),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: isFrontVisible
                  ? _buildFront(context)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBack(context),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final hasImage = widget.flashcard.imagePath != null && widget.flashcard.imagePath!.isNotEmpty;

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasImage) ...[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(
                            widget.flashcard.imagePath!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          )
                        : Image.file(
                            File(widget.flashcard.imagePath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                "Question",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.flashcard.question,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.blueAccent),
              onPressed: () {
                ttsService.speak(widget.flashcard.question);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Answer",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.flashcard.answer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
            child: IconButton(
              icon: const Icon(Icons.volume_up, color: Colors.green),
              onPressed: () {
                ttsService.speak(widget.flashcard.answer);
              },
            ),
          ),
        ),
      ],
    );
  }
}
