import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Section header widget showing date label in transaction list.
///
/// Displays date labels like "Aujourd'hui", "Hier", or "DD/MM/YYYY"
/// with consistent styling across the history screen.
class DateSectionHeader extends StatelessWidget {
  /// Creates a DateSectionHeader.
  const DateSectionHeader({
    required this.label,
    super.key,
  });

  /// The date label to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surfaceVariant,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}
