import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/photo.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/gradient_button.dart';

/// Screen for curating / uploading a new image.
class CurateScreen extends StatefulWidget {
  const CurateScreen({super.key});

  @override
  State<CurateScreen> createState() => _CurateScreenState();
}

class _CurateScreenState extends State<CurateScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedImagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImagePath = file.path;
      });
    }
  }

  void _addPhotoToGallery() {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an image first.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please provide a title.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final newPhoto = Photo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      imageUrl: _selectedImagePath!,
      date: DateTime.now(),
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      caption: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
    );

    context.read<GalleryProvider>().addPhoto(newPhoto);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: Text(
          'Curate New Image',
          style: tt.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // ── Image Preview Area ──────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.15),
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: _selectedImagePath != null
                    ? Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to select an image',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG, HEIC supported',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Title Field ─────────────────────────────────
            _buildLabel(context, 'TITLE', cs, tt),
            const SizedBox(height: 8),
            _buildTextField(context, _titleController, 'e.g. The Crossing', cs, tt),

            const SizedBox(height: 24),

            // ── Location Field ──────────────────────────────
            _buildLabel(context, 'LOCATION', cs, tt),
            const SizedBox(height: 8),
            _buildTextField(
              context,
              _locationController,
              'e.g. Tokyo, Japan',
              cs,
              tt,
              prefixIcon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 24),

            // ── Caption Field ───────────────────────────
            _buildLabel(context, 'CAPTION', cs, tt),
            const SizedBox(height: 8),
            _buildTextField(
              context,
              _descriptionController,
              'Write a caption for this moment...',
              cs,
              tt,
              maxLines: 4,
            ),

            const SizedBox(height: 40),

            // ── CTA ─────────────────────────────────────────
            Center(
              child: GradientButton(
                label: 'Add to Collection',
                icon: Icons.add_rounded,
                onPressed: _addPhotoToGallery,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
      BuildContext context, String text, ColorScheme cs, TextTheme tt) {
    return Text(
      text,
      style: tt.labelSmall?.copyWith(
        color: cs.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String hint,
    ColorScheme cs,
    TextTheme tt, {
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: tt.bodyLarge?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: tt.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: cs.onSurfaceVariant, size: 20)
            : null,
      ),
    );
  }
}
