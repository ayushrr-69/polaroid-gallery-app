import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/album.dart';
import '../../models/photo.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/polaroid_card.dart';
import '../photo_preview/photo_preview_screen.dart';

/// Displays the photos inside a specific album using a vertical scrolling list.
class AlbumDetailsScreen extends StatefulWidget {
  const AlbumDetailsScreen({super.key, required this.album});

  final Album album;

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  void _openPreview(Photo photo) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: PhotoPreviewScreen(
            photo: photo,
            onFavoriteToggle: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
            onDelete: () => context.read<GalleryProvider>().deletePhoto(photo.id),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<GalleryProvider>();
    // Fetch the updated album from the provider to ensure we have fresh data
    final Album currentAlbum = provider.albums.firstWhere(
      (a) => a.id == widget.album.id, 
      orElse: () => widget.album
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            pinned: true,
            expandedHeight: 280,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: Text(
                currentAlbum.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      color: Colors.black54,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (currentAlbum.photos.isNotEmpty)
                    currentAlbum.displayCover.startsWith('http')
                        ? Image.network(
                            currentAlbum.displayCover,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(currentAlbum.displayCover),
                            fit: BoxFit.cover,
                          )
                  else
                    Container(color: cs.surfaceContainer),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black87],
                        stops: [0.0, 0.5, 1.0],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          if (currentAlbum.photos.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No photos in this album',
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverList.separated(
                itemCount: currentAlbum.photos.length,
                separatorBuilder: (context, _) => const SizedBox(height: 48),
                itemBuilder: (context, index) {
                  final photo = currentAlbum.photos[index];
                  return PolaroidCard(
                    photo: photo,
                    onTap: () => _openPreview(photo),
                    onDoubleTap: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                    onFavorite: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}
