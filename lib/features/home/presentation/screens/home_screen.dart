import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/month_summary_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../budget_rules/presentation/widgets/budget_allocation_mini_cards.dart';
import '../../../budget_rules/presentation/widgets/emergency_fund_card.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../planned_expenses/presentation/widgets/upcoming_expense_preview.dart';
import '../../../savings_projects/presentation/widgets/project_preview_card.dart';
import '../../../streaks/presentation/widgets/streak_badge.dart';
import '../../../tips/presentation/widgets/tip_card.dart';
import '../widgets/budget_hero_card.dart';
import '../widgets/month_end_summary_card.dart';
import '../widgets/recent_transactions_section.dart';
import '../widgets/upcoming_expenses_section.dart';

/// The main home screen of the app.
///
/// Displays the [BudgetHeroCard] as the primary visual element,
/// showing the user's remaining budget at a glance.
///
/// Below the budget card, shows either:
/// - [MonthEndSummaryCard] on the last day(s) of the month
/// - [EmptyStateWidget] when no transactions exist
/// - Space for recent transactions preview (future enhancement)
///
/// Note: FAB is now in MainShell for persistent access across tabs.
class HomeScreen extends ConsumerWidget {
  /// Creates a HomeScreen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch transactions to determine if we should show empty state
    final historyAsync = ref.watch(historyTransactionsProvider);
    final hasTransactions = historyAsync.maybeWhen(
      data: (grouped) => grouped.totalCount > 0,
      orElse: () => false,
    );

    // Watch month-end summary state
    final showSummaryAsync = ref.watch(shouldShowMonthSummaryProvider);
    final summaryAsync = ref.watch(monthSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Streak Badge - user engagement indicator
              const Center(child: StreakBadge()),

              const SizedBox(height: AppSpacing.sm),

              // Tip of the day (compact)
              const TipCardCompact(),

              const SizedBox(height: AppSpacing.md),

              // Budget Hero Card - the main visual element
              const BudgetHeroCard(),

              // 50/30/20 Mini Cards with circular gauges (if enabled)
              const SizedBox(height: AppSpacing.md),
              const BudgetAllocationMiniCards(),

              // Emergency Fund Progress (if enabled)
              const SizedBox(height: AppSpacing.sm),
              const EmergencyFundCard(),

              // Priority savings project preview (if any)
              const SizedBox(height: AppSpacing.sm),
              const ProjectPreviewCard(),

              // Next planned expense preview (if any)
              const SizedBox(height: AppSpacing.sm),
              const UpcomingExpensePreview(),

              // Month-end summary card (FR55)
              showSummaryAsync.when(
                data: (shouldShow) {
                  if (!shouldShow) return const SizedBox.shrink();
                  return summaryAsync.when(
                    data: (summary) {
                      if (summary == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: MonthEndSummaryCard(
                          summary: summary,
                          onDismiss: () => _dismissSummary(ref),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

              const SizedBox(height: AppSpacing.md),

              // Upcoming planned expenses section
              const UpcomingExpensesSection(),

              const SizedBox(height: AppSpacing.sectionSpacing),
              // Empty state or recent transactions
              if (!hasTransactions)
                EmptyStateWidget.home()
              else
                const RecentTransactionsSection(),
            ],
          ),
        ),
      ),
      // Note: FAB moved to MainShell for persistent bottom navigation
    );
  }

  void _dismissSummary(WidgetRef ref) {
    final service = ref.read(monthSummaryServiceProvider);
    service.dismissSummary();
    // Invalidate the provider to refresh the UI
    ref.invalidate(shouldShowMonthSummaryProvider);
  }
}
