import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../home/presentation/providers/budget_provider.dart';
import '../../data/savings_project_repository.dart';
import '../enums/contribution_type.dart';
import '../models/savings_project_model.dart';

/// Result of processing an auto-contribution.
class AutoContributionResult {
  const AutoContributionResult({
    required this.project,
    required this.success,
    this.amountContributed = 0,
    this.reason,
  });

  final SavingsProjectModel project;
  final bool success;
  final int amountContributed;
  final String? reason;
}

/// Service for handling automatic contributions to savings projects.
class AutoContributionService {
  AutoContributionService({
    required this.repository,
    required this.clock,
    required this.notificationService,
    required this.getBudgetRemaining,
  });

  final SavingsProjectRepository repository;
  final Clock clock;
  final NotificationService notificationService;
  final int Function() getBudgetRemaining;

  /// Process all due auto-contributions.
  ///
  /// Returns a list of results for each processed project.
  Future<List<AutoContributionResult>> processDueContributions() async {
    final now = clock.now();
    final dueProjects = await repository.getProjectsWithDueAutoContribution(now);
    final results = <AutoContributionResult>[];

    for (final project in dueProjects) {
      final result = await _processAutoContribution(project);
      results.add(result);
    }

    return results;
  }

  /// Process a single project's auto-contribution.
  Future<AutoContributionResult> _processAutoContribution(
    SavingsProjectModel project,
  ) async {
    final now = clock.now();
    final amount = project.autoContributionAmountFcfa;
    final budgetRemaining = getBudgetRemaining();

    // Check if project is already complete
    if (project.isGoalReached) {
      // Disable auto-contribution
      await repository.configureAutoContribution(
        projectId: project.id,
        enabled: false,
        amountFcfa: 0,
        frequency: project.autoContributionFrequency!,
      );
      return AutoContributionResult(
        project: project,
        success: false,
        reason: 'Objectif atteint',
      );
    }

    // Check if budget is sufficient
    if (budgetRemaining < amount) {
      // Record failed contribution
      await repository.recordFailedAutoContribution(
        projectId: project.id,
        amountFcfa: amount,
        reason: 'Budget insuffisant (${budgetRemaining} FCFA disponible)',
      );

      // Send notification
      await _sendFailedNotification(project, amount, budgetRemaining);

      // Update next contribution date
      final nextDate = project.autoContributionFrequency!.nextDateFrom(now);
      await repository.updateNextContributionDate(project.id, nextDate);

      return AutoContributionResult(
        project: project,
        success: false,
        reason: 'Budget insuffisant',
      );
    }

    // Process the contribution
    await repository.addAutoDeposit(
      projectId: project.id,
      amountFcfa: amount,
    );

    // Update next contribution date
    final nextDate = project.autoContributionFrequency!.nextDateFrom(now);
    await repository.updateNextContributionDate(project.id, nextDate);

    // Send success notification
    await _sendSuccessNotification(project, amount);

    return AutoContributionResult(
      project: project,
      success: true,
      amountContributed: amount,
    );
  }

  Future<void> _sendSuccessNotification(
    SavingsProjectModel project,
    int amount,
  ) async {
    await notificationService.showGenericNotification(
      title: 'Cotisation automatique',
      body: '${_formatAmount(amount)} ajoutés à "${project.name}"',
      payload: 'project:${project.id}',
    );
  }

  Future<void> _sendFailedNotification(
    SavingsProjectModel project,
    int amount,
    int available,
  ) async {
    await notificationService.showGenericNotification(
      title: 'Cotisation impossible',
      body: 'Budget insuffisant pour "${project.name}" (${_formatAmount(amount)} requis, ${_formatAmount(available)} disponible)',
      payload: 'project:${project.id}',
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

/// Provider for AutoContributionService.
final autoContributionServiceProvider = Provider<AutoContributionService>((ref) {
  final repository = ref.watch(savingsProjectRepositoryProvider);
  final clock = ref.watch(clockProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final budgetState = ref.watch(budgetStateProvider);

  return AutoContributionService(
    repository: repository,
    clock: clock,
    notificationService: notificationService,
    getBudgetRemaining: () => budgetState.remainingBudget,
  );
});

/// Provider to run auto-contributions check.
final runAutoContributionsProvider = FutureProvider<List<AutoContributionResult>>((ref) async {
  final service = ref.watch(autoContributionServiceProvider);
  return service.processDueContributions();
});
