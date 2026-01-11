import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/pattern_analysis_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../history/presentation/providers/history_provider.dart';

/// Medal emojis for ranking.
const List<String> _medals = ['🥇', '🥈', '🥉'];

/// Card showing the top 3 expense categories.
///
/// Displays categories ranked by total spending with:
/// - Medal emoji for ranking (🥇🥈🥉)
/// - Category icon and name
/// - Total amount spent
/// - Tap navigation to filtered history
///
/// Covers: FR20
class TopCategoriesCard extends ConsumerWidget {
  /// Creates a TopCategoriesCard.
  const TopCategoriesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryBreakdownProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        // Take top 3 (or less if fewer categories)
        final topCategories = categories.take(3).toList();

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
                    Icons.emoji_events,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Top ${topCategories.length} Categories',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Top categories list
              ...List.generate(
                topCategories.length,
                (index) => _TopCategoryItem(
                  rank: index,
                  category: topCategories[index],
                  onTap: () => _navigateToFilteredHistory(
                    context,
                    ref,
                    topCategories[index].categoryId,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _navigateToFilteredHistory(
    BuildContext context,
    WidgetRef ref,
    String categoryId,
  ) {
    // Set the category filter
    ref.read(historyCategoryFilterProvider.notifier).state = categoryId;
    // Navigate to history
    context.go(AppRoutes.history);
  }
}

/// Individual top category item.
class _TopCategoryItem extends StatelessWidget {
  const _TopCategoryItem({
    required this.rank,
    required this.category,
    required this.onTap,
  });

  final int rank;
  final CategorySpending category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            children: [
              // Medal
              Text(
                _medals[rank],
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Category icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getRankColor(rank).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.categoryIcon,
                  size: 20,
                  color: _getRankColor(rank),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Category name
              Expanded(
                child: Text(
                  category.categoryLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),

              // Amount
              Text(
                _formatAmount(category.totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.onSurface,
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              // Chevron
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.primary;
    }
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
