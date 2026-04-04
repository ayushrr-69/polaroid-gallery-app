import 'dart:ui';
import 'package:flutter/material.dart';

/// A floating glassmorphism bottom navigation bar with a sliding card indicator.
///
/// Uses [Theme.of(context).colorScheme] for dynamic theming — responds to
/// dark/light mode and accent color changes from ThemeProvider.
class FrostedNavBar extends StatelessWidget {
  const FrostedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 16),
                  blurRadius: 40,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                // Inner subtle shine
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: -5,
                  blurStyle: BlurStyle.inner,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / 3;

                return Stack(
                  children: [
                    // Sliding active highlight card
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: currentIndex * tabWidth + 8,
                      width: tabWidth - 16,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // Navigation Icons
                    Positioned.fill(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _NavItem(
                              icon: Icons.grid_view_rounded,
                              activeIcon: Icons.grid_view_rounded,
                              label: 'Gallery',
                              isSelected: currentIndex == 0,
                              onTap: () => onTap(0),
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: Icons.favorite_border_rounded,
                              activeIcon: Icons.favorite_rounded,
                              label: 'Favorites',
                              isSelected: currentIndex == 1,
                              onTap: () => onTap(1),
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              icon: Icons.style_outlined,
                              activeIcon: Icons.style_rounded,
                              label: 'Albums',
                              isSelected: currentIndex == 2,
                              onTap: () => onTap(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.labelSmall?.fontFamily,
                fontSize: isSelected ? 9.5 : 9.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? cs.primary
                    : cs.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: isSelected ? 0.8 : 0.5,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
