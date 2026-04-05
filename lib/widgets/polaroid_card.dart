import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo.dart';

/// A true Polaroid-style photo card with a white border, chin, and caption.
/// Includes a tilt/press animation when tapped, and heart break/pop animations.
class PolaroidCard extends StatefulWidget {
  const PolaroidCard({
    super.key,
    required this.photo,
    this.onTap,
    this.onFavorite,
    this.onDoubleTap,
    this.onLongPress,
  });

  final Photo photo;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  @override
  State<PolaroidCard> createState() => _PolaroidCardState();
}

class _PolaroidCardState extends State<PolaroidCard>
    with TickerProviderStateMixin {
  late final AnimationController _heartController;
  late final AnimationController _pressController;
  bool _showHeart = false;
  bool _isBreaking = false;

  @override
  void initState() {
    super.initState();
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

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final wasFavorite = widget.photo.isFavorite;
    HapticFeedback.mediumImpact(); // Added haptics
    widget.onDoubleTap?.call();
    setState(() {
      _showHeart = true;
      _isBreaking = wasFavorite;
    });
    _heartController.forward(from: 0.0);
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onDoubleTap: _handleDoubleTap,
      onLongPress: widget.onLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          // Tilt and scale down slightly when pressed
          final scale = 1.0 - (_pressController.value * 0.02);
          final rotate = _pressController.value * -0.015; // rotate slightly left

          return Transform.rotate(
            angle: rotate,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Container(
          // True polaroid look: white/off-white background
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 12),
                blurRadius: 24,
                color: Color.fromRGBO(0, 0, 0, 0.25),
              ),
              BoxShadow(
                offset: Offset(0, 4),
                blurRadius: 8,
                color: Color.fromRGBO(0, 0, 0, 0.15),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // large chin at bottom
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image Area ──────────────────────────
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: widget.photo.aspectRatio.clamp(0.6, 1.6),
                    child: Hero(
                      tag: 'photo_${widget.photo.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: widget.photo.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: widget.photo.imageUrl,
                                fit: BoxFit.cover,
                                fadeInDuration: const Duration(milliseconds: 500),
                                placeholder: (_, _) => Container(
                                  color: cs.surfaceContainerHighest.withValues(alpha: 0.1),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: cs.primary.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: cs.errorContainer.withValues(alpha: 0.2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: cs.error.withValues(alpha: 0.5),
                                        size: 32,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: cs.error.withValues(alpha: 0.6),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : widget.photo.imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    widget.photo.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : Image.file(
                                    File(widget.photo.imageUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  if (_showHeart)
                    Positioned.fill(
                      child: Center(
                        child: _isBreaking
                            ? _buildBrokenHeart(cs)
                            : _buildPoppingHeart(cs),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),

              // ── Chin / Caption Area ──────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.photo.caption != null && widget.photo.caption!.isNotEmpty) ...[
                          Text(
                            widget.photo.caption!,
                            style: const TextStyle(
                              fontFamily: 'Caveat', // A handwriting style font if available, or just a stylized text
                              fontStyle: FontStyle.italic,
                              fontSize: 18,
                              color: Color(0xFF2A2A2A),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          widget.photo.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: Color(0xFF6B6B6B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.onFavorite != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact(); // Added haptics
                        widget.onFavorite?.call();
                      },
                      icon: Icon(
                        widget.photo.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.photo.isFavorite
                            ? cs.primary
                            : const Color(0xFFC4C4C4),
                        size: 24,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
          size: 72,
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
        final yOffset = fallAnimation.value * 100.0;
        final xOffset = fallAnimation.value * 30.0;
        final rotation = fallAnimation.value * 0.5;
        final opacity = 1.0 - fallAnimation.value;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
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
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ),
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
                          size: 80,
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
