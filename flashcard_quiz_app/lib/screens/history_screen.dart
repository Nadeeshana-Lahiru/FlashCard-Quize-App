import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/flashcard_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          final historyCards = provider.historyCards;

          if (historyCards.isEmpty) {
            return const Center(child: Text("No history available. Create some cards!"));
          }

          return ListView.builder(
            itemCount: historyCards.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final card = historyCards[index];
              final category = provider.getCategoryById(card.categoryId);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(category?.colorValue ?? 0xFF2563EB),
                    child: const Icon(Icons.style, color: Colors.white, size: 18),
                  ),
                  title: Text(card.question, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Created: ${DateFormat.yMMMd().add_jm().format(card.createdAt)}",
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
