import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/photo.dart';

enum ShareBackgroundType { blur, gradient, solid }

class ShareImageService {
  static final ScreenshotController _screenshotController = ScreenshotController();

  /// Captures a branded Polaroid layout offscreen and shares it natively.
  /// V4 adds support for selectable background styles.
  static Future<void> sharePhoto(
    BuildContext context, 
    Photo photo, {
    required bool isStory,
    ShareBackgroundType backgroundType = ShareBackgroundType.blur,
    Color? backgroundColor,
    Gradient? backgroundGradient,
  }) async {
    // 1. Ensure the image is fully loaded into memory before we try to capture it.
    await _waitForImage(context, photo.imageUrl);

    // 2. Build the stylized layout (off-screen)
    Widget captureWidget = _buildShareWidget(
      context, 
      photo, 
      isStory: isStory,
      backgroundType: backgroundType,
      backgroundColor: backgroundColor,
      backgroundGradient: backgroundGradient,
    );

    try {
      // 3. Render to memory with high pixel ratio for professional quality
      final imageBytes = await _screenshotController.captureFromWidget(
        captureWidget,
        delay: const Duration(milliseconds: 500), // Safety buffer
        context: context,
        pixelRatio: 3.0, // High quality "Retina" render
      );

      if (imageBytes == null) throw Exception("Failed to capture widget");

      // 4. Save bytes to a temporary local file 
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/curator_share_${DateTime.now().millisecondsSinceEpoch}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      // 5. Trigger the native Share Sheet
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Shared from Curator ✨',
      );
    } catch (e) {
      debugPrint('Error generating share artifact: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate professional share image.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Helper to guarantee the image is in the GPU/Memory cache
  static Future<void> _waitForImage(BuildContext context, String url) async {
    final Completer<void> completer = Completer();
    final ImageProvider provider = url.startsWith('http')
        ? NetworkImage(url)
        : url.startsWith('assets/')
            ? AssetImage(url)
            : FileImage(File(url)) as ImageProvider;

    final ImageStream stream = provider.resolve(createLocalImageConfiguration(context));
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool sync) {
        if (!completer.isCompleted) completer.complete();
        stream.removeListener(listener);
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        if (!completer.isCompleted) completer.complete();
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    
    return completer.future.timeout(const Duration(seconds: 5), onTimeout: () {});
  }

  /// Helper to build the photo image widget
  static Widget _buildPhotoImage(Photo photo, {BoxFit fit = BoxFit.cover}) {
    if (photo.imageUrl.startsWith('http')) {
      return Image.network(photo.imageUrl, fit: fit, filterQuality: FilterQuality.high);
    } else if (photo.imageUrl.startsWith('assets/')) {
      return Image.asset(photo.imageUrl, fit: fit, filterQuality: FilterQuality.high);
    } else {
      return Image.file(File(photo.imageUrl), fit: fit, filterQuality: FilterQuality.high);
    }
  }

  /// The refined "Curated." style rendering layout
  static Widget _buildShareWidget(
    BuildContext context, 
    Photo photo, {
    required bool isStory,
    ShareBackgroundType backgroundType = ShareBackgroundType.blur,
    Color? backgroundColor,
    Gradient? backgroundGradient,
  }) {
    final Size size = isStory ? const Size(1080, 1920) : const Size(1080, 1080);
    
    return MediaQuery(
      data: MediaQueryData(size: size, devicePixelRatio: 3.0),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: isStory ? (backgroundColor ?? Colors.black) : const Color(0xFF1A1A1A),
            gradient: (isStory && backgroundType == ShareBackgroundType.gradient)
                ? backgroundGradient
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final double h = constraints.maxHeight;

              // All proportions relative to actual render size
              final double cardWidthFraction = 0.78;
              final double cardWidth = w * cardWidthFraction;
              final double cardLeft = (w - cardWidth) / 2;
              
              // Instagram Story Safe Zones (offsets to avoid UI overlap)
              final double cardTop = isStory ? h * 0.18 : h * 0.13;
              final double watermarkBottom = isStory ? h * 0.14 : h * 0.07;
              
              final double borderPad = cardWidth * 0.032; // white border around image
              final double chinPad = cardWidth * 0.08; // chin bottom padding
              final double titleSize = (w * 0.065).clamp(20.0, 40.0); // scales with width
              final double captionSize = (w * 0.028).clamp(9.0, 16.0);
              final double brandSize = (w * 0.08).clamp(28.0, 48.0);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Background Layer
                  if (isStory && backgroundType == ShareBackgroundType.blur) ...[
                    Positioned.fill(child: _buildPhotoImage(photo)),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ],

                  if (!isStory)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: Image.asset(
                          'assets/images/sand_grain.png',
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),

                  // 2. Polaroid Card — proportionally positioned
                  Positioned(
                    top: cardTop,
                    left: cardLeft,
                    child: Container(
                      width: cardWidth,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9F9F9),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 12),
                            blurRadius: 30,
                            color: Color.fromRGBO(0, 0, 0, 0.15),
                          ),
                          BoxShadow(
                            offset: Offset(0, 4),
                            blurRadius: 10,
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Square image with white border padding
                          Padding(
                            padding: EdgeInsets.only(
                              top: borderPad,
                              left: borderPad,
                              right: borderPad,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: ClipRect(child: _buildPhotoImage(photo)),
                            ),
                          ),
                          // Chin area with title & caption
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              borderPad + 4, // slightly inset from image edge
                              borderPad * 0.7,
                              borderPad,
                              chinPad,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Heavy Title
                                Text(
                                  photo.title.toLowerCase(),
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                    color: const Color(0xFF1A1A1A),
                                  ),
                                ),
                                if (photo.caption != null && photo.caption!.isNotEmpty) ...[
                                  SizedBox(height: chinPad * 0.06),
                                  // Heavy Caption
                                  Text(
                                    photo.caption!.toUpperCase(),
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.inter(
                                      fontSize: captionSize,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: const Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Bottom-Left Watermark
                  Positioned(
                    bottom: watermarkBottom,
                    left: w * 0.05,
                    child: Opacity(
                      opacity: 0.75,
                      child: Text(
                        'Curated.',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: brandSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
