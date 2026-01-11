import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/clock_service.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../budget/domain/services/budget_calculation_service.dart';
import '../../domain/models/budget_state.dart';

/// Provider for the current budget state.
///
/// Uses BudgetCalculationService to get real budget data from the database.
final budgetStateProvider = StateNotifierProvider<BudgetStateNotifier, BudgetState>(
  (ref) {
    final calculationService = ref.watch(budgetCalculationServiceProvider);
    return BudgetStateNotifier(calculationService);
  },
);

/// Notifier for budget state management.
class BudgetStateNotifier extends StateNotifier<BudgetState> {
  BudgetStateNotifier(this._calculationService) : super(BudgetState.initial()) {
    _loadBudget();
  }

  final BudgetCalculationService _calculationService;

  Future<void> _loadBudget() async {
    try {
      final result = await _calculationService.calculateRemainingBudget();

      state = BudgetState(
        totalBudget: result.totalBudget,
        remainingBudget: result.remainingBudget,
        periodStart: result.periodStart,
        periodEnd: result.periodEnd,
        hasTimeInconsistency: result.hasTimeInconsistency,
      );
    } on Exception catch (e) {
      state = BudgetState.withError(e.toString());
    }
  }

  /// Refresh budget data from the database
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadBudget();
  }

  /// Update remaining budget (called after transaction)
  void updateRemaining(int newRemaining) {
    state = state.copyWith(remainingBudget: newRemaining);
  }

  /// Acknowledge and dismiss time inconsistency warning
  void acknowledgeTimeWarning() {
    _calculationService.resetTimeInconsistencyDetection();
    state = state.copyWith(hasTimeInconsistency: false);
  }
}

/// Provider for formatted budget amount string.
///
/// Returns the remaining budget formatted with FCFA formatter.
/// Example: "215 000 FCFA"
final formattedBudgetProvider = Provider<String>((ref) {
  final budgetState = ref.watch(budgetStateProvider);

  if (budgetState.isLoading) {
    return '---';
  }

  if (budgetState.hasError) {
    return 'Erreur';
  }

  return FcfaFormatter.format(budgetState.remainingBudget);
});

/// Provider for formatted budget amount without currency suffix.
///
/// Returns just the number formatted.
/// Example: "215 000"
final formattedBudgetNumberProvider = Provider<String>((ref) {
  final budgetState = ref.watch(budgetStateProvider);

  if (budgetState.isLoading) {
    return '---';
  }

  if (budgetState.hasError) {
    return '---';
  }

  return FcfaFormatter.formatCompact(budgetState.remainingBudget);
});

/// Provider for current month label in French.
///
/// Returns capitalized month name with year.
/// Example: "Janvier 2026"
final currentMonthLabelProvider = Provider<String>((ref) {
  final clock = ref.watch(clockProvider);
  final now = clock.now();

  // Format as "MMMM yyyy" in French
  final formatter = DateFormat('MMMM yyyy', 'fr_FR');
  final formatted = formatter.format(now);

  // Capitalize first letter
  if (formatted.isEmpty) return formatted;
  return formatted[0].toUpperCase() + formatted.substring(1);
});

/// Provider for budget percentage (0.0 to 1.0).
final budgetPercentageProvider = Provider<double>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  return budgetState.percentageRemaining.clamp(0.0, 1.0);
});

/// Provider for budget status.
final budgetStatusProvider = Provider<BudgetStatus>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  return budgetState.status;
});

/// Provider for time inconsistency warning state.
final hasTimeInconsistencyProvider = Provider<bool>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  return budgetState.hasTimeInconsistency;
});
