import 'package:flutter/material.dart';

/// All color tokens from the Stitch "Albums View" design system.
/// Design: "The Analog Minimalist" — Dark theme.
class AppColors {
  AppColors._();

  // ── Surfaces ──────────────────────────────────────────────
  static const surface = Color(0xFF131313);
  static const surfaceDim = Color(0xFF131313);
  static const surfaceBright = Color(0xFF393939);
  static const surfaceContainerLowest = Color(0xFF0E0E0E);
  static const surfaceContainerLow = Color(0xFF1C1B1B);
  static const surfaceContainer = Color(0xFF20201F);
  static const surfaceContainerHigh = Color(0xFF2A2A2A);
  static const surfaceContainerHighest = Color(0xFF353535);
  static const surfaceVariant = Color(0xFF353535);

  // ── Primary ───────────────────────────────────────────────
  static const primary = Color(0xFFB1CADF);
  static const primaryContainer = Color(0xFF869EB2);
  static const onPrimary = Color(0xFF1B3343);
  static const onPrimaryContainer = Color(0xFF1D3546);
  static const primaryFixed = Color(0xFFCDE6FB);
  static const primaryFixedDim = Color(0xFFB1CADF);

  // ── Secondary ─────────────────────────────────────────────
  static const secondary = Color(0xFFC8C6C2);
  static const secondaryContainer = Color(0xFF494946);
  static const onSecondary = Color(0xFF30312E);
  static const onSecondaryContainer = Color(0xFFB9B8B4);

  // ── Tertiary ──────────────────────────────────────────────
  static const tertiary = Color(0xFFC6C6C7);
  static const tertiaryContainer = Color(0xFF9A9B9B);
  static const onTertiary = Color(0xFF2F3131);

  // ── On-Surface ────────────────────────────────────────────
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFC3C7CC);
  static const inverseSurface = Color(0xFFE5E2E1);
  static const inverseOnSurface = Color(0xFF313030);
  static const inversePrimary = Color(0xFF4A6173);

  // ── Outline ───────────────────────────────────────────────
  static const outline = Color(0xFF8D9196);
  static const outlineVariant = Color(0xFF43474C);

  // ── Error ─────────────────────────────────────────────────
  static const error = Color(0xFFFFB4AB);
  static const errorContainer = Color(0xFF93000A);
  static const onError = Color(0xFF690005);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // ── Accent / Custom ───────────────────────────────────────
  static const customAccent = Color(0xFF869EB2);

  // ── Gradient ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
}
