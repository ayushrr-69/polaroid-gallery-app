import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/album.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/gradient_button.dart';

/// Screen for creating a new album — album name input + photo selector grid.
/// Fully supports dynamic theming.
class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  State<CreateAlbumScreen> createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedPhotoIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _togglePhoto(String id) {
    setState(() {
      if (_selectedPhotoIds.contains(id)) {
        _selectedPhotoIds.remove(id);
      } else {
        _selectedPhotoIds.add(id);
      }
    });
  }

  void _createAlbum() {
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an album name.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final provider = context.read<GalleryProvider>();
    final selectedPhotos = provider.photos.where((p) => _selectedPhotoIds.contains(p.id)).toList();

    final newAlbum = Album(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      photos: selectedPhotos,
    );

    provider.addAlbum(newAlbum);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final photos = context.watch<GalleryProvider>().photos;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        title: Text(
          'Create New Album',
          style: tt.titleLarge?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Album Name ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ALBUM NAME',
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'e.g. Summer Memories',
                    hintStyle: tt.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Section Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Photos',
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_selectedPhotoIds.length} selected',
                  style: tt.labelMedium?.copyWith(
                    color: cs.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Photo Selector Grid ─────────────────────────────
          Expanded(
            child: photos.isEmpty
              ? Center(
                  child: Text(
                    'No photos available to select.\nUpload photos from the gallery first.',
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                )
              : GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                final isSelected = _selectedPhotoIds.contains(photo.id);

                return GestureDetector(
                  onTap: () => _togglePhoto(photo.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: cs.primary, width: 2.5)
                          : Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.15),
                            ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        isSelected ? 13.5 : 15,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          photo.imageUrl.startsWith('http')
                              ? Image.network(photo.imageUrl, fit: BoxFit.cover)
                              : Image.file(File(photo.imageUrl), fit: BoxFit.cover),
                          if (isSelected)
                            Container(
                              color: cs.primary.withValues(alpha: 0.2),
                              child: Center(
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: cs.primary,
                                  size: 28,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── CTA ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Center(
              child: GradientButton(
                label: 'Create Album',
                icon: Icons.create_new_folder_outlined,
                onPressed: _selectedPhotoIds.isEmpty
                    ? null
                    : _createAlbum,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
