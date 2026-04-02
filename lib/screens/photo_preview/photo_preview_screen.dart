import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/photo.dart';
import '../../widgets/circular_button.dart';

/// Fullscreen photo preview with Hero animation, frosted overlay metadata,
/// action buttons, and a double-tap to like/unlike animation (pop or break).
class PhotoPreviewScreen extends StatefulWidget {
  const PhotoPreviewScreen({
    super.key,
    required this.photo,
    this.onFavoriteToggle,
    this.onDelete,
  });

  final Photo photo;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen>
    with TickerProviderStateMixin {
  bool _showInfo = false;

  late final AnimationController _heartController;
  bool _showHeart = false;
  bool _isBreaking = false;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.photo.isFavorite;
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showHeart = false;
          _isBreaking = false;
        });
        _heartController.reset();
      }
    });
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _handleFavoriteToggle() {
    if (widget.onFavoriteToggle == null) return;
    
    final wasFavorite = _isFavorite;
    widget.onFavoriteToggle!();

    setState(() {
      _isFavorite = !wasFavorite;
      _showHeart = true;
      _isBreaking = wasFavorite; // If it was already a favorite, we are unliking it
    });
    
    _heartController.forward(from: 0.0);
  }

  void _handleTopBarFavorite() {
    if (widget.onFavoriteToggle == null) return;
    widget.onFavoriteToggle!();
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _handleDelete() {
    if (widget.onDelete != null) {
      widget.onDelete!();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: GestureDetector(
        onTap: () => setState(() => _showInfo = !_showInfo),
        onDoubleTap: _handleFavoriteToggle,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Hero(
                tag: 'photo_${widget.photo.id}',
                child: widget.photo.imageUrl.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: widget.photo.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        errorWidget: (_, _, _) => Icon(
                          Icons.broken_image_rounded,
                          color: cs.onSurfaceVariant,
                          size: 48,
                        ),
                      )
                    : Image.file(
                        File(widget.photo.imageUrl),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.broken_image_rounded,
                          color: cs.onSurfaceVariant,
                          size: 48,
                        ),
                      ),
              ),
            ),
            
            // ── Heart Animation Overlay ───────────────────────────
            if (_showHeart)
              Positioned.fill(
                child: Center(
                  child: _isBreaking
                      ? _buildBrokenHeart(cs)
                      : _buildPoppingHeart(cs),
                ),
              ),

            // ── Top bar ───────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: cs.surfaceContainerLowest.withValues(alpha: 0.6),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: cs.onSurface,
                              ),
                            ),
                            const Spacer(),
                            if (widget.onDelete != null) ...[
                              CircularButton(
                                icon: Icons.delete_outline_rounded,
                                iconColor: cs.error,
                                onPressed: _handleDelete,
                                size: CircularButtonSize.small,
                              ),
                              const SizedBox(width: 8),
                            ],
                            CircularButton(
                              icon: _isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              iconColor: _isFavorite
                                  ? cs.primary
                                  : cs.onSurface,
                              onPressed: _handleTopBarFavorite,
                              size: CircularButtonSize.small,
                            ),
                            const SizedBox(width: 8),
                            CircularButton(
                              icon: Icons.share_outlined,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Sharing photo...'),
                                    backgroundColor: cs.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              size: CircularButtonSize.small,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom info panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: _showInfo ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: cs.surface.withValues(alpha: 0.8),
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.photo.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.photo.location != null)
                            _infoRow(context, Icons.location_on_outlined,
                                widget.photo.location!),
                          if (widget.photo.shutterSpeed != null)
                            _infoRow(context, Icons.camera_outlined,
                                widget.photo.shutterSpeed!),
                          _infoRow(
                            context,
                            Icons.calendar_today_outlined,
                            _formatDate(widget.photo.date),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoppingHeart(ColorScheme cs) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _heartController,
        curve: Curves.elasticOut,
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
          parent: _heartController,
          curve: const Interval(0.5, 1.0),
        )),
        child: Icon(
          Icons.favorite_rounded,
          color: cs.primary.withValues(alpha: 0.9),
          size: 100,
        ),
      ),
    );
  }

  Widget _buildBrokenHeart(ColorScheme cs) {
    final fallAnimation = CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeIn,
    );

    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, child) {
        // Fall down and spread apart
        final yOffset = fallAnimation.value * 150.0;
        final xOffset = fallAnimation.value * 50.0;
        final rotation = fallAnimation.value * 0.5;
        final opacity = 1.0 - fallAnimation.value;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                // Left half (clipped)
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(-xOffset, yOffset),
                    child: Transform.rotate(
                      angle: -rotation,
                      child: ClipRect(
                        clipper: _HalfClipper(isLeft: true),
                        child: Icon(
                          Icons.heart_broken_rounded,
                          color: cs.primary.withValues(alpha: 0.9),
                          size: 120,
                        ),
                      ),
                    ),
                  ),
                ),
                // Right half (clipped)
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(xOffset, yOffset),
                    child: Transform.rotate(
                      angle: rotation,
                      child: ClipRect(
                        clipper: _HalfClipper(isLeft: false),
                        child: Icon(
                          Icons.heart_broken_rounded,
                          color: cs.primary.withValues(alpha: 0.9),
                          size: 120,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool isLeft;
  _HalfClipper({required this.isLeft});

  @override
  Rect getClip(Size size) {
    if (isLeft) {
      return Rect.fromLTRB(0, 0, size.width / 2, size.height);
    } else {
      return Rect.fromLTRB(size.width / 2, 0, size.width, size.height);
    }
  }

  @override
  bool shouldReclip(_HalfClipper oldClipper) => isLeft != oldClipper.isLeft;
}
