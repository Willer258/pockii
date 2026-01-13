import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/simulation_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../budget/data/repositories/budget_period_repository.dart';
import '../../../budget_rules/presentation/providers/budget_rules_provider.dart';
import '../../../budget_rules/presentation/widgets/budget_allocation_card.dart';
import '../../../home/presentation/providers/budget_provider.dart';
import '../../../home/presentation/widgets/budget_animation/budget_animation_widget.dart';
import '../../../tutorials/presentation/widgets/tutorial_bottom_sheet.dart';
import '../../../tutorials/tutorial_content.dart';
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

          // Appearance Section
          _AppearanceSection(),
          const SizedBox(height: AppSpacing.lg),

          // Budget Rules Section (50/30/20)
          _BudgetRulesSection(),
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
        // Refresh the budget state on home screen
        await ref.read(budgetStateProvider.notifier).refresh();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Budget mis à jour')),
          );
        }
      }
    }
  }
}

/// Appearance section with animation style selector.
class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'Apparence',
      icon: Icons.palette_outlined,
      child: const BudgetAnimationSelector(),
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

/// About section with app information and simulation button.
class _AboutSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends ConsumerState<_AboutSection> {
  bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsSection(
      title: 'À propos',
      icon: Icons.info_outline,
      child: Column(
        children: [
          const _SettingsTile(
            title: 'Pockii',
            subtitle: 'Version 1.0.0',
          ),
          const Divider(height: 1),
          const _SettingsTile(
            title: 'Ton budget, simplifié',
            subtitle: 'Gestion de budget simple et efficace',
          ),
          // Simulation only in debug mode
          if (kDebugMode) ...[
            const Divider(height: 1),
            _SettingsTile(
              title: 'Simulation 3 mois',
              subtitle: 'Générer des données de démonstration',
              trailing: _isSimulating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.science_outlined),
              onTap: _isSimulating ? null : _runSimulation,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _runSimulation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulation'),
        content: const Text(
          'Cette action va supprimer toutes les données existantes et les remplacer par des données de simulation sur 3 mois.\n\nContinuer?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simuler'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSimulating = true;
    });

    try {
      final service = ref.read(simulationServiceProvider);
      await service.runSimulation();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simulation terminée! Redémarrage recommandé.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSimulating = false;
        });
      }
    }
  }
}

/// Reusable settings section container.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
    this.action,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? action;

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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (action != null) action!,
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

/// Budget Rules section (50/30/20 rule).
class _BudgetRulesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(budgetRuleSettingsProvider);

    return _SettingsSection(
      title: 'Règle 50/30/20',
      icon: Icons.pie_chart_outline,
      action: TutorialHelpButton(tutorial: TutorialContent.rule503020, size: 18),
      child: Column(
        children: [
          _SettingsTile(
            title: settings.isEnabled ? 'Activée' : 'Désactivée',
            subtitle: 'Répartir ton budget: Besoins, Envies, Épargne',
            trailing: Switch(
              value: settings.isEnabled,
              onChanged: (_) {
                ref.read(budgetRuleSettingsProvider.notifier).toggleEnabled();
              },
              activeColor: AppColors.primary,
            ),
          ),
          if (settings.isEnabled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const BudgetAllocationPreview(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${settings.needsPercentage}% Besoins • ${settings.wantsPercentage}% Envies • ${settings.savingsPercentage}% Épargne',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Provider for current budget period.
final _currentPeriodProvider = FutureProvider.autoDispose((ref) {
  final repository = ref.watch(budgetPeriodRepositoryProvider);
  return repository.ensureCurrentPeriodExists();
});
