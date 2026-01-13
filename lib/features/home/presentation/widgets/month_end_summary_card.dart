import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/month_summary_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/budget_colors.dart';
import '../../../../shared/utils/fcfa_formatter.dart';

/// Card displaying month-end summary on the home screen.
///
/// Shows final budget balance, total spent, total income, and top category.
/// Appears on the last day(s) of the month until dismissed.
///
/// Covers: FR55, Story 4.9
class MonthEndSummaryCard extends ConsumerWidget {
  const MonthEndSummaryCard({
    super.key,
    required this.summary,
    required this.onDismiss,
  });

  final MonthSummary summary;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: summary.isPositive
              ? BudgetColors.ok.withValues(alpha: 0.3)
              : BudgetColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Bilan ${summary.monthName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Final balance - the hero number
            Center(
              child: Column(
                children: [
                  Text(
                    'Solde final',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${summary.isPositive ? '+' : ''}${FcfaFormatter.format(summary.remainingBudget)} FCFA',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: summary.isPositive
                          ? BudgetColors.ok
                          : BudgetColors.danger,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Revenus',
                    value: summary.totalIncome,
                    isPositive: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.outlineVariant,
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Depenses',
                    value: summary.totalSpent,
                    isPositive: false,
                  ),
                ),
              ],
            ),

            // Top category if available
            if (summary.topCategory != null) ...[
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Top catégorie: ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    summary.topCategory!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    FcfaFormatter.format(summary.topCategoryAmount),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(color: AppColors.outlineVariant),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                    child: const Text('Fermer'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.push('/patterns'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                    child: const Text('Voir details'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.isPositive,
  });

  final String label;
  final int value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${isPositive ? '+' : '-'}${FcfaFormatter.format(value)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isPositive ? BudgetColors.ok : BudgetColors.danger,
          ),
        ),
      ],
    );
  }
}
