import 'package:flutter/material.dart';
import '../../app.dart';
import '../../theme/theme_provider.dart';

/// Settings screen with functional theme controls.
///
/// All changes are applied in real-time via [ThemeProvider]:
/// - Dark / Light mode toggle
/// - Accent color picker (5 palettes)
/// - Typography selector (Inter, Roboto, Outfit)
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CuratorApp.themeOf(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
            elevation: 0,
            title: Text(
              'Settings',
              style: tt.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ══════════════════════════════════════════════
                // APPEARANCE
                // ══════════════════════════════════════════════
                _sectionLabel(context, 'APPEARANCE'),
                const SizedBox(height: 12),
                _group(
                  context,
                  children: [
                    // ── Dark / Light Toggle ─────────────────
                    _switchTile(
                      context,
                      icon: theme.isDark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'Dark Mode',
                      subtitle: theme.isDark
                          ? 'Dark color scheme active'
                          : 'Light color scheme active',
                      value: theme.isDark,
                      onChanged: (_) => theme.toggleTheme(),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // THEME COLOR
                // ══════════════════════════════════════════════
                _sectionLabel(context, 'THEME COLOR'),
                const SizedBox(height: 12),
                _group(
                  context,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accent Color',
                            style: tt.titleSmall
                                ?.copyWith(color: cs.onSurface),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.accent.label,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: AccentColor.values.map((accent) {
                              final isSelected = theme.accent == accent;
                              return GestureDetector(
                                onTap: () => theme.setAccent(accent),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: accent.primary,
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: cs.onSurface,
                                            width: 2.5,
                                          )
                                        : null,
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: accent.primary
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: accent.onPrimary,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          // Color labels
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: AccentColor.values.map((accent) {
                              final isSelected = theme.accent == accent;
                              return SizedBox(
                                width: 50,
                                child: Text(
                                  accent.label.split(' ').last,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // TYPOGRAPHY
                // ══════════════════════════════════════════════
                _sectionLabel(context, 'TYPOGRAPHY'),
                const SizedBox(height: 12),
                _group(
                  context,
                  children: AppFont.values.map((font) {
                    final isSelected = theme.font == font;
                    return _radioTile(
                      context,
                      icon: Icons.text_fields_rounded,
                      title: font.label,
                      subtitle: _fontDescription(font),
                      isSelected: isSelected,
                      onTap: () => theme.setFont(font),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // PREVIEW
                // ══════════════════════════════════════════════
                _sectionLabel(context, 'PREVIEW'),
                const SizedBox(height: 12),
                _themePreviewCard(context, theme),

                const SizedBox(height: 28),

                // ══════════════════════════════════════════════
                // ABOUT
                // ══════════════════════════════════════════════
                _sectionLabel(context, 'ABOUT'),
                const SizedBox(height: 12),
                _group(
                  context,
                  children: [
                    _navTile(context,
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        subtitle: '1.0.0'),
                    _navTile(context,
                        icon: Icons.description_outlined,
                        title: 'Licenses'),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  String _fontDescription(AppFont font) {
    switch (font) {
      case AppFont.inter:
        return 'Clean geometric sans-serif (default)';
      case AppFont.roboto:
        return "Google's open-source typeface";
      case AppFont.outfit:
        return 'Modern geometric with personality';
    }
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _group(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: cs.onSurface)),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: cs.primary,
            activeTrackColor: cs.primaryContainer,
            inactiveThumbColor: cs.onSurfaceVariant,
            inactiveTrackColor: cs.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _radioTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurfaceVariant, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(color: cs.onSurface)),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outlineVariant,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: cs.onSurface)),
                if (subtitle != null)
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }

  /// Live preview card showing current theme settings.
  Widget _themePreviewCard(BuildContext context, ThemeProvider theme) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme Preview', style: tt.titleSmall?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 16),
          // Color + font summary
          Row(
            children: [
              // Gradient swatch
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [theme.accent.primary, theme.accent.container],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accent.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.accent.label,
                      style: tt.titleSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${theme.font.label} • ${theme.isDark ? "Dark" : "Light"} Mode',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sample text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Headline Preview',
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Body text using ${theme.font.label} in ${theme.isDark ? 'dark' : 'light'} mode.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
