import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CircularButtonSize { small, large }

/// Circular icon button with dynamic theming.
class CircularButton extends StatelessWidget {
  const CircularButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = CircularButtonSize.large,
    this.glow = false,
    this.iconColor,
    this.isLoading = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final CircularButtonSize size;
  final bool glow;
  final Color? iconColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dim = size == CircularButtonSize.large ? 52.0 : 40.0;
    final iconSize = size == CircularButtonSize.large ? 24.0 : 20.0;
    final resolvedIconColor = iconColor ?? cs.onSurface;

    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              HapticFeedback.lightImpact(); // Added haptics
              onPressed?.call();
            },
      child: Container(
        width: dim,
        height: dim,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.surfaceContainerHigh,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 24,
              color: const Color.fromRGBO(0, 0, 0, 0.35),
            ),
            if (glow)
              BoxShadow(
                blurRadius: 16,
                color: cs.primary.withValues(alpha: 0.25),
              ),
          ],
        ),
        child: Center(
          child: isLoading 
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: resolvedIconColor,
                  ),
                )
              : Icon(icon, color: resolvedIconColor, size: iconSize),
        ),
      ),
    );
  }
}
