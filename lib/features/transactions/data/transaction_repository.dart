import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/transactions_dao.dart';
import 'package:pockii/core/database/database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/transaction_model.dart';
import '../domain/models/transaction_type.dart';

/// Repository that abstracts TransactionsDao for the presentation layer.
///
/// Handles mapping between domain models (TransactionModel) and data layer
/// entities (Transaction from drift).
/// Uses Riverpod provider pattern (ARCH-4).
class TransactionRepository {
  /// Creates a TransactionRepository with the given DAO.
  TransactionRepository(this._dao);

  final TransactionsDao _dao;

  // ============== CRUD OPERATIONS ==============

  /// Creates a new transaction from a domain model and returns its ID.
  Future<int> createTransactionFromModel(TransactionModel transaction) async {
    final companion = TransactionsCompanion.insert(
      amountFcfa: transaction.amountFcfa,
      category: transaction.category,
      type: transaction.type.toDbValue(),
      note: Value.absentIfNull(transaction.note),
      date: transaction.date,
    );
    return _dao.createTransaction(companion);
  }

  /// Creates a new transaction with the given parameters and returns its ID.
  ///
  /// This is a convenience method for creating transactions without needing
  /// to construct a TransactionModel first.
  Future<int> createTransaction({
    required int amountFcfa,
    required String category,
    required TransactionType type,
    required DateTime date,
    String? note,
  }) async {
    final companion = TransactionsCompanion.insert(
      amountFcfa: amountFcfa,
      category: category,
      type: type.toDbValue(),
      note: Value.absentIfNull(note),
      date: date,
    );
    return _dao.createTransaction(companion);
  }

  /// Gets a specific transaction by ID.
  Future<TransactionModel?> getTransactionById(int id) async {
    final entity = await _dao.getTransactionById(id);
    return entity != null ? TransactionModel.fromEntity(entity) : null;
  }

  /// Gets all transactions ordered by date descending.
  Future<List<TransactionModel>> getAllTransactions() async {
    final entities = await _dao.getAllTransactions();
    return entities.map(TransactionModel.fromEntity).toList();
  }

  /// Updates an existing transaction.
  Future<bool> updateTransaction(TransactionModel transaction) async {
    final entity = Transaction(
      id: transaction.id,
      amountFcfa: transaction.amountFcfa,
      category: transaction.category,
      type: transaction.type.toDbValue(),
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt,
    );
    return _dao.updateTransaction(entity);
  }

  /// Deletes a transaction by ID.
  Future<int> deleteTransaction(int id) {
    return _dao.deleteTransaction(id);
  }

  // ============== FILTERED QUERIES ==============

  /// Gets transactions within a date range.
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final entities = await _dao.getTransactionsByDateRange(start, end);
    return entities.map(TransactionModel.fromEntity).toList();
  }

  /// Gets transactions filtered by category.
  Future<List<TransactionModel>> getTransactionsByCategory(
    String category,
  ) async {
    final entities = await _dao.getTransactionsByCategory(category);
    return entities.map(TransactionModel.fromEntity).toList();
  }

  /// Gets transactions filtered by type.
  Future<List<TransactionModel>> getTransactionsByType(
    TransactionType type,
  ) async {
    final entities = await _dao.getTransactionsByType(type.toDbValue());
    return entities.map(TransactionModel.fromEntity).toList();
  }

  /// Gets transactions for the current month.
  Future<List<TransactionModel>> getTransactionsForCurrentMonth(
    DateTime now,
  ) async {
    final entities = await _dao.getTransactionsForCurrentMonth(now);
    return entities.map(TransactionModel.fromEntity).toList();
  }

  /// Gets the sum of expenses for the current month.
  Future<int> getExpensesSumForMonth(DateTime now) {
    return _dao.getExpensesSumForMonth(now);
  }

  /// Gets the sum of income for the current month.
  Future<int> getIncomeSumForMonth(DateTime now) {
    return _dao.getIncomeSumForMonth(now);
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all transactions for reactive updates.
  Stream<List<TransactionModel>> watchAllTransactions() {
    return _dao.watchAllTransactions().map(
          (entities) => entities.map(TransactionModel.fromEntity).toList(),
        );
  }

  /// Watches transactions for a specific month.
  Stream<List<TransactionModel>> watchTransactionsForMonth(DateTime month) {
    return _dao.watchTransactionsForMonth(month).map(
          (entities) => entities.map(TransactionModel.fromEntity).toList(),
        );
  }
}

/// Provider for TransactionRepository.
///
/// Uses Riverpod provider pattern (ARCH-4).
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dao = ref.watch(transactionsDaoProvider);
  return TransactionRepository(dao);
});
