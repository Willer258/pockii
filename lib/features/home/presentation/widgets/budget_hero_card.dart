import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_border_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/budget_colors.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../domain/models/budget_state.dart';
import '../providers/budget_provider.dart';

/// The hero card displaying the user's remaining budget.
///
/// This is the central visual element of the app, showing:
/// - The remaining budget amount in large 56sp font
/// - Color-coded status (green/orange/red)
/// - Current month label
/// - Progress bar showing remaining/total
///
/// Covers: FR1, FR3, FR4, UX-1, UX-11
class BudgetHeroCard extends ConsumerWidget {
  const BudgetHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetState = ref.watch(budgetStateProvider);
    final monthLabel = ref.watch(currentMonthLabelProvider);

    if (budgetState.isLoading) {
      return const _LoadingCard();
    }

    if (budgetState.hasError) {
      return _ErrorCard(error: budgetState.error ?? 'Erreur inconnue');
    }

    return _BudgetCard(
      budgetState: budgetState,
      monthLabel: monthLabel,
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budgetState,
    required this.monthLabel,
  });

  final BudgetState budgetState;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final statusColor = BudgetColors.forPercentage(
      budgetState.percentageRemaining,
    );

    final formattedAmount = FcfaFormatter.formatCompact(
      budgetState.remainingBudget,
    );
    final progressValue = budgetState.percentageRemaining.clamp(0.0, 1.0);

    return Semantics(
      label: _buildAccessibilityLabel(),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Month label
              Text(
                monthLabel,
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // "Reste à vivre" label
              Text(
                'Reste à vivre',
                style: AppTypography.body.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Hero number
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTypography.hero.copyWith(color: statusColor),
                child: Text(formattedAmount),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Currency suffix
              Text(
                'FCFA',
                style: AppTypography.title.copyWith(
                  color: statusColor,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.chip),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Budget summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dépensé: ${FcfaFormatter.format(budgetState.totalBudget - budgetState.remainingBudget)}',
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Budget: ${FcfaFormatter.format(budgetState.totalBudget)}',
                    style: AppTypography.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildAccessibilityLabel() {
    final status = BudgetColors.accessibilityLabel(
      budgetState.percentageRemaining,
    );
    final amount = FcfaFormatter.formatCompact(budgetState.remainingBudget);

    return '$status. Reste à vivre: $amount francs CFA. '
        '$monthLabel.';
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.xl),
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text('Chargement...'),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Erreur de chargement',
              style: AppTypography.title.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
