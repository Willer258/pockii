import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

/// Data Access Object for transactions.
///
/// Provides CRUD operations and filtered queries for the transactions table.
/// All monetary values are handled as integers (FCFA, ARCH-7).
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // ============== CRUD OPERATIONS ==============

  /// Creates a new transaction and returns its ID.
  Future<int> createTransaction(TransactionsCompanion transaction) {
    return into(transactions).insert(transaction);
  }

  /// Gets a specific transaction by ID.
  Future<Transaction?> getTransactionById(int id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all transactions ordered by date descending (most recent first).
  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Updates an existing transaction.
  ///
  /// Returns true if the update was successful.
  Future<bool> updateTransaction(Transaction transaction) {
    return update(transactions).replace(transaction);
  }

  /// Deletes a transaction by ID.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  // ============== FILTERED QUERIES ==============

  /// Gets transactions within a date range (inclusive).
  ///
  /// [start] and [end] should be provided by clockProvider for testability.
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return (select(transactions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerOrEqualValue(end),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gets transactions filtered by category.
  Future<List<Transaction>> getTransactionsByCategory(String category) {
    return (select(transactions)
          ..where((t) => t.category.equals(category))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gets transactions filtered by type ('expense' or 'income').
  Future<List<Transaction>> getTransactionsByType(String type) {
    return (select(transactions)
          ..where((t) => t.type.equals(type))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gets transactions for the current month based on the provided date.
  ///
  /// [now] should come from clockProvider for testability (ARCH-6).
  Future<List<Transaction>> getTransactionsForCurrentMonth(DateTime now) {
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  /// Calculates the sum of transaction amounts for a specific type.
  ///
  /// Useful for budget calculations.
  Future<int> getSumByType(String type) async {
    final result = await (selectOnly(transactions)
          ..addColumns([transactions.amountFcfa.sum()])
          ..where(transactions.type.equals(type)))
        .getSingleOrNull();

    return result?.read(transactions.amountFcfa.sum()) ?? 0;
  }

  /// Calculates the sum of expenses for the current month.
  Future<int> getExpensesSumForMonth(DateTime now) async {
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final result = await (selectOnly(transactions)
          ..addColumns([transactions.amountFcfa.sum()])
          ..where(
            transactions.type.equals('expense') &
                transactions.date.isBiggerOrEqualValue(startOfMonth) &
                transactions.date.isSmallerOrEqualValue(endOfMonth),
          ))
        .getSingleOrNull();

    return result?.read(transactions.amountFcfa.sum()) ?? 0;
  }

  /// Calculates the sum of income for the current month.
  Future<int> getIncomeSumForMonth(DateTime now) async {
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final result = await (selectOnly(transactions)
          ..addColumns([transactions.amountFcfa.sum()])
          ..where(
            transactions.type.equals('income') &
                transactions.date.isBiggerOrEqualValue(startOfMonth) &
                transactions.date.isSmallerOrEqualValue(endOfMonth),
          ))
        .getSingleOrNull();

    return result?.read(transactions.amountFcfa.sum()) ?? 0;
  }

  /// Gets the first (oldest) transaction by date.
  ///
  /// Used to determine how long the user has been tracking expenses
  /// for pattern unlock logic (FR18).
  Future<Transaction?> getFirstTransaction() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all transactions for reactive updates.
  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Watches transactions for a specific month.
  ///
  /// [month] is any DateTime within the target month.
  Stream<List<Transaction>> watchTransactionsForMonth(DateTime month) {
    final startOfMonth = DateTime(month.year, month.month);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    return (select(transactions)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(startOfMonth) &
                t.date.isSmallerOrEqualValue(endOfMonth),
          )
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
