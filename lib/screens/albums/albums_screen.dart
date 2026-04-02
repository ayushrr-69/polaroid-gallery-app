import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/gallery_provider.dart';
import '../../widgets/album_card.dart';
import '../album_details/album_details_screen.dart';

/// Albums screen with a vertical list of AlbumCards.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({super.key});

  @override
  State<AlbumsScreen> createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final albums = context.watch<GalleryProvider>().albums;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Albums',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your curated collections',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (albums.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.collections_bookmark_rounded,
                    size: 56,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No albums yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap the + button to create an album',
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailsScreen(album: albums[index]),
                          ),
                        ).then((_) {
                          // Force rebuild of albums screen if photos were deleted
                          setState((){});
                        });
                      },
                      child: AlbumCard(album: albums[index]),
                    ),
                  );
                },
                childCount: albums.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
