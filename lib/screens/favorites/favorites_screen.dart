import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/photo.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/polaroid_card.dart';
import '../photo_preview/photo_preview_screen.dart';

/// Shows only favorited photos in a masonry grid.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final photos = context.watch<GalleryProvider>().photos;
    final favorites = photos.where((p) => p.isFavorite).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorites',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your handpicked collection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (favorites.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 56,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Double-tap any photo to add it here',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList.separated(
              itemCount: favorites.length,
              separatorBuilder: (context, _) => const SizedBox(height: 48),
              itemBuilder: (context, index) {
                final photo = favorites[index];
                return PolaroidCard(
                  photo: photo,
                  onTap: () => _openPreview(photo),
                  onDoubleTap: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                  onFavorite: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                );
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
