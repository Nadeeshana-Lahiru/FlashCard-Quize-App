import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/flashcard.dart';
import '../providers/flashcard_provider.dart';
import '../services/image_storage_service.dart';

class AddEditCardScreen extends StatefulWidget {
  final String categoryId;
  final Flashcard? flashcard;

  const AddEditCardScreen({Key? key, required this.categoryId, this.flashcard}) : super(key: key);

  @override
  State<AddEditCardScreen> createState() => _AddEditCardScreenState();
}

class _AddEditCardScreenState extends State<AddEditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController = TextEditingController(text: widget.flashcard?.answer ?? '');
    _imagePath = widget.flashcard?.imagePath;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(widget.flashcard == null ? "Confirm Save" : "Confirm Changes"),
            content: Text(
              widget.flashcard == null
                  ? "Are you sure you want to add this flashcard?"
                  : "Are you sure you want to save these changes?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No, Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes, Save", style: TextStyle(color: Colors.blue)),
              ),
            ],
          );
        },
      );

      if (shouldSave == true) {
        if (!mounted) return;
        
        setState(() => _isSaving = true);
        
        String? finalImagePath = _imagePath;
        
        // If image is new (not the same as existing saved image), copy to storage
        if (_imagePath != null && _imagePath != widget.flashcard?.imagePath) {
          finalImagePath = await ImageStorageService.saveImageToAppDirectory(_imagePath!);
        }

        if (!mounted) return;
        final provider = Provider.of<FlashcardProvider>(context, listen: false);

        if (widget.flashcard == null) {
          provider.addFlashcard(
            _questionController.text.trim(),
            _answerController.text.trim(),
            widget.categoryId,
            imagePath: finalImagePath,
          );
        } else {
          provider.updateFlashcard(
            widget.flashcard!.id,
            _questionController.text.trim(),
            _answerController.text.trim(),
            widget.categoryId,
            imagePath: finalImagePath,
          );
        }
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.flashcard != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputFillColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Card' : 'Create Card'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Visual Media (Optional)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_imagePath != null) ...[
                  Center(
                    child: Stack(
                      alignment: Alignment.topRight,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(50), width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: kIsWeb
                                ? Image.network(
                                    _imagePath!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  )
                                : Image.file(
                                    File(_imagePath!),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(12, -12),
                          child: CircleAvatar(
                            backgroundColor: Colors.redAccent,
                            radius: 16,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, color: Colors.white, size: 18),
                              onPressed: () => setState(() => _imagePath = null),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_imagePath != null ? "Retake" : "Camera", style: const TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: Text(_imagePath != null ? "Change" : "Gallery", style: const TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  "Question",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Enter the question here...",
                    filled: true,
                    fillColor: inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                const Text(
                  "Answer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _answerController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter the answer here...",
                    filled: true,
                    fillColor: inputFillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveForm,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEditMode ? 'Save Changes' : 'Create Flashcard',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
