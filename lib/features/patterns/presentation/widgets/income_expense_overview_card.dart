import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/pattern_analysis_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Card showing income vs expenses overview for current month.
///
/// Displays:
/// - Total income and total expenses for the month
/// - Net balance (income - expenses)
/// - Visual indicator for positive/negative balance
/// - "No data" state when no transactions exist
///
/// Covers: FR22, Story 5.5
class IncomeExpenseOverviewCard extends ConsumerWidget {
  /// Creates an IncomeExpenseOverviewCard.
  const IncomeExpenseOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(incomeExpenseOverviewProvider);

    return overviewAsync.when(
      data: (overview) {
        if (!overview.hasIncome && !overview.hasExpenses) {
          return _NoDataState(monthName: overview.monthName);
        }

        return _OverviewContent(overview: overview);
      },
      loading: () => const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Overview content when data exists.
class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.overview});

  final IncomeExpenseOverview overview;

  @override
  Widget build(BuildContext context) {
    final balanceColor = overview.isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Revenus vs Depenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  overview.monthName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Income and expense rows
          _AmountRow(
            icon: Icons.arrow_downward,
            iconColor: AppColors.success,
            label: 'Revenus',
            amount: overview.totalIncome,
            amountColor: AppColors.success,
          ),

          const SizedBox(height: AppSpacing.sm),

          _AmountRow(
            icon: Icons.arrow_upward,
            iconColor: AppColors.error,
            label: 'Depenses',
            amount: overview.totalExpenses,
            amountColor: AppColors.error,
          ),

          const SizedBox(height: AppSpacing.md),

          // Divider
          Divider(color: AppColors.outlineVariant, height: 1),

          const SizedBox(height: AppSpacing.md),

          // Net balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Solde net',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Row(
                children: [
                  Icon(
                    overview.isPositive
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: balanceColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatAmount(overview.netBalance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Status message
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: balanceColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  overview.isPositive ? '💰' : '⚠️',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    overview.isPositive
                        ? 'Tu es dans le positif ce mois!'
                        : 'Tu depenses plus que tu gagnes',
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '+';
    if (absAmount >= 1000000) {
      return '$sign${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '$sign${(absAmount / 1000).toStringAsFixed(0)}K';
    }
    return '$sign$absAmount';
  }
}

/// Row showing icon, label, and amount.
class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          _formatAmount(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K FCFA';
    }
    return '$amount FCFA';
  }
}

/// State shown when no income or expenses exist.
class _NoDataState extends StatelessWidget {
  const _NoDataState({required this.monthName});

  final String monthName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Revenus vs Depenses',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.inbox_outlined,
            color: AppColors.onSurfaceVariant,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pas de donnees ce mois',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ajoute des revenus ou depenses pour voir le bilan',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
