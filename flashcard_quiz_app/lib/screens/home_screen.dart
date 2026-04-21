import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/settings_provider.dart';
import '../models/category.dart';
import 'quiz_screen.dart';
import 'multiple_choice_screen.dart';
import 'typing_quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text('${settings.currentStreak}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
             );
          },
          tooltip: "Settings",
        ),
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 80, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 24),
                  Text('No Subjects yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Create a subject to begin organizing flashcards', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context, provider),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Subject'),
                  )
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: provider.categories.length,
            itemBuilder: (context, index) {
              final category = provider.categories[index];
              return Stack(
                children: [
                  InkWell(
                    onTap: () {
                      _showStudyModeSelection(context, provider, category);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(category.colorValue).withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(category.colorValue).withAlpha(100), width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder, size: 48, color: Color(category.colorValue)),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              category.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${provider.getCardsByCategory(category.id).length} cards",
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: provider.getCategoryMastery(category.id),
                                minHeight: 6,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  provider.getCategoryMastery(category.id) >= 0.8 
                                      ? Colors.green 
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ⋮ Context Menu Button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Color(category.colorValue),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameCategoryDialog(context, provider, category.id, category.name);
                          } else if (value == 'delete') {
                            _showDeleteCategoryDialog(context, provider, category.id, category.name);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: ListTile(
                              leading: Icon(Icons.edit, color: Colors.blue),
                              title: Text('Rename'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete_outline, color: Colors.red),
                              title: Text('Delete', style: TextStyle(color: Colors.red)),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
           final provider = Provider.of<FlashcardProvider>(context, listen: false);
           _showAddCategoryDialog(context, provider);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Subject'),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, FlashcardProvider provider) {
    final TextEditingController nameController = TextEditingController();
    
    // Pick a random beautiful color mapping
    final colors = [0xFFEF4444, 0xFFF59E0B, 0xFF10B981, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEC4899];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Subject Name (e.g. Science)'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                 final randomColor = colors[DateTime.now().millisecond % colors.length];
                 provider.addCategory(nameController.text.trim(), randomColor);
                 Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      )
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, FlashcardProvider provider, String id, String name) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Subject?'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(text: '"$name"', style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(text: '? This will permanently remove the subject and '),
              const TextSpan(text: 'ALL flashcards inside it.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteCategory(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$name" deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete'),
          ),
        ],
      )
    );
  }

  void _showRenameCategoryDialog(BuildContext context, FlashcardProvider provider, String id, String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Rename Subject'),
          ],
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Subject Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              provider.renameCategory(id, value.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Renamed to "${value.trim()}"')),
              );
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                provider.renameCategory(id, newName);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Renamed to "$newName"')),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  void _showStudyModeSelection(BuildContext context, FlashcardProvider provider, FlashcardCategory category) {
    final cards = provider.getCardsByCategory(category.id);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Select Study Mode", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 24),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.style, color: Colors.white)),
                title: const Text("Classic Swiping"),
                subtitle: const Text("Read and flip normal flashcards"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(categoryId: category.id, categoryName: category.name)));
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.format_list_bulleted, color: Colors.white)),
                title: const Text("Multiple Choice"),
                subtitle: const Text("Pick the correct answer from 4 options"),
                onTap: () {
                  if (cards.length < 4) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You need at least 4 flashcards in this subject to play Multiple Choice!")));
                  } else {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MultipleChoiceScreen(categoryId: category.id, categoryName: category.name)));
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.keyboard, color: Colors.white)),
                title: const Text("Typing Quiz"),
                subtitle: const Text("Type the exact answer from memory"),
                onTap: () {
                  if (cards.isEmpty) {
                     Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You need flashcards to play this mode!")));
                  } else {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TypingQuizScreen(categoryId: category.id, categoryName: category.name)));
                  }
                },
              ),
            ],
          ),
        );
      }
    );
  }
}

