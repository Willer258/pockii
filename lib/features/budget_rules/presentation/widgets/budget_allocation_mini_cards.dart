import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../domain/enums/expense_category.dart';
import '../../domain/models/budget_allocation.dart';
import '../providers/budget_rules_provider.dart';

/// Compact horizontal row of circular progress indicators for 50/30/20 rule.
///
/// Shows three mini cards with circular gauges for Besoins, Envies, Épargne.
/// Only displays if budget rules are enabled in settings.
class BudgetAllocationMiniCards extends ConsumerWidget {
  const BudgetAllocationMiniCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allocation = ref.watch(budgetAllocationProvider);

    // Don't show if not enabled or no data
    if (allocation == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _CircularBudgetCard(
              categoryAllocation: allocation.needs,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CircularBudgetCard(
              categoryAllocation: allocation.wants,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _CircularBudgetCard(
              categoryAllocation: allocation.savings,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual circular budget card for a category.
class _CircularBudgetCard extends StatelessWidget {
  const _CircularBudgetCard({
    required this.categoryAllocation,
  });

  final CategoryAllocation categoryAllocation;

  @override
  Widget build(BuildContext context) {
    final category = categoryAllocation.category;
    final progress = categoryAllocation.progress.clamp(0.0, 1.0);
    final isOver = categoryAllocation.isOverBudget;
    final percentage = (categoryAllocation.progress * 100).clamp(0, 999).toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOver
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress indicator
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOver ? AppColors.error : category.color,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Center content - emoji and percentage
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isOver ? AppColors.error : category.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Category name
          Text(
            category.displayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Amount remaining
          Text(
            isOver
                ? '-${FcfaFormatter.formatCompact(-categoryAllocation.remaining)}'
                : FcfaFormatter.formatCompact(categoryAllocation.remaining),
            style: TextStyle(
              fontSize: 10,
              color: isOver ? AppColors.error : AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
