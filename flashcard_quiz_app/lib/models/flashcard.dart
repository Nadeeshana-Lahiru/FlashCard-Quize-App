class Flashcard {
  final String id;
  String question;
  String answer;
  String categoryId;
  DateTime createdAt;
  String? imagePath;
  int masteryLevel;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.categoryId,
    required this.createdAt,
    this.imagePath,
    this.masteryLevel = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'masteryLevel': masteryLevel,
      if (imagePath != null) 'imagePath': imagePath,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      categoryId: json['categoryId'] as String? ?? 'default',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(), // Fallback for any deprecated cards
      imagePath: json['imagePath'] as String?,
      masteryLevel: json['masteryLevel'] as int? ?? 0,
    );
  }
}
