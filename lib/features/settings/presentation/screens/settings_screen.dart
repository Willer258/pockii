import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../budget/data/repositories/budget_period_repository.dart';
import '../../../planned_expenses/presentation/providers/planned_expenses_list_provider.dart';
import '../../../subscriptions/presentation/providers/subscriptions_list_provider.dart'
    show activeSubscriptionsProvider, totalMonthlyAmountProvider;
import '../dialogs/budget_edit_dialog.dart';

/// Settings screen for budget configuration and navigation.
///
/// Shows sections:
/// - Budget mensuel with current amount and edit action
/// - Abonnements with count and total amount
/// - Dépenses prévues with pending count
/// - À propos with app version info
///
/// Covers: FR42 (modify budget), FR43 (budget recalculation), UX-15
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Budget Section
          _BudgetSection(),
          const SizedBox(height: AppSpacing.lg),

          // Subscriptions Section
          _SubscriptionsSection(),
          const SizedBox(height: AppSpacing.lg),

          // Planned Expenses Section
          _PlannedExpensesSection(),
          const SizedBox(height: AppSpacing.lg),

          // Notifications Section
          _NotificationsSection(),
          const SizedBox(height: AppSpacing.lg),

          // About Section
          _AboutSection(),
        ],
      ),
    );
  }
}

/// Budget section showing current monthly budget with edit option.
class _BudgetSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodAsync = ref.watch(_currentPeriodProvider);

    return _SettingsSection(
      title: 'Budget mensuel',
      icon: Icons.account_balance_wallet_outlined,
      child: periodAsync.when(
        data: (period) {
          final budget = period.monthlyBudgetFcfa;
          return _SettingsTile(
            title: FcfaFormatter.format(budget),
            subtitle: 'Budget pour ce mois',
            trailing: TextButton(
              onPressed: () => _showBudgetEditDialog(context, ref, budget),
              child: const Text('Modifier'),
            ),
          );
        },
        loading: () => const _SettingsTile(
          title: 'Chargement...',
          subtitle: 'Budget pour ce mois',
        ),
        error: (_, __) => const _SettingsTile(
          title: 'Erreur',
          subtitle: 'Impossible de charger le budget',
        ),
      ),
    );
  }

  Future<void> _showBudgetEditDialog(
    BuildContext context,
    WidgetRef ref,
    int currentBudget,
  ) async {
    final newBudget = await BudgetEditDialog.show(context, currentBudget);

    if (newBudget != null && newBudget != currentBudget) {
      final repository = ref.read(budgetPeriodRepositoryProvider);
      final period = await repository.getCurrentPeriod();

      if (period != null) {
        await repository.updatePeriodBudget(period.id, newBudget);
        // Invalidate to refresh the UI
        ref.invalidate(_currentPeriodProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget mis à jour')),
          );
        }
      }
    }
  }
}

/// Subscriptions section showing count and total with navigation.
class _SubscriptionsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(activeSubscriptionsProvider);
    final totalAsync = ref.watch(totalMonthlyAmountProvider);

    return _SettingsSection(
      title: 'Abonnements',
      icon: Icons.repeat_outlined,
      child: subscriptionsAsync.when(
        data: (subscriptions) {
          final count = subscriptions.length;
          final total = totalAsync.maybeWhen(
            data: (int t) => t,
            orElse: () => 0,
          );
          return _SettingsTile(
            title: '$count abonnement${count != 1 ? 's' : ''}',
            subtitle: 'Total mensuel: ${FcfaFormatter.format(total)}',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/subscriptions'),
          );
        },
        loading: () => const _SettingsTile(
          title: 'Chargement...',
          subtitle: 'Total mensuel: --',
        ),
        error: (_, __) => const _SettingsTile(
          title: 'Erreur',
          subtitle: 'Impossible de charger',
        ),
      ),
    );
  }
}

/// Planned expenses section showing pending count with navigation.
class _PlannedExpensesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(pendingPlannedExpensesProvider);
    final totalAsync = ref.watch(totalPendingAmountProvider);

    return _SettingsSection(
      title: 'Dépenses prévues',
      icon: Icons.event_note_outlined,
      child: expensesAsync.when(
        data: (expenses) {
          final count = expenses.length;
          final total = totalAsync.maybeWhen(
            data: (int t) => t,
            orElse: () => 0,
          );
          return _SettingsTile(
            title: '$count dépense${count != 1 ? 's' : ''} en attente',
            subtitle: 'Total: ${FcfaFormatter.format(total)}',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/planned-expenses'),
          );
        },
        loading: () => const _SettingsTile(
          title: 'Chargement...',
          subtitle: 'Total: --',
        ),
        error: (_, __) => const _SettingsTile(
          title: 'Erreur',
          subtitle: 'Impossible de charger',
        ),
      ),
    );
  }
}

/// Notifications section with link to preferences.
class _NotificationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      child: _SettingsTile(
        title: 'Préférences',
        subtitle: 'Gérer les alertes et rappels',
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/settings/notifications'),
      ),
    );
  }
}

/// About section with app information.
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _SettingsSection(
      title: 'À propos',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _SettingsTile(
            title: 'accountapp',
            subtitle: 'Version 1.0.0',
          ),
          Divider(height: 1),
          _SettingsTile(
            title: 'Gestion de budget',
            subtitle: 'Simple et efficace',
          ),
        ],
      ),
    );
  }
}

/// Reusable settings section container.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant,
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// Reusable settings tile.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Provider for current budget period.
final _currentPeriodProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(budgetPeriodRepositoryProvider);
  return repository.ensureCurrentPeriodExists();
});
