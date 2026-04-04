import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/photo.dart';
import '../../widgets/circular_button.dart';
import '../../services/share_image_service.dart';

/// Fullscreen photo preview with V4 Background Selector and alignment refinements.
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
  bool _isSharing = false;

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
      _isBreaking = wasFavorite;
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

  /// V4: Step 1 - Choose Format
  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      // Removed isScrollControlled as this sheet is small and fixed-height
      builder: (ctx) => _ShareFormatBottomSheet(
        photo: widget.photo,
        onSelected: (isStory) {
          Navigator.pop(ctx);
          if (isStory) {
            _showStoryBackgroundOptions();
          } else {
            _executeShare(isStory: false);
          }
        },
      ),
    );
  }

  /// V4: Step 2 - Choose Background (for Stories)
  void _showStoryBackgroundOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true, // Better handling for modern screens
      builder: (ctx) => _StoryBackgroundBottomSheet(
        photo: widget.photo,
        onShared: (type, color, gradient) {
          Navigator.pop(ctx);
          _executeShare(
            isStory: true,
            backgroundType: type,
            backgroundColor: color,
            backgroundGradient: gradient,
          );
        },
      ),
    );
  }

  Future<void> _executeShare({
    required bool isStory,
    ShareBackgroundType backgroundType = ShareBackgroundType.blur,
    Color? backgroundColor,
    Gradient? backgroundGradient,
  }) async {
    if (mounted) setState(() => _isSharing = true);
    try {
      await ShareImageService.sharePhoto(
        context, 
        widget.photo, 
        isStory: isStory,
        backgroundType: backgroundType,
        backgroundColor: backgroundColor,
        backgroundGradient: backgroundGradient,
      );
    } catch (e) {
      debugPrint('Share failed: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
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
                    : widget.photo.imageUrl.startsWith('assets/')
                        ? Image.asset(
                            widget.photo.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
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
            
            if (_showHeart)
              Positioned.fill(
                child: Center(
                  child: _isBreaking
                      ? _buildBrokenHeart(cs)
                      : _buildPoppingHeart(cs),
                ),
              ),

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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
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
                              iconColor: _isFavorite ? cs.primary : cs.onSurface,
                              onPressed: _handleTopBarFavorite,
                              size: CircularButtonSize.small,
                            ),
                            const SizedBox(width: 8),
                            CircularButton(
                              icon: Icons.share_outlined,
                              isLoading: _isSharing,
                              onPressed: _showShareOptions,
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
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.photo.location != null)
                            _infoRow(context, Icons.location_on_outlined, widget.photo.location!),
                          if (widget.photo.shutterSpeed != null)
                            _infoRow(context, Icons.camera_outlined, widget.photo.shutterSpeed!),
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

            if (_isSharing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 24),
                        Text(
                          'PREPARING SHOT...',
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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
      scale: CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(CurvedAnimation(
          parent: _heartController,
          curve: const Interval(0.5, 1.0),
        )),
        child: Icon(Icons.favorite_rounded, color: cs.primary.withValues(alpha: 0.9), size: 100),
      ),
    );
  }

  Widget _buildBrokenHeart(ColorScheme cs) {
    final fallAnimation = CurvedAnimation(parent: _heartController, curve: Curves.easeIn);
    return AnimatedBuilder(
      animation: _heartController,
      builder: (context, child) {
        final yOffset = fallAnimation.value * 150.0;
        final xOffset = fallAnimation.value * 50.0;
        final rotation = fallAnimation.value * 0.5;
        final opacity = 1.0 - fallAnimation.value;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: SizedBox(
            width: 120, height: 120,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(-xOffset, yOffset),
                    child: Transform.rotate(
                      angle: -rotation,
                      child: ClipRect(
                        clipper: _HalfClipper(isLeft: true),
                        child: Icon(Icons.heart_broken_rounded, color: cs.primary.withValues(alpha: 0.9), size: 120),
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
                        child: Icon(Icons.heart_broken_rounded, color: cs.primary.withValues(alpha: 0.9), size: 120),
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
          Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _HalfClipper extends CustomClipper<Rect> {
  final bool isLeft;
  _HalfClipper({required this.isLeft});
  @override
  Rect getClip(Size size) => isLeft ? Rect.fromLTRB(0, 0, size.width/2, size.height) : Rect.fromLTRB(size.width/2, 0, size.width, size.height);
  @override
  bool shouldReclip(_HalfClipper oldClipper) => isLeft != oldClipper.isLeft;
}

// ── V4 BOTTOM SHEETS ───────────────────────────

class _ShareFormatBottomSheet extends StatelessWidget {
  final Photo photo;
  final Function(bool isStory) onSelected;

  const _ShareFormatBottomSheet({required this.photo, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.onSurfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('Select Format', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _FormatCard(
                  icon: Icons.amp_stories_rounded,
                  title: 'Story',
                  subtitle: '9:16 Vertical',
                  onTap: () => onSelected(true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FormatCard(
                  icon: Icons.grid_on_rounded,
                  title: 'Post',
                  subtitle: '1:1 Square',
                  onTap: () => onSelected(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FormatCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: cs.outlineVariant), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 32, color: cs.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StoryBackgroundBottomSheet extends StatefulWidget {
  final Photo photo;
  final Function(ShareBackgroundType type, Color? color, Gradient? gradient) onShared;

  const _StoryBackgroundBottomSheet({required this.photo, required this.onShared});

  @override
  State<_StoryBackgroundBottomSheet> createState() => _StoryBackgroundBottomSheetState();
}

class _StoryBackgroundBottomSheetState extends State<_StoryBackgroundBottomSheet> {
  ShareBackgroundType _selectedType = ShareBackgroundType.blur;
  Color? _selectedColor;
  List<Color> _extractedColors = [];
  bool _isExtracting = true;

  @override
  void initState() {
    super.initState();
    _extractColors();
  }



  Future<void> _extractColors() async {
    // Small delay to ensure the BottomSheet animation is not interrupted by heavy processing
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final ImageProvider provider = widget.photo.imageUrl.startsWith('http')
        ? CachedNetworkImageProvider(widget.photo.imageUrl)
        : widget.photo.imageUrl.startsWith('assets/')
            ? AssetImage(widget.photo.imageUrl)
            : FileImage(File(widget.photo.imageUrl)) as ImageProvider;

    // Limit to 3 major colors as requested
    final paletteGenerator = await PaletteGenerator.fromImageProvider(provider, maximumColorCount: 3);
    if (mounted) {
      setState(() {
        _extractedColors = paletteGenerator.colors.take(3).toList();
        if (_extractedColors.isNotEmpty) _selectedColor = _extractedColors.first;
        _isExtracting = false;
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a custom color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor ?? Theme.of(context).colorScheme.primary,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('DONE'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, 
                    height: 4, 
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4), 
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Background Style', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _styleChip('Blur', ShareBackgroundType.blur, Icons.blur_on_rounded),
                    _styleChip('Gradient', ShareBackgroundType.gradient, Icons.gradient_rounded),
                    _styleChip('Solid', ShareBackgroundType.solid, Icons.color_lens_rounded),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Dynamic content based on background type selection
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_selectedType == ShareBackgroundType.solid) ...[
                        const Text('Match your photo:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 16),
                        if (_isExtracting)
                          const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                        else
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _extractedColors.length,
                                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                                    itemBuilder: (ctx, i) {
                                      final color = _extractedColors[i];
                                      final isSelected = _selectedColor == color;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedColor = color),
                                        child: Container(
                                          width: 44, height: 44,
                                          decoration: BoxDecoration(
                                            color: color, 
                                            shape: BoxShape.circle, 
                                            border: isSelected ? Border.all(color: cs.primary, width: 3) : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                            boxShadow: isSelected ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)] : null,
                                          ),
                                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const VerticalDivider(indent: 8, endIndent: 8),
                                // 4th Option: Color Wheel Picker
                                GestureDetector(
                                  onTap: _showColorPicker,
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cs.outlineVariant),
                                      gradient: const SweepGradient(
                                        colors: [Colors.red, Colors.yellow, Colors.green, Colors.cyan, Colors.blue, Colors.pink, Colors.red],
                                      ),
                                    ),
                                    child: const Icon(Icons.colorize_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else if (_selectedType == ShareBackgroundType.gradient) ...[
                        const Text('Aesthetic Light Leak', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 16),
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [cs.primary.withValues(alpha: 0.8), cs.secondary.withValues(alpha: 0.8)],
                            ),
                          ),
                          child: const Center(child: Text('Soft Diagonal Blend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Gradient? grad;
                    if (_selectedType == ShareBackgroundType.gradient) {
                      grad = LinearGradient(
                        begin: Alignment.topLeft, 
                        end: Alignment.bottomRight, 
                        colors: [(_selectedColor ?? cs.primary).withValues(alpha: 0.8), Colors.black],
                      );
                    }
                    widget.onShared(_selectedType, _selectedColor, grad);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary, 
                    foregroundColor: cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('GENERATE & SHARE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _styleChip(String label, ShareBackgroundType type, IconData icon) {
    final isSelected = _selectedType == type;
    final cs = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedType = type);
      },
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
      ),
    );
  }
}


