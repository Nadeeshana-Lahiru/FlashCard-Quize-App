import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/flashcard.dart';

class CsvService {
  /// Parses an imported CSV file and returns a list of [question, answer] pairs.
  /// Expects Column A = Question, Column B = Answer.
  static Future<List<List<String>>?> importFromCsv() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true, // Required for web support
      );

      if (result == null || result.files.isEmpty) return null;

      String csvContent;

      if (kIsWeb) {
        final bytes = result.files.first.bytes;
        if (bytes == null) return null;
        csvContent = utf8.decode(bytes);
      } else {
        final path = result.files.first.path;
        if (path == null) return null;
        csvContent = await File(path).readAsString();
      }

      // csv v8: use top-level csv.decode()
      final rows = csv.decode(csvContent);

      // Filter out header row and empty/invalid rows
      final validRows = rows
          .where((row) =>
              row.length >= 2 &&
              row[0].toString().toLowerCase() != 'question' &&
              row[0].toString().trim().isNotEmpty)
          .map((row) => [row[0].toString().trim(), row[1].toString().trim()])
          .toList();

      return validRows;
    } catch (e) {
      return null;
    }
  }

  /// Exports a list of flashcards as a CSV string and shares it via the native OS.
  static Future<void> exportAndShareDeck(
      List<Flashcard> cards, String deckName) async {
    // Build 2D list with header row
    final List<List<String>> rows = [
      ['Question', 'Answer'],
      ...cards.map((c) => [c.question, c.answer]),
    ];

    // csv v8: use top-level csv.encode()
    final csvString = csv.encode(rows);
    final fileName = '${deckName.replaceAll(' ', '_')}_deck.csv';

    if (kIsWeb) {
      // Web: share as plain text since file paths don't exist
      await SharePlus.instance.share(
        ShareParams(
          text: csvString,
          subject: '$deckName Flashcard Deck',
        ),
      );
    } else {
      // Mobile/Desktop: write to temp dir, share as an attachment
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: '$deckName Flashcard Deck',
          text: 'Here is my "$deckName" flashcard deck! Import it in the Flashcards app.',
        ),
      );
    }
  }
}
