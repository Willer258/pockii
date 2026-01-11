import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/pattern_analysis_service.dart';
import '../../../../core/services/pattern_unlock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/category_detail_dialog.dart';
import '../widgets/day_of_week_spending_card.dart';
import '../widgets/income_expense_overview_card.dart';
import '../widgets/month_comparison_card.dart';
import '../widgets/top_categories_card.dart';

/// Screen for the Patterns feature.
///
/// Shows either:
/// - Locked state with progress when <30 days of data
/// - Unlock celebration (one-time) when first reaching 30 days
/// - Full patterns screen when unlocked
///
/// Covers: FR18, Story 5.1
class PatternsLockedScreen extends ConsumerStatefulWidget {
  /// Creates a PatternsLockedScreen.
  const PatternsLockedScreen({super.key});

  @override
  ConsumerState<PatternsLockedScreen> createState() =>
      _PatternsLockedScreenState();
}

class _PatternsLockedScreenState extends ConsumerState<PatternsLockedScreen> {
  bool _showingCelebration = false;

  @override
  void initState() {
    super.initState();
    _checkForCelebration();
  }

  Future<void> _checkForCelebration() async {
    final service = ref.read(patternUnlockServiceProvider);
    final shouldShow = await service.shouldShowCelebration();
    if (shouldShow && mounted) {
      setState(() => _showingCelebration = true);
      // Auto-dismiss after animation
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          service.markCelebrationShown();
          setState(() => _showingCelebration = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAsync = ref.watch(patternUnlockedProvider);
    final daysRemainingAsync = ref.watch(patternDaysRemainingProvider);
    final progressAsync = ref.watch(patternProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes Patterns'),
        centerTitle: true,
      ),
      body: unlockedAsync.when(
        data: (isUnlocked) {
          if (_showingCelebration) {
            return _UnlockCelebration();
          }

          if (isUnlocked) {
            return _PatternsContent();
          }

          // Show locked state with progress
          return daysRemainingAsync.when(
            data: (daysRemaining) => progressAsync.when(
              data: (progress) => _LockedState(
                daysRemaining: daysRemaining,
                progress: progress,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => EmptyStateWidget.patternsLocked(daysRemaining: 30),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => EmptyStateWidget.patternsLocked(daysRemaining: 30),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => EmptyStateWidget.patternsLocked(daysRemaining: 30),
      ),
    );
  }
}

/// Locked state showing progress toward unlock.
class _LockedState extends StatelessWidget {
  const _LockedState({
    required this.daysRemaining,
    required this.progress,
  });

  final int daysRemaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lock icon with progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              Icon(
                Icons.lock_outline,
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Patterns verrouilles',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.sm),

          // Days remaining
          Text(
            daysRemaining == 1
                ? 'Encore 1 jour avant de debloquer'
                : 'Encore $daysRemaining jours avant de debloquer',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Progress text
          Text(
            '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Explanation
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Pourquoi 30 jours?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'On a besoin de suffisamment de donnees pour te montrer des insights vraiment utiles sur tes habitudes.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Unlock celebration animation.
class _UnlockCelebration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated checkmark/unlock icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_open,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Celebration text
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Column(
                children: [
                  Text(
                    'Tes patterns sont prets!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Decouvre tes habitudes de depenses',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full patterns screen with category analysis.
///
/// Shows spending breakdown by category with:
/// - Donut chart visualization
/// - Category list with amounts and percentages
/// - Tap interaction for detailed view
///
/// Covers: FR19, UX-9
class _PatternsContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryBreakdownAsync = ref.watch(categoryBreakdownProvider);

    return categoryBreakdownAsync.when(
      data: (categories) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title
            Text(
              'Repartition par categorie',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Category breakdown chart
            CategoryBreakdownChart(
              categories: categories,
              onCategoryTap: (categoryId) {
                CategoryDetailDialog.show(context, categoryId);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // Top 3 categories (Story 5.3)
            const TopCategoriesCard(),

            const SizedBox(height: AppSpacing.lg),

            // Month comparison (Story 5.4)
            const MonthComparisonCard(),

            const SizedBox(height: AppSpacing.lg),

            // Income vs Expenses overview (Story 5.5)
            const IncomeExpenseOverviewCard(),

            const SizedBox(height: AppSpacing.lg),

            // Day-of-week spending distribution (Story 5.6)
            const DayOfWeekSpendingCard(),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text('Erreur de chargement'),
          ],
        ),
      ),
    );
  }
}
