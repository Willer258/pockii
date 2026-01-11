import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionsDao dao;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = TransactionsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionsDao', () {
    // ============== CRUD OPERATIONS ==============

    group('createTransaction', () {
      test('creates a transaction and returns ID', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        expect(id, greaterThan(0));
      });

      test('creates multiple transactions with unique IDs', () async {
        final id1 = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final id2 = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        expect(id1, isNot(equals(id2)));
      });

      test('creates transaction with optional note', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1500,
            category: 'food',
            type: 'expense',
            note: const Value('Déjeuner au restaurant'),
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.note, 'Déjeuner au restaurant');
      });

      test('creates transaction without note (null)', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1500,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.note, isNull);
      });

      test('stores FCFA amount as int correctly', () async {
        // Using realistic FCFA amounts
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 999999999, // Max edge case
            category: 'other',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.amountFcfa, 999999999);
      });
    });

    group('getTransactionById', () {
      test('returns transaction when found', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);

        expect(transaction, isNotNull);
        expect(transaction!.amountFcfa, 25000);
        expect(transaction.category, 'transport');
        expect(transaction.type, 'expense');
      });

      test('returns null when not found', () async {
        final transaction = await dao.getTransactionById(999);

        expect(transaction, isNull);
      });
    });

    group('getAllTransactions', () {
      test('returns empty list when no transactions exist', () async {
        final transactions = await dao.getAllTransactions();

        expect(transactions, isEmpty);
      });

      test('returns all transactions ordered by date descending', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1500,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 10),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 20),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transactions = await dao.getAllTransactions();

        expect(transactions.length, 3);
        // Most recent first (20th, 15th, 10th)
        expect(transactions[0].amountFcfa, 25000);
        expect(transactions[1].amountFcfa, 350000);
        expect(transactions[2].amountFcfa, 1500);
      });
    });

    group('updateTransaction', () {
      test('updates existing transaction', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final original = await dao.getTransactionById(id);
        final updated = original!.copyWith(amountFcfa: 30000);

        final result = await dao.updateTransaction(updated);

        expect(result, true);

        final retrieved = await dao.getTransactionById(id);
        expect(retrieved!.amountFcfa, 30000);
      });

      test('updates transaction category', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final original = await dao.getTransactionById(id);
        final updated = original!.copyWith(category: 'food');

        await dao.updateTransaction(updated);

        final retrieved = await dao.getTransactionById(id);
        expect(retrieved!.category, 'food');
      });
    });

    group('deleteTransaction', () {
      test('deletes existing transaction', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final deletedCount = await dao.deleteTransaction(id);

        expect(deletedCount, 1);

        final transaction = await dao.getTransactionById(id);
        expect(transaction, isNull);
      });

      test('returns 0 when deleting non-existent transaction', () async {
        final deletedCount = await dao.deleteTransaction(999);

        expect(deletedCount, 0);
      });
    });

    // ============== FILTERED QUERIES ==============

    group('getTransactionsByDateRange', () {
      test('returns transactions within date range', () async {
        // Create transactions on different dates
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 5),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 3000,
            category: 'leisure',
            type: 'expense',
            date: DateTime(2026, 1, 25),
          ),
        );

        final transactions = await dao.getTransactionsByDateRange(
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 20),
        );

        expect(transactions.length, 1);
        expect(transactions[0].amountFcfa, 2000);
      });

      test('includes boundary dates', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 10),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 20),
          ),
        );

        final transactions = await dao.getTransactionsByDateRange(
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 20),
        );

        expect(transactions.length, 2);
      });

      test('returns empty list when no transactions in range', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 5),
          ),
        );

        final transactions = await dao.getTransactionsByDateRange(
          DateTime(2026, 2, 1),
          DateTime(2026, 2, 28),
        );

        expect(transactions, isEmpty);
      });
    });

    group('getTransactionsByCategory', () {
      test('returns transactions for specific category', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 3000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 16),
          ),
        );

        final transactions = await dao.getTransactionsByCategory('food');

        expect(transactions.length, 2);
        expect(transactions.every((t) => t.category == 'food'), true);
      });

      test('returns empty list for non-existent category', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transactions = await dao.getTransactionsByCategory('leisure');

        expect(transactions, isEmpty);
      });
    });

    group('getTransactionsByType', () {
      test('returns only expense transactions', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 16),
          ),
        );

        final transactions = await dao.getTransactionsByType('expense');

        expect(transactions.length, 2);
        expect(transactions.every((t) => t.type == 'expense'), true);
      });

      test('returns only income transactions', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transactions = await dao.getTransactionsByType('income');

        expect(transactions.length, 1);
        expect(transactions[0].type, 'income');
      });
    });

    group('getTransactionsForCurrentMonth', () {
      test('returns transactions for the given month', () async {
        // January transactions
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 5),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 25),
          ),
        );

        // February transaction
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 3000,
            category: 'leisure',
            type: 'expense',
            date: DateTime(2026, 2, 10),
          ),
        );

        final transactions = await dao.getTransactionsForCurrentMonth(
          DateTime(2026, 1, 15),
        );

        expect(transactions.length, 2);
        expect(transactions.every((t) => t.date.month == 1), true);
      });

      test('handles month boundary correctly', () async {
        // Last day of January
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // First day of February
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 2, 1, 0, 0, 0),
          ),
        );

        final janTransactions = await dao.getTransactionsForCurrentMonth(
          DateTime(2026, 1, 15),
        );

        final febTransactions = await dao.getTransactionsForCurrentMonth(
          DateTime(2026, 2, 15),
        );

        expect(janTransactions.length, 1);
        expect(febTransactions.length, 1);
      });
    });

    group('getSumByType', () {
      test('returns sum of expense amounts', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        final expenseSum = await dao.getSumByType('expense');

        expect(expenseSum, 3000);
      });

      test('returns 0 when no transactions of type exist', () async {
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final incomeSum = await dao.getSumByType('income');

        expect(incomeSum, 0);
      });
    });

    group('getExpensesSumForMonth', () {
      test('returns sum of expenses for specific month', () async {
        // January expenses
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 10),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 20),
          ),
        );

        // January income (should not be counted)
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 15),
          ),
        );

        // February expense (should not be counted)
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 5000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 2, 10),
          ),
        );

        final sum = await dao.getExpensesSumForMonth(DateTime(2026, 1, 15));

        expect(sum, 3000);
      });
    });

    group('getIncomeSumForMonth', () {
      test('returns sum of income for specific month', () async {
        // January income
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 350000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 1, 5),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 50000,
            category: 'freelance',
            type: 'income',
            date: DateTime(2026, 1, 20),
          ),
        );

        // January expense (should not be counted)
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 5000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        // February income (should not be counted)
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 100000,
            category: 'salary',
            type: 'income',
            date: DateTime(2026, 2, 5),
          ),
        );

        final sum = await dao.getIncomeSumForMonth(DateTime(2026, 1, 15));

        expect(sum, 400000);
      });

      test('returns 0 when no income in month', () async {
        // Only expenses
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 5000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final sum = await dao.getIncomeSumForMonth(DateTime(2026, 1, 15));

        expect(sum, 0);
      });
    });

    // ============== REACTIVE STREAMS ==============

    group('watchAllTransactions', () {
      test('emits updates when transactions change', () async {
        final stream = dao.watchAllTransactions();

        // Get first emission (should be empty)
        final firstEmission = await stream.first;
        expect(firstEmission, isEmpty);

        // Create a transaction
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 25000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        // Get the next emission with the new transaction
        final secondEmission = await dao.watchAllTransactions().first;
        expect(secondEmission, hasLength(1));
      });
    });

    group('watchTransactionsForMonth', () {
      test('emits only transactions for the specified month', () async {
        // Create transactions in different months
        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 2000,
            category: 'transport',
            type: 'expense',
            date: DateTime(2026, 2, 15),
          ),
        );

        // Watch January
        final janEmission = await dao.watchTransactionsForMonth(
          DateTime(2026, 1, 15),
        ).first;

        expect(janEmission.length, 1);
        expect(janEmission[0].amountFcfa, 1000);

        // Watch February
        final febEmission = await dao.watchTransactionsForMonth(
          DateTime(2026, 2, 15),
        ).first;

        expect(febEmission.length, 1);
        expect(febEmission[0].amountFcfa, 2000);
      });
    });

    // ============== EDGE CASES ==============

    group('edge cases', () {
      test('handles zero amount (FCFA)', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 0,
            category: 'other',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.amountFcfa, 0);
      });

      test('handles empty category string', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: '',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.category, '');
      });

      test('handles French special characters in note', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1500,
            category: 'food',
            type: 'expense',
            note: const Value('Café au lait à côté de la gare'),
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.note, 'Café au lait à côté de la gare');
      });

      test('handles large FCFA amounts (max int)', () async {
        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 999999999,
            category: 'other',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final transaction = await dao.getTransactionById(id);
        expect(transaction!.amountFcfa, 999999999);
      });

      test('createdAt is auto-generated', () async {
        final beforeCreate = DateTime.now();

        final id = await dao.createTransaction(
          TransactionsCompanion.insert(
            amountFcfa: 1000,
            category: 'food',
            type: 'expense',
            date: DateTime(2026, 1, 15),
          ),
        );

        final afterCreate = DateTime.now();

        final transaction = await dao.getTransactionById(id);
        expect(
          transaction!.createdAt.isAfter(beforeCreate.subtract(
            const Duration(seconds: 1),
          )),
          true,
        );
        expect(
          transaction.createdAt.isBefore(afterCreate.add(
            const Duration(seconds: 1),
          )),
          true,
        );
      });
    });
  });
}
