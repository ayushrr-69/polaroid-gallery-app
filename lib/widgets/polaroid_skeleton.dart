import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmering skeleton placeholder for the PolaroidCard.
class PolaroidSkeleton extends StatelessWidget {
  const PolaroidSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;

    // Use colors that match the glassmorphic/premium theme
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[200]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 12),
            blurRadius: 24,
            color: Color.fromRGBO(0, 0, 0, 0.15),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Image Shimmer ────────────────────────
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: AspectRatio(
              aspectRatio: 0.8, // standard portrait polaroid
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // ── Title/Caption Shimmer ────────────────
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
