import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../budget_rules/presentation/providers/budget_rules_provider.dart';
import '../../../planned_expenses/presentation/providers/planned_expenses_list_provider.dart';
import '../../../savings_projects/presentation/providers/savings_projects_provider.dart';
import '../../../subscriptions/presentation/providers/subscriptions_list_provider.dart';

/// Screen for managing finances: savings projects, planned expenses, subscriptions, emergency fund.
///
/// This screen provides quick access to all financial management features
/// that were previously only accessible through Settings.
class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes finances'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Savings Projects Section
          _SavingsProjectsCard(),
          const SizedBox(height: AppSpacing.md),

          // Planned Expenses Section
          _PlannedExpensesCard(),
          const SizedBox(height: AppSpacing.md),

          // Subscriptions Section
          _SubscriptionsCard(),
          const SizedBox(height: AppSpacing.md),

          // Emergency Fund Section
          _EmergencyFundCard(),
        ],
      ),
    );
  }
}

/// Card for savings projects section.
class _SavingsProjectsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(activeProjectsProvider);
    final stats = ref.watch(projectsStatsProvider);

    return _FinanceCard(
      icon: Icons.savings_outlined,
      iconColor: AppColors.primary,
      title: 'Projets d\'épargne',
      onTap: () => context.push('/projects'),
      child: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _CardContent(
              mainText: 'Aucun projet',
              subText: 'Crée ta première cagnotte',
              actionText: 'Créer un projet',
              onAction: () => context.push('/projects/create'),
            );
          }
          return _CardContent(
            mainText: '${projects.length} projet${projects.length > 1 ? 's' : ''} actif${projects.length > 1 ? 's' : ''}',
            subText: 'Total épargné: ${FcfaFormatter.format(stats.totalSaved)}',
            progress: stats.overallProgress,
            progressLabel: '${(stats.overallProgress * 100).round()}% de l\'objectif',
          );
        },
        loading: () => const _CardContentLoading(),
        error: (_, __) => const _CardContentError(),
      ),
    );
  }
}

/// Card for planned expenses section.
class _PlannedExpensesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(pendingPlannedExpensesProvider);
    final totalAsync = ref.watch(totalPendingAmountProvider);

    return _FinanceCard(
      icon: Icons.event_note_outlined,
      iconColor: Colors.orange,
      title: 'Dépenses prévues',
      onTap: () => context.push('/planned-expenses'),
      child: expensesAsync.when(
        data: (expenses) {
          final total = totalAsync.maybeWhen(
            data: (t) => t,
            orElse: () => 0,
          );
          if (expenses.isEmpty) {
            return _CardContent(
              mainText: 'Aucune dépense prévue',
              subText: 'Planifie tes futures dépenses',
              actionText: 'Ajouter une dépense',
              onAction: () => context.push('/planned-expenses'),
            );
          }
          return _CardContent(
            mainText: '${expenses.length} dépense${expenses.length > 1 ? 's' : ''} en attente',
            subText: 'Total: ${FcfaFormatter.format(total)}',
          );
        },
        loading: () => const _CardContentLoading(),
        error: (_, __) => const _CardContentError(),
      ),
    );
  }
}

/// Card for subscriptions section.
class _SubscriptionsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final totalAsync = ref.watch(totalMonthlyAmountProvider);

    return _FinanceCard(
      icon: Icons.repeat_outlined,
      iconColor: Colors.blue,
      title: 'Abonnements',
      onTap: () => context.push('/subscriptions'),
      child: subscriptionsAsync.when(
        data: (subscriptions) {
          final total = totalAsync.maybeWhen(
            data: (t) => t,
            orElse: () => 0,
          );
          if (subscriptions.isEmpty) {
            return _CardContent(
              mainText: 'Aucun abonnement',
              subText: 'Ajoute tes abonnements récurrents',
              actionText: 'Ajouter un abonnement',
              onAction: () => context.push('/subscriptions'),
            );
          }
          return _CardContent(
            mainText: '${subscriptions.length} abonnement${subscriptions.length > 1 ? 's' : ''}',
            subText: 'Total mensuel: ${FcfaFormatter.format(total)}',
          );
        },
        loading: () => const _CardContentLoading(),
        error: (_, __) => const _CardContentError(),
      ),
    );
  }
}

/// Card for emergency fund section.
class _EmergencyFundCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(emergencyFundSettingsProvider);

    return _FinanceCard(
      icon: Icons.shield_outlined,
      iconColor: Colors.green,
      title: 'Fonds d\'urgence',
      onTap: () => context.push('/settings'),
      child: Builder(
        builder: (context) {
          if (!settings.isEnabled) {
            return _CardContent(
              mainText: 'Non configuré',
              subText: 'Configure ton fonds d\'urgence',
              actionText: 'Configurer',
              onAction: () => context.push('/settings'),
            );
          }

          final target = settings.monthlySalary * settings.targetMonths;
          final progress = target > 0 ? settings.currentSavings / target : 0.0;

          return _CardContent(
            mainText: FcfaFormatter.format(settings.currentSavings),
            subText: 'Objectif: ${settings.targetMonths} mois de salaire',
            progress: progress.clamp(0.0, 1.0),
            progressLabel: '${(progress * 100).round()}% atteint',
          );
        },
      ),
    );
  }
}

/// Reusable finance card container.
class _FinanceCard extends StatelessWidget {
  const _FinanceCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Content
            child,
          ],
        ),
      ),
    );
  }
}

/// Card content widget.
class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.mainText,
    required this.subText,
    this.progress,
    this.progressLabel,
    this.actionText,
    this.onAction,
  });

  final String mainText;
  final String subText;
  final double? progress;
  final String? progressLabel;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mainText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subText,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (progress != null) ...[
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress!,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.success],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          if (progressLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              progressLabel!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(actionText!),
          ),
        ],
      ],
    );
  }
}

/// Loading state for card content.
class _CardContentLoading extends StatelessWidget {
  const _CardContentLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Error state for card content.
class _CardContentError extends StatelessWidget {
  const _CardContentError();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Erreur de chargement',
      style: TextStyle(
        fontSize: 13,
        color: AppColors.error,
      ),
    );
  }
}
