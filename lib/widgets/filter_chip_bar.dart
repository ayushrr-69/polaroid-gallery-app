import 'package:flutter/material.dart';

/// Horizontal scrollable list of filter chips with animated selection.
/// Uses [Theme.of(context).colorScheme] for dynamic theming.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9999),
              ),
              alignment: Alignment.center,
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected
                      ? cs.onPrimary
                      : cs.onSurface,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
