import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/photo.dart';
import '../../state/gallery_provider.dart';
import '../../services/cloudinary_service.dart';
import '../../services/auth_service.dart';
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
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final path = await CloudinaryService.pickImage();
    if (path != null) {
      setState(() => _selectedImagePath = path);
    }
  }

  void _showQualityPickerAndUpload() {
    if (_selectedImagePath == null) {
      _showSnackBar('Please select an image first.', isError: true);
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('Please provide a title.', isError: true);
      return;
    }

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upload Quality',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose the quality for your upload',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // High Quality option
            _QualityOption(
              icon: Icons.high_quality_rounded,
              title: 'High Quality',
              subtitle: 'Best visual clarity • ~1–2 MB',
              accentColor: cs.primary,
              onTap: () {
                Navigator.pop(ctx);
                _uploadPhoto(highQuality: true);
              },
            ),
            const SizedBox(height: 12),

            // Optimized option
            _QualityOption(
              icon: Icons.compress_rounded,
              title: 'Optimized',
              subtitle: 'Fast upload • <1 MB • Max 1080px',
              accentColor: cs.secondary,
              onTap: () {
                Navigator.pop(ctx);
                _uploadPhoto(highQuality: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto({required bool highQuality}) async {
    if (_selectedImagePath == null) return;

    setState(() => _isUploading = true);

    try {
      // 1. Compress and upload to Cloudinary
      final cloudUrl = await CloudinaryService.compressAndUpload(
        _selectedImagePath!,
        highQuality: highQuality,
      );

      if (cloudUrl == null) {
        _showSnackBar('Upload failed. Please try again.', isError: true);
        setState(() => _isUploading = false);
        return;
      }

      // 2. Create Photo object
      final title = _titleController.text.trim();
      final photoId = DateTime.now().millisecondsSinceEpoch.toString();

      final newPhoto = Photo(
        id: photoId,
        title: title,
        imageUrl: cloudUrl,
        date: DateTime.now(),
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        caption: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      );

      // 3. Save to Firestore if signed in
      final user = AuthService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('photos')
            .doc(photoId)
            .set({
          'imageUrl': cloudUrl,
          'title': title,
          'caption': newPhoto.caption,
          'location': newPhoto.location,
          'userId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'isFavorite': false,
          'aspectRatio': 1.0,
        });
      }

      // 4. Add to local gallery
      if (mounted) {
        context.read<GalleryProvider>().addPhoto(newPhoto);
        _showSnackBar('Photo uploaded successfully! ✨');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      _showSnackBar('Upload failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
      ),
    );
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // ── Image Preview Area ──────────────────────────
                GestureDetector(
                  onTap: _isUploading ? null : _pickImage,
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
                    label: _isUploading ? 'Uploading...' : 'Add to Collection',
                    icon: _isUploading ? Icons.cloud_upload_rounded : Icons.add_rounded,
                    onPressed: _isUploading ? null : _showQualityPickerAndUpload,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // ── Upload Overlay ────────────────────────────────────
          if (_isUploading)
            Container(
              color: cs.surface.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(cs.primary),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Uploading your image...',
                      style: tt.titleSmall?.copyWith(color: cs.onSurface),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compressing and uploading to cloud',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
        ],
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

/// A quality option card used in the bottom sheet.
class _QualityOption extends StatelessWidget {
  const _QualityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
