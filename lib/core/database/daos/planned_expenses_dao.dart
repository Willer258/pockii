import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/planned_expenses_table.dart';

part 'planned_expenses_dao.g.dart';

/// Data Access Object for planned expenses.
///
/// Provides CRUD operations and filtered queries for the planned_expenses table.
/// All monetary values are handled as integers (FCFA, ARCH-7).
@DriftAccessor(tables: [PlannedExpenses])
class PlannedExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$PlannedExpensesDaoMixin {
  PlannedExpensesDao(super.db);

  // ============== CRUD OPERATIONS ==============

  /// Creates a new planned expense and returns its ID.
  Future<int> createPlannedExpense(PlannedExpensesCompanion expense) {
    return into(plannedExpenses).insert(expense);
  }

  /// Gets a specific planned expense by ID.
  Future<PlannedExpense?> getPlannedExpenseById(int id) {
    return (select(plannedExpenses)..where((e) => e.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all planned expenses ordered by expected date.
  Future<List<PlannedExpense>> getAllPlannedExpenses() {
    return (select(plannedExpenses)
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Updates an existing planned expense.
  ///
  /// Returns true if the update was successful.
  Future<bool> updatePlannedExpense(PlannedExpense expense) {
    return update(plannedExpenses).replace(expense);
  }

  /// Deletes a planned expense by ID.
  ///
  /// Returns the number of deleted rows.
  Future<int> deletePlannedExpense(int id) {
    return (delete(plannedExpenses)..where((e) => e.id.equals(id))).go();
  }

  // ============== FILTERED QUERIES ==============

  /// Gets all pending planned expenses (not yet paid or cancelled).
  Future<List<PlannedExpense>> getPendingPlannedExpenses() {
    return (select(plannedExpenses)
          ..where((e) => e.status.equals('pending'))
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets planned expenses for a specific month.
  Future<List<PlannedExpense>> getPlannedExpensesForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1);

    return (select(plannedExpenses)
          ..where((e) =>
              e.expectedDate.isBiggerOrEqualValue(startOfMonth) &
              e.expectedDate.isSmallerThanValue(endOfMonth))
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets pending planned expenses for a specific month.
  Future<List<PlannedExpense>> getPendingPlannedExpensesForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1);

    return (select(plannedExpenses)
          ..where((e) =>
              e.status.equals('pending') &
              e.expectedDate.isBiggerOrEqualValue(startOfMonth) &
              e.expectedDate.isSmallerThanValue(endOfMonth))
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets planned expenses by status.
  Future<List<PlannedExpense>> getPlannedExpensesByStatus(String status) {
    return (select(plannedExpenses)
          ..where((e) => e.status.equals(status))
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // ============== AGGREGATE QUERIES ==============

  /// Calculates the total amount for all pending planned expenses.
  Future<int> getTotalPendingAmount() async {
    final pending = await getPendingPlannedExpenses();
    var total = 0;
    for (final expense in pending) {
      total += expense.amountFcfa;
    }
    return total;
  }

  /// Calculates the total amount for pending planned expenses in a specific month.
  Future<int> getTotalPendingAmountForMonth(DateTime month) async {
    final pending = await getPendingPlannedExpensesForMonth(month);
    var total = 0;
    for (final expense in pending) {
      total += expense.amountFcfa;
    }
    return total;
  }

  /// Counts pending planned expenses.
  Future<int> getPendingPlannedExpenseCount() async {
    final result = await (selectOnly(plannedExpenses)
          ..addColumns([plannedExpenses.id.count()])
          ..where(plannedExpenses.status.equals('pending')))
        .getSingleOrNull();

    return result?.read(plannedExpenses.id.count()) ?? 0;
  }

  // ============== STATUS UPDATES ==============

  /// Marks a planned expense as converted (paid).
  Future<bool> markAsConverted(int id) async {
    final existing = await getPlannedExpenseById(id);
    if (existing == null) return false;

    final updated = PlannedExpense(
      id: existing.id,
      description: existing.description,
      amountFcfa: existing.amountFcfa,
      expectedDate: existing.expectedDate,
      status: 'converted',
      category: existing.category,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return updatePlannedExpense(updated);
  }

  /// Marks a planned expense as cancelled.
  Future<bool> markAsCancelled(int id) async {
    final existing = await getPlannedExpenseById(id);
    if (existing == null) return false;

    final updated = PlannedExpense(
      id: existing.id,
      description: existing.description,
      amountFcfa: existing.amountFcfa,
      expectedDate: existing.expectedDate,
      status: 'cancelled',
      category: existing.category,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return updatePlannedExpense(updated);
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all planned expenses for reactive updates.
  Stream<List<PlannedExpense>> watchAllPlannedExpenses() {
    return (select(plannedExpenses)
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// Watches pending planned expenses for reactive updates.
  Stream<List<PlannedExpense>> watchPendingPlannedExpenses() {
    return (select(plannedExpenses)
          ..where((e) => e.status.equals('pending'))
          ..orderBy([
            (e) => OrderingTerm(expression: e.expectedDate, mode: OrderingMode.asc),
          ]))
        .watch();
  }
}
