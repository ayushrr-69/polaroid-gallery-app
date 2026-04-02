import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/album.dart';

/// Album card displaying cover image, title, and photo count.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
  });

  final Album album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 16),
              blurRadius: 40,
              color: Color.fromRGBO(0, 0, 0, 0.3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              album.displayCover.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: album.displayCover,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: cs.surfaceContainer,
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: cs.surfaceContainer,
                        child: Icon(
                          Icons.photo_album_rounded,
                          color: cs.onSurfaceVariant,
                          size: 40,
                        ),
                      ),
                    )
                  : Image.file(
                      File(album.displayCover),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: cs.surfaceContainer,
                        child: Icon(
                          Icons.photo_album_rounded,
                          color: cs.onSurfaceVariant,
                          size: 40,
                        ),
                      ),
                    ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
              // Title + count
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      album.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${album.photoCount} PHOTOS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
