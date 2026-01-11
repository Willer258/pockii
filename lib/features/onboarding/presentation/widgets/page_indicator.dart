import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// A horizontal row of dots indicating current page position.
///
/// Used in the onboarding flow to show progress through screens.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.totalPages,
    required this.currentPage,
    super.key,
  });

  /// Total number of pages
  final int totalPages;

  /// Current page index (0-based)
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Page ${currentPage + 1} sur $totalPages',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => _buildDot(context, index, theme),
        ),
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index, ThemeData theme) {
    final isActive = index == currentPage;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
