class FlashcardCategory {
  final String id;
  String name;
  int colorValue;

  FlashcardCategory({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
    };
  }

  factory FlashcardCategory.fromJson(Map<String, dynamic> json) {
    return FlashcardCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int? ?? 0xFF2563EB,
    );
  }
}
