import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../services/csv_service.dart';
import 'add_edit_card_screen.dart';

class ManageFlashcardsScreen extends StatelessWidget {
  final String categoryId;

  const ManageFlashcardsScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Cards'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer<FlashcardProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'import') {
                    await _importCsv(context, provider);
                  } else if (value == 'export') {
                    await _exportCsv(context, provider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'import',
                    child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('Import CSV'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Share Deck'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          final categoryCards = provider.getCardsByCategory(categoryId);

          if (categoryCards.isEmpty) {
            return const Center(
              child: Text('You have no flashcards in this subject. Add some!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100, top: 16),
            itemCount: categoryCards.length,
            itemBuilder: (context, index) {
              final card = categoryCards[index];
              return Dismissible(
                key: Key(card.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Icon(Icons.delete, color: Colors.white, size: 32),
                ),
                confirmDismiss: (direction) async {
                  return await _confirmDeleteForm(context);
                },
                onDismissed: (_) {
                  provider.deleteFlashcard(card.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Flashcard deleted')),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      card.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        card.answer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditCardScreen(categoryId: categoryId, flashcard: card),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: "Delete Flashcard",
                          onPressed: () async {
                              bool confirmed = await _confirmDeleteForm(context) ?? false;
                              if (confirmed) {
                                provider.deleteFlashcard(card.id);
                              }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCardScreen(categoryId: categoryId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Card'),
      ),
    );
  }

  Future<bool?> _confirmDeleteForm(BuildContext context) {
      return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this flashcard?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No, Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes, Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
  }

  Future<void> _importCsv(BuildContext context, FlashcardProvider provider) async {
    final rows = await CsvService.importFromCsv();

    if (rows == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid CSV file selected or file is empty.')),
        );
      }
      return;
    }

    for (final row in rows) {
      provider.addFlashcard(row[0], row[1], categoryId);
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Imported ${rows.length} flashcards successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _exportCsv(BuildContext context, FlashcardProvider provider) async {
    final cards = provider.getCardsByCategory(categoryId);
    if (cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cards to share. Add some first!')),
      );
      return;
    }

    // Fetch category name for the filename
    final category = provider.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => provider.categories.first,
    );

    await CsvService.exportAndShareDeck(cards, category.name);
  }
}
