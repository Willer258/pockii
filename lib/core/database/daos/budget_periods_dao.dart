import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/budget_periods_table.dart';

part 'budget_periods_dao.g.dart';

/// Data Access Object for budget periods.
///
/// Provides CRUD operations for the budget_periods table.
@DriftAccessor(tables: [BudgetPeriods])
class BudgetPeriodsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetPeriodsDaoMixin {
  BudgetPeriodsDao(super.db);

  /// Gets all budget periods ordered by start date descending (most recent first).
  Future<List<BudgetPeriod>> getAllBudgetPeriods() {
    return (select(budgetPeriods)
          ..orderBy([
            (t) => OrderingTerm(expression: t.startDate, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// Gets a specific budget period by ID.
  Future<BudgetPeriod?> getBudgetPeriodById(int id) {
    return (select(budgetPeriods)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets the current active budget period based on the provided date.
  ///
  /// Returns the budget period where [date] falls between startDate and endDate.
  /// If multiple periods exist (edge case), returns the most recently created one.
  /// Uses id DESC as secondary sort for deterministic behavior when createdAt is identical.
  Future<BudgetPeriod?> getCurrentBudgetPeriod(DateTime date) async {
    final periods = await (select(budgetPeriods)
          ..where(
            (t) =>
                t.startDate.isSmallerOrEqualValue(date) &
                t.endDate.isBiggerOrEqualValue(date),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .get();
    return periods.isEmpty ? null : periods.first;
  }

  /// Creates a new budget period.
  ///
  /// Returns the ID of the inserted record.
  Future<int> createBudgetPeriod(BudgetPeriodsCompanion period) {
    return into(budgetPeriods).insert(period);
  }

  /// Updates an existing budget period.
  ///
  /// Returns true if the update was successful.
  Future<bool> updateBudgetPeriod(BudgetPeriod period) {
    return update(budgetPeriods).replace(period);
  }

  /// Deletes a budget period by ID.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteBudgetPeriod(int id) {
    return (delete(budgetPeriods)..where((t) => t.id.equals(id))).go();
  }

  /// Watches all budget periods for reactive updates.
  Stream<List<BudgetPeriod>> watchAllBudgetPeriods() {
    return (select(budgetPeriods)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.startDate, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Watches the current budget period for reactive updates.
  Stream<BudgetPeriod?> watchCurrentBudgetPeriod(DateTime date) {
    return (select(budgetPeriods)
          ..where(
            (t) => t.startDate.isSmallerOrEqualValue(date) &
                t.endDate.isBiggerOrEqualValue(date),
          ))
        .watchSingleOrNull();
  }
}
