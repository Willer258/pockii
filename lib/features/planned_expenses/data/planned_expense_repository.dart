import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/planned_expenses_dao.dart';
import 'package:accountapp/core/database/database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/planned_expense_model.dart';
import '../domain/models/planned_expense_status.dart';

/// Repository that abstracts PlannedExpensesDao for the presentation layer.
///
/// Handles mapping between domain models (PlannedExpenseModel) and data layer
/// entities (PlannedExpense from drift).
/// Uses Riverpod provider pattern (ARCH-4).
class PlannedExpenseRepository {
  /// Creates a PlannedExpenseRepository with the given DAO.
  PlannedExpenseRepository(this._dao);

  final PlannedExpensesDao _dao;

  // ============== CRUD OPERATIONS ==============

  /// Creates a new planned expense and returns its ID.
  Future<int> createPlannedExpense({
    required String description,
    required int amountFcfa,
    required DateTime expectedDate,
    String? category,
  }) async {
    final companion = PlannedExpensesCompanion.insert(
      description: description,
      amountFcfa: amountFcfa,
      expectedDate: expectedDate,
      category: Value(category),
    );
    return _dao.createPlannedExpense(companion);
  }

  /// Creates a new planned expense from a domain model and returns its ID.
  Future<int> createPlannedExpenseFromModel(PlannedExpenseModel expense) {
    return _dao.createPlannedExpense(expense.toCompanion());
  }

  /// Gets a specific planned expense by ID.
  Future<PlannedExpenseModel?> getPlannedExpenseById(int id) async {
    final entity = await _dao.getPlannedExpenseById(id);
    return entity != null ? PlannedExpenseModel.fromEntity(entity) : null;
  }

  /// Gets all planned expenses ordered by expected date.
  Future<List<PlannedExpenseModel>> getAllPlannedExpenses() async {
    final entities = await _dao.getAllPlannedExpenses();
    return entities.map(PlannedExpenseModel.fromEntity).toList();
  }

  /// Updates an existing planned expense.
  Future<bool> updatePlannedExpense(PlannedExpenseModel expense) async {
    return _dao.updatePlannedExpense(expense.toEntity());
  }

  /// Deletes a planned expense by ID.
  Future<int> deletePlannedExpense(int id) {
    return _dao.deletePlannedExpense(id);
  }

  // ============== FILTERED QUERIES ==============

  /// Gets all pending planned expenses (not yet paid or cancelled).
  Future<List<PlannedExpenseModel>> getPendingPlannedExpenses() async {
    final entities = await _dao.getPendingPlannedExpenses();
    return entities.map(PlannedExpenseModel.fromEntity).toList();
  }

  /// Gets planned expenses for a specific month.
  Future<List<PlannedExpenseModel>> getPlannedExpensesForMonth(
    DateTime month,
  ) async {
    final entities = await _dao.getPlannedExpensesForMonth(month);
    return entities.map(PlannedExpenseModel.fromEntity).toList();
  }

  /// Gets pending planned expenses for a specific month.
  Future<List<PlannedExpenseModel>> getPendingPlannedExpensesForMonth(
    DateTime month,
  ) async {
    final entities = await _dao.getPendingPlannedExpensesForMonth(month);
    return entities.map(PlannedExpenseModel.fromEntity).toList();
  }

  /// Gets planned expenses by status.
  Future<List<PlannedExpenseModel>> getPlannedExpensesByStatus(
    PlannedExpenseStatus status,
  ) async {
    final entities = await _dao.getPlannedExpensesByStatus(status.toDbValue());
    return entities.map(PlannedExpenseModel.fromEntity).toList();
  }

  // ============== AGGREGATE QUERIES ==============

  /// Calculates the total amount for all pending planned expenses.
  Future<int> getTotalPendingAmount() {
    return _dao.getTotalPendingAmount();
  }

  /// Calculates the total amount for pending planned expenses in a specific month.
  Future<int> getTotalPendingAmountForMonth(DateTime month) {
    return _dao.getTotalPendingAmountForMonth(month);
  }

  /// Counts pending planned expenses.
  Future<int> getPendingPlannedExpenseCount() {
    return _dao.getPendingPlannedExpenseCount();
  }

  // ============== STATUS UPDATES ==============

  /// Marks a planned expense as converted (paid).
  ///
  /// Returns true if the update was successful.
  Future<bool> markAsConverted(int id) {
    return _dao.markAsConverted(id);
  }

  /// Marks a planned expense as cancelled.
  ///
  /// Returns true if the update was successful.
  Future<bool> markAsCancelled(int id) {
    return _dao.markAsCancelled(id);
  }

  /// Marks a planned expense as postponed.
  ///
  /// Returns true if the update was successful.
  Future<bool> markAsPostponed(int id) {
    return _dao.markAsPostponed(id);
  }

  /// Marks a planned expense as pending (reactivate from postponed).
  ///
  /// Returns true if the update was successful.
  Future<bool> markAsPending(int id) {
    return _dao.markAsPending(id);
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all planned expenses for reactive updates.
  Stream<List<PlannedExpenseModel>> watchAllPlannedExpenses() {
    return _dao.watchAllPlannedExpenses().map(
          (entities) => entities.map(PlannedExpenseModel.fromEntity).toList(),
        );
  }

  /// Watches pending planned expenses for reactive updates.
  Stream<List<PlannedExpenseModel>> watchPendingPlannedExpenses() {
    return _dao.watchPendingPlannedExpenses().map(
          (entities) => entities.map(PlannedExpenseModel.fromEntity).toList(),
        );
  }
}

/// Provider for PlannedExpenseRepository.
///
/// Uses Riverpod provider pattern (ARCH-4).
final plannedExpenseRepositoryProvider = Provider<PlannedExpenseRepository>((ref) {
  final dao = ref.watch(plannedExpensesDaoProvider);
  return PlannedExpenseRepository(dao);
});
