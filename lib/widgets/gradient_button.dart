import 'package:flutter/material.dart';

/// Gradient-filled primary CTA button.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDisabled = onPressed == null;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 12),
                blurRadius: 32,
                color: cs.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: cs.onPrimary, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ghost-styled secondary button.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: cs.onSurface, size: 20),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
