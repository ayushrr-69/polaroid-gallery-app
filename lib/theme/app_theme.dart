import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Generates the full [ThemeData] for the app.
///
/// [AppTheme.dark()] returns the default Stitch dark theme.
/// [AppTheme.build()] accepts dynamic parameters from ThemeProvider.
class AppTheme {
  AppTheme._();

  /// Default dark theme using the original Stitch spec.
  static ThemeData dark() => build(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        onPrimary: AppColors.onPrimary,
        fontFamily: 'Inter',
        surface: AppColors.surface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outlineVariant: AppColors.outlineVariant,
      );

  /// Parameterized builder for dynamic theming.
  static ThemeData build({
    required Brightness brightness,
    required Color primary,
    required Color primaryContainer,
    required Color onPrimary,
    required String fontFamily,
    required Color surface,
    required Color surfaceContainerLowest,
    required Color surfaceContainerLow,
    required Color surfaceContainer,
    required Color surfaceContainerHigh,
    required Color surfaceContainerHighest,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outlineVariant,
  }) {
    final isDark = brightness == Brightness.dark;

    // Select the right Google Font
    TextStyle Function({
      TextStyle? textStyle,
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? letterSpacing,
      double? height,
    }) fontBuilder;

    switch (fontFamily) {
      case 'Roboto':
        fontBuilder = ({
          textStyle,
          color,
          fontSize,
          fontWeight,
          letterSpacing,
          height,
        }) =>
            GoogleFonts.roboto(
              textStyle: textStyle,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              height: height,
            );
        break;
      case 'Outfit':
        fontBuilder = ({
          textStyle,
          color,
          fontSize,
          fontWeight,
          letterSpacing,
          height,
        }) =>
            GoogleFonts.outfit(
              textStyle: textStyle,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              height: height,
            );
        break;
      default: // Inter
        fontBuilder = ({
          textStyle,
          color,
          fontSize,
          fontWeight,
          letterSpacing,
          height,
        }) =>
            GoogleFonts.inter(
              textStyle: textStyle,
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              height: height,
            );
    }

    final textTheme = TextTheme(
      displayLarge: fontBuilder(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 57,
        color: onSurface,
      ),
      displayMedium: fontBuilder(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 45,
        color: onSurface,
      ),
      displaySmall: fontBuilder(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.02 * 36,
        color: onSurface,
      ),
      headlineLarge: fontBuilder(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineMedium: fontBuilder(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineSmall: fontBuilder(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      titleLarge: fontBuilder(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleMedium: fontBuilder(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleSmall: fontBuilder(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      bodyLarge: fontBuilder(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: fontBuilder(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      bodySmall: fontBuilder(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: onSurfaceVariant,
      ),
      labelLarge: fontBuilder(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1 * 14,
        color: onSurface,
      ),
      labelMedium: fontBuilder(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1 * 12,
        color: onSurfaceVariant,
      ),
      labelSmall: fontBuilder(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1 * 11,
        color: onSurfaceVariant,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onSurface,
        secondary: isDark ? AppColors.secondary : const Color(0xFF5A5957),
        onSecondary: isDark ? AppColors.onPrimary : const Color(0xFFFFFFFF),
        error: AppColors.error,
        onError: AppColors.onPrimary,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainerHighest: surfaceContainerHighest,
        outline: isDark ? AppColors.outline : const Color(0xFF8D9196),
        outlineVariant: outlineVariant,
      ),
      textTheme: textTheme,

      // ── App Bar ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: fontBuilder(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
      ),

      // ── Cards ────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // ── Inputs ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: primary.withValues(alpha: 0.4), width: 1.5),
        ),
        hintStyle: TextStyle(
          color: onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── FAB ──────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Chips ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHighest,
        selectedColor: primary,
        labelStyle: TextStyle(color: onSurface, fontSize: 12),
        secondaryLabelStyle: TextStyle(color: onPrimary, fontSize: 12),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
    );
  }
}
