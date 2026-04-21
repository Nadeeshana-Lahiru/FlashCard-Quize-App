import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class ImageStorageService {
  static Future<String?> saveImageToAppDirectory(String sourcePath) async {
    if (kIsWeb) {
      // In Flutter Web, the path is actually a Blob URL.
      // We can't use dart:io File copy here.
      return sourcePath;
    }

    try {
      final sourceFile = File(sourcePath);
      final directory = await getApplicationDocumentsDirectory();
      
      final uri = Uri.file(sourcePath);
      final rawFileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'image.png';
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$rawFileName';
      
      final targetDir = Directory('${directory.path}/flashcard_images');
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      
      final targetPath = '${targetDir.path}/$fileName';
      final savedFile = await sourceFile.copy(targetPath);
      return savedFile.path;
    } catch (e) {
      debugPrint("Error saving image: $e");
      return null;
    }
  }

  static Future<void> deleteImage(String path) async {
    if (kIsWeb) return; // Blob URLs are cleared automatically on Web

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Error deleting image: $e");
    }
  }
}
