import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiGraderService {
  static const String _apiKey = 'enter your key';
  static const String _model = 'gemini-2.0-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  /// Grades a student's answer semantically using Gemini AI.
  static Future<GradingResult> gradeAnswer({
    required String question,
    required String correctAnswer,
    required String studentAnswer,
  }) async {
    final prompt = '''
You are a helpful and encouraging academic tutor grading a student's flashcard answer.

Question: "$question"
Correct Answer: "$correctAnswer"
Student's Answer: "$studentAnswer"

Grading Rules:
- IGNORE capitalization differences completely (e.g., "ice cream" = "Ice-Cream" = "ICE CREAM")
- IGNORE hyphen vs space differences (e.g., "ice cream" = "ice-cream")
- IGNORE minor spelling variations or extra/missing articles (a, the, an)
- Focus on whether the MEANING and KEY CONCEPTS are captured
- Score 90-100: Essentially same meaning, correct concept
- Score 70-89: Mostly correct, minor wording gap
- Score 40-69: Contains some correct ideas but misses important parts
- Score 0-39: Significantly wrong or totally off-topic

Write 2-3 sentences of educational feedback:
1. Tell them SPECIFICALLY what they got right
2. If wrong or partial, explain WHY the correct answer is "$correctAnswer" in simple terms
3. Give a helpful memory tip or context clue to remember it better

Respond ONLY with valid JSON, no markdown:
{"score": <integer 0-100>, "feedback": "<2-3 educational sentences>"}
''';

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 250,
          }
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Strip markdown code fences if Gemini wraps response
        final cleaned = rawText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final parsed = jsonDecode(cleaned);

        return GradingResult(
          score: (parsed['score'] as num).toInt().clamp(0, 100),
          feedback: parsed['feedback'] as String,
          isAiGraded: true,
        );
      } else {
        // API error - use smart local fallback
        return _smartLocalFallback(correctAnswer, studentAnswer, question);
      }
    } catch (e) {
      // Network/timeout error - use smart local fallback
      return _smartLocalFallback(correctAnswer, studentAnswer, question);
    }
  }

  /// Smart local fallback with punctuation/case normalization
  static GradingResult _smartLocalFallback(
      String correct, String student, String question) {
    // Normalize: lowercase + remove hyphens, dashes, extra spaces, punctuation
    String normalize(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[-–—]'), ' ')   // hyphens → space
        .replaceAll(RegExp(r'[^\w\s]'), '')  // remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ')     // collapse spaces
        .trim();

    final c = normalize(correct);
    final s = normalize(student);

    // Remove articles for loose comparison
    String removeArticles(String text) =>
        text.replaceAll(RegExp(r'\b(a|an|the)\b'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

    final cClean = removeArticles(c);
    final sClean = removeArticles(s);

    if (c == s || cClean == sClean) {
      return GradingResult(
        score: 97,
        feedback:
            'Perfect answer! "$correct" is exactly right. Great memory recall!',
        isAiGraded: false,
      );
    }

    // Check if one contains the other after normalization
    if (c.contains(s) || s.contains(c)) {
      return GradingResult(
        score: 80,
        feedback:
            'Very close! Your answer captures the right idea. The complete answer is "$correct" — remember the exact phrasing for full marks.',
        isAiGraded: false,
      );
    }

    // Word overlap scoring
    final correctWords = c.split(' ').toSet();
    final studentWords = s.split(' ').toSet();
    final overlap = correctWords.intersection(studentWords).length;
    final overlapRatio = overlap / correctWords.length;

    if (overlapRatio >= 0.7) {
      return GradingResult(
        score: 72,
        feedback:
            'Good effort! You got most of the key words. The correct answer is "$correct". Review for any missing details.',
        isAiGraded: false,
      );
    } else if (overlapRatio >= 0.4) {
      return GradingResult(
        score: 50,
        feedback:
            'Partially correct — you had some right ideas. The full answer is "$correct". Try to recall all parts next time.',
        isAiGraded: false,
      );
    } else {
      return GradingResult(
        score: 15,
        feedback:
            'The correct answer is "$correct". Review this topic and focus on understanding why this answer is correct, then try again.',
        isAiGraded: false,
      );
    }
  }
}

class GradingResult {
  final int score;
  final String feedback;
  final bool isAiGraded;

  const GradingResult({
    required this.score,
    required this.feedback,
    required this.isAiGraded,
  });

  bool get isPassing => score >= 70;
}
