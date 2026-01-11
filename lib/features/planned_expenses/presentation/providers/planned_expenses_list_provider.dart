import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/planned_expense_repository.dart';
import '../../domain/models/planned_expense_model.dart';

/// State for the planned expenses list screen.
class PlannedExpensesListState {
  const PlannedExpensesListState({
    this.showCompleted = false,
  });

  /// Whether to show completed (converted/cancelled) expenses.
  final bool showCompleted;

  PlannedExpensesListState copyWith({
    bool? showCompleted,
  }) {
    return PlannedExpensesListState(
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }
}

/// Notifier for managing planned expenses list state.
class PlannedExpensesListNotifier extends StateNotifier<PlannedExpensesListState> {
  PlannedExpensesListNotifier() : super(const PlannedExpensesListState());

  /// Toggles the visibility of completed expenses.
  void toggleShowCompleted() {
    state = state.copyWith(showCompleted: !state.showCompleted);
  }

  /// Sets whether to show completed expenses.
  void setShowCompleted({required bool value}) {
    state = state.copyWith(showCompleted: value);
  }
}

/// Provider for the planned expenses list state.
final plannedExpensesListStateProvider =
    StateNotifierProvider<PlannedExpensesListNotifier, PlannedExpensesListState>(
  (ref) => PlannedExpensesListNotifier(),
);

/// Provider that streams all planned expenses.
final allPlannedExpensesProvider =
    StreamProvider<List<PlannedExpenseModel>>((ref) {
  final repository = ref.watch(plannedExpenseRepositoryProvider);
  return repository.watchAllPlannedExpenses();
});

/// Provider that streams pending planned expenses only.
final pendingPlannedExpensesProvider =
    StreamProvider<List<PlannedExpenseModel>>((ref) {
  final repository = ref.watch(plannedExpenseRepositoryProvider);
  return repository.watchPendingPlannedExpenses();
});

/// Provider for total pending amount.
final totalPendingAmountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(plannedExpenseRepositoryProvider);
  return repository.getTotalPendingAmount();
});

/// Provider for pending planned expense count.
final pendingPlannedExpenseCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(plannedExpenseRepositoryProvider);
  return repository.getPendingPlannedExpenseCount();
});

/// Provider that filters planned expenses based on showCompleted setting.
final filteredPlannedExpensesProvider =
    Provider<AsyncValue<List<PlannedExpenseModel>>>((ref) {
  final listState = ref.watch(plannedExpensesListStateProvider);

  if (listState.showCompleted) {
    return ref.watch(allPlannedExpensesProvider);
  } else {
    return ref.watch(pendingPlannedExpensesProvider);
  }
});
