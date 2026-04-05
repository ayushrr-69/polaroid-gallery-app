import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/photo.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/polaroid_card.dart';
import '../../widgets/polaroid_skeleton.dart';
import '../photo_preview/photo_preview_screen.dart';
import '../edit_metadata/edit_metadata_screen.dart';

/// Main gallery screen — vertical page scroller of true Polaroid cards.
/// Uses [Theme.of(context).colorScheme] for dynamic theming of the shell.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
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

  void _showPhotoOptions(Photo photo) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  photo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Divider(
                color: cs.outlineVariant,
                height: 1,
                indent: 20,
                endIndent: 20,
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: cs.onSurfaceVariant),
                title: Text('Edit Metadata',
                    style: TextStyle(color: cs.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditMetadataScreen(
                        initialTitle: photo.title,
                        initialLocation: photo.location ?? '',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  photo.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: photo.isFavorite ? cs.primary : cs.onSurfaceVariant,
                ),
                title: Text(
                  photo.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  style: TextStyle(color: cs.onSurface),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<GalleryProvider>().toggleFavorite(photo.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: cs.error),
                title: Text('Delete Photo',
                    style: TextStyle(color: cs.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<GalleryProvider>().deletePhoto(photo.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<GalleryProvider>();
    final photos = provider.photos;
    final isLoading = provider.isLoading;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital Archive.01',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Curated moments, preserved forever',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (isLoading)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList.separated(
              itemCount: 3, // show a few skeletons
              separatorBuilder: (context, _) => const SizedBox(height: 48),
              itemBuilder: (context, index) => const PolaroidSkeleton(),
            ),
          )
        else if (photos.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // A more stylized empty state icon
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.collections_outlined,
                        size: 64,
                        color: cs.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Your archive is empty.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'The "Digital Archive" preserves your professional moments. Tap Curator to start your collection.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            sliver: SliverList.separated(
              itemCount: photos.length,
              separatorBuilder: (context, _) => const SizedBox(height: 48),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return PolaroidCard(
                  photo: photo,
                  onTap: () => _openPreview(photo),
                  onDoubleTap: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                  onFavorite: () => context.read<GalleryProvider>().toggleFavorite(photo.id),
                  onLongPress: () => _showPhotoOptions(photo),
                );
              },
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
