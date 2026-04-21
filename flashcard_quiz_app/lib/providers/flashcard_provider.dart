import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';
import '../models/category.dart';

class FlashcardProvider with ChangeNotifier {
  List<FlashcardCategory> _categories = [];
  List<Flashcard> _flashcards = [];
  bool _isLoading = true;

  List<FlashcardCategory> get categories => _categories;
  List<Flashcard> get flashcards => _flashcards;
  
  // Sort history by date descending
  List<Flashcard> get historyCards {
    final list = List<Flashcard>.from(_flashcards);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  bool get isLoading => _isLoading;

  FlashcardProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Categories
    final categoriesString = prefs.getString('flashcard_categories_v2');
    if (categoriesString != null) {
      final List<dynamic> decodedList = jsonDecode(categoriesString);
      _categories = decodedList.map((item) => FlashcardCategory.fromJson(item)).toList();
    } else {
      _categories = [
        FlashcardCategory(id: 'cat_1', name: 'Science', colorValue: 0xFF10B981),
        FlashcardCategory(id: 'cat_2', name: 'History', colorValue: 0xFFF59E0B),
        FlashcardCategory(id: 'cat_3', name: 'Programming', colorValue: 0xFF3B82F6),
      ];
      _saveCategories();
    }

    // Load Flashcards
    final cardsString = prefs.getString('flashcards_v2');
    if (cardsString != null) {
      final List<dynamic> decodedList = jsonDecode(cardsString);
      _flashcards = decodedList.map((item) => Flashcard.fromJson(item)).toList();
    } else {
      // Clear out V1 flashcards by migrating entirely to V2 clean slate
      _flashcards = [
        Flashcard(
          id: DateTime.now().millisecondsSinceEpoch.toString() + "_1",
          question: "When was Flutter officially released?",
          answer: "December 2018 (Flutter 1.0)",
          categoryId: 'cat_3',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Flashcard(
           id: DateTime.now().millisecondsSinceEpoch.toString() + "_2",
          question: "What is the powerhouse behind the cell?",
          answer: "Mitochondria",
          categoryId: 'cat_1',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        )
      ];
      _saveFlashcards();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(_categories.map((c) => c.toJson()).toList());
    await prefs.setString('flashcard_categories_v2', encodedList);
  }

  Future<void> _saveFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(_flashcards.map((f) => f.toJson()).toList());
    await prefs.setString('flashcards_v2', encodedList);
  }

  void addCategory(String name, int color) {
    final newCat = FlashcardCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      colorValue: color,
    );
    _categories.add(newCat);
    _saveCategories();
    notifyListeners();
  }

  void renameCategory(String id, String newName) {
    final index = _categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      _categories[index] = FlashcardCategory(
        id: _categories[index].id,
        name: newName,
        colorValue: _categories[index].colorValue,
      );
      _saveCategories();
      notifyListeners();
    }
  }

  void deleteCategory(String id) {
    _categories.removeWhere((cat) => cat.id == id);
    _flashcards.removeWhere((card) => card.categoryId == id);
    _saveCategories();
    _saveFlashcards();
    notifyListeners();
  }

  List<Flashcard> getCardsByCategory(String categoryId) {
    return _flashcards.where((card) => card.categoryId == categoryId).toList();
  }

  FlashcardCategory? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  void addFlashcard(String question, String answer, String categoryId, {String? imagePath}) {
    final newCard = Flashcard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      answer: answer,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );
    _flashcards.add(newCard);
    _saveFlashcards();
    notifyListeners();
  }

  void updateFlashcard(String id, String newQuestion, String newAnswer, String categoryId, {String? imagePath}) {
    final index = _flashcards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _flashcards[index].question = newQuestion;
      _flashcards[index].answer = newAnswer;
      _flashcards[index].categoryId = categoryId;
      _flashcards[index].imagePath = imagePath;
      _saveFlashcards();
      notifyListeners();
    }
  }

  void incrementMastery(String id) {
    final index = _flashcards.indexWhere((card) => card.id == id);
    if (index != -1) {
      // Increase mastery smoothly up to 100% capacity
      _flashcards[index].masteryLevel = (_flashcards[index].masteryLevel + 25).clamp(0, 100);
      _saveFlashcards();
      notifyListeners();
    }
  }

  double getCategoryMastery(String categoryId) {
    final cards = getCardsByCategory(categoryId);
    if (cards.isEmpty) return 0.0;
    int totalPoints = cards.fold(0, (sum, item) => sum + item.masteryLevel);
    int maxPoints = cards.length * 100;
    return totalPoints / maxPoints; // yield simple float ratio 0.0 -> 1.0!
  }

  void deleteFlashcard(String id) {
    _flashcards.removeWhere((card) => card.id == id);
    _saveFlashcards();
    notifyListeners();
  }
}
