import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'app_theme.dart';

/// Available accent color palettes.
enum AccentColor {
  steelBlue('Steel Blue', Color(0xFFB1CADF), Color(0xFF869EB2), Color(0xFF1B3343)),
  amber('Amber', Color(0xFFDFC7A5), Color(0xFFB29B76), Color(0xFF3D3020)),
  emerald('Emerald', Color(0xFFA8D5BA), Color(0xFF7AB294), Color(0xFF1B3D2B)),
  rose('Rose', Color(0xFFDFB1C3), Color(0xFFB28698), Color(0xFF431B2E)),
  lavender('Lavender', Color(0xFFC3B1DF), Color(0xFF9886B2), Color(0xFF2B1B43));

  const AccentColor(this.label, this.primary, this.container, this.onPrimary);
  final String label;
  final Color primary;
  final Color container;
  final Color onPrimary;
}

/// Available font families.
enum AppFont {
  inter('Inter'),
  roboto('Roboto'),
  outfit('Outfit');

  const AppFont(this.label);
  final String label;
}

/// Central theme state manager. Exposes reactive [themeData] and notifies
/// listeners when any setting changes. Persists settings to [SharedPreferences].
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AccentColor _accent = AccentColor.steelBlue;
  AppFont _font = AppFont.inter;
  SharedPreferences? _prefs;

  ThemeProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load Theme Mode
    final savedTheme = _prefs?.getString('themeMode');
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => ThemeMode.dark,
      );
    }

    // Load Accent Color
    final savedAccent = _prefs?.getString('accentColor');
    if (savedAccent != null) {
      _accent = AccentColor.values.firstWhere(
        (e) => e.name == savedAccent,
        orElse: () => AccentColor.steelBlue,
      );
    }

    // Load Font
    final savedFont = _prefs?.getString('appFont');
    if (savedFont != null) {
      _font = AppFont.values.firstWhere(
        (e) => e.name == savedFont,
        orElse: () => AppFont.inter,
      );
    }

    notifyListeners();
  }

  // ── Getters ────────────────────────────────────────────────
  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  AccentColor get accent => _accent;
  AppFont get font => _font;

  ThemeData get darkTheme => _buildTheme(Brightness.dark);
  ThemeData get lightTheme => _buildTheme(Brightness.light);

  // ── Setters ────────────────────────────────────────────────
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs?.setString('themeMode', mode.toString());
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefs?.setString('themeMode', _themeMode.toString());
    notifyListeners();
  }

  void setAccent(AccentColor accent) {
    if (_accent == accent) return;
    _accent = accent;
    _prefs?.setString('accentColor', accent.name);
    notifyListeners();
  }

  void setFont(AppFont font) {
    if (_font == font) return;
    _font = font;
    _prefs?.setString('appFont', font.name);
    notifyListeners();
  }

  // ── Theme Builder ──────────────────────────────────────────
  ThemeData _buildTheme(Brightness brightness) {
    final isDarkMode = brightness == Brightness.dark;

    return AppTheme.build(
      brightness: brightness,
      primary: _accent.primary,
      primaryContainer: _accent.container,
      onPrimary: _accent.onPrimary,
      fontFamily: _font.label,
      surface: isDarkMode ? AppColors.surface : const Color(0xFFF5F3F0),
      surfaceContainerLowest: isDarkMode
          ? AppColors.surfaceContainerLowest
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: isDarkMode
          ? AppColors.surfaceContainerLow
          : const Color(0xFFEDEBE8),
      surfaceContainer:
          isDarkMode ? AppColors.surfaceContainer : const Color(0xFFE5E3E0),
      surfaceContainerHigh: isDarkMode
          ? AppColors.surfaceContainerHigh
          : const Color(0xFFDBD9D6),
      surfaceContainerHighest: isDarkMode
          ? AppColors.surfaceContainerHighest
          : const Color(0xFFD1CFCC),
      onSurface:
          isDarkMode ? AppColors.onSurface : const Color(0xFF1C1B1B),
      onSurfaceVariant: isDarkMode
          ? AppColors.onSurfaceVariant
          : const Color(0xFF44474B),
      outlineVariant: isDarkMode
          ? AppColors.outlineVariant
          : const Color(0xFFC3C7CC),
    );
  }
}
