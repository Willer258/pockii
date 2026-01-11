import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:accountapp/features/transactions/data/transaction_repository.dart';
import 'package:accountapp/features/transactions/domain/models/transaction_model.dart';
import 'package:accountapp/features/transactions/domain/models/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionsDao dao;
  late TransactionRepository repository;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = TransactionsDao(db);
    repository = TransactionRepository(dao);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionRepository', () {
    // ============== CRUD OPERATIONS ==============

    group('createTransaction', () {
      test('creates transaction and returns ID', () async {
        final transaction = TransactionModel(
          id: 0, // ID will be assigned by database
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);

        expect(id, greaterThan(0));
      });

      test('creates transaction with note', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 1500,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
          note: 'Déjeuner',
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved!.note, 'Déjeuner');
      });

      test('creates income transaction', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved!.type, TransactionType.income);
      });
    });

    group('getTransactionById', () {
      test('returns TransactionModel when found', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved, isNotNull);
        expect(retrieved!.amountFcfa, 25000);
        expect(retrieved.category, 'transport');
        expect(retrieved.type, TransactionType.expense);
      });

      test('returns null when not found', () async {
        final retrieved = await repository.getTransactionById(999);

        expect(retrieved, isNull);
      });
    });

    group('getAllTransactions', () {
      test('returns empty list when no transactions', () async {
        final transactions = await repository.getAllTransactions();

        expect(transactions, isEmpty);
      });

      test('returns all transactions as TransactionModel', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getAllTransactions();

        expect(transactions.length, 2);
        expect(transactions[0], isA<TransactionModel>());
      });

      test('returns transactions ordered by date descending', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 10),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 20),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getAllTransactions();

        expect(transactions[0].amountFcfa, 2000); // Most recent first
        expect(transactions[1].amountFcfa, 1000);
      });
    });

    group('updateTransaction', () {
      test('updates existing transaction', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final original = await repository.getTransactionById(id);
        final updated = original!.copyWith(amountFcfa: 30000);

        final result = await repository.updateTransaction(updated);

        expect(result, true);

        final retrieved = await repository.getTransactionById(id);
        expect(retrieved!.amountFcfa, 30000);
      });

      test('updates transaction type', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'other',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final original = await repository.getTransactionById(id);
        final updated = original!.copyWith(type: TransactionType.income);

        await repository.updateTransaction(updated);

        final retrieved = await repository.getTransactionById(id);
        expect(retrieved!.type, TransactionType.income);
      });
    });

    group('deleteTransaction', () {
      test('deletes existing transaction', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final deletedCount = await repository.deleteTransaction(id);

        expect(deletedCount, 1);

        final retrieved = await repository.getTransactionById(id);
        expect(retrieved, isNull);
      });
    });

    // ============== FILTERED QUERIES ==============

    group('getTransactionsByDateRange', () {
      test('returns transactions within date range', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 5),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 3000,
          category: 'leisure',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 25),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getTransactionsByDateRange(
          DateTime(2026, 1, 10),
          DateTime(2026, 1, 20),
        );

        expect(transactions.length, 1);
        expect(transactions[0].amountFcfa, 2000);
      });
    });

    group('getTransactionsByCategory', () {
      test('returns transactions for specific category', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getTransactionsByCategory('food');

        expect(transactions.length, 1);
        expect(transactions[0].category, 'food');
      });
    });

    group('getTransactionsByType', () {
      test('returns only expense transactions', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getTransactionsByType(
          TransactionType.expense,
        );

        expect(transactions.length, 1);
        expect(transactions[0].type, TransactionType.expense);
      });

      test('returns only income transactions', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getTransactionsByType(
          TransactionType.income,
        );

        expect(transactions.length, 1);
        expect(transactions[0].type, TransactionType.income);
      });
    });

    group('getTransactionsForCurrentMonth', () {
      test('returns transactions for the given month', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 2, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final transactions = await repository.getTransactionsForCurrentMonth(
          DateTime(2026, 1, 15),
        );

        expect(transactions.length, 1);
        expect(transactions[0].amountFcfa, 1000);
      });
    });

    group('getExpensesSumForMonth', () {
      test('returns sum of expenses for month', () async {
        // January expenses
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 10),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 20),
          createdAt: DateTime(2026, 1, 1),
        ));

        // Income (should not be counted)
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final sum = await repository.getExpensesSumForMonth(
          DateTime(2026, 1, 15),
        );

        expect(sum, 3000);
      });
    });

    group('getIncomeSumForMonth', () {
      test('returns sum of income for month', () async {
        // January income
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 5),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 50000,
          category: 'freelance',
          type: TransactionType.income,
          date: DateTime(2026, 1, 20),
          createdAt: DateTime(2026, 1, 1),
        ));

        // Expense (should not be counted)
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 5000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final sum = await repository.getIncomeSumForMonth(
          DateTime(2026, 1, 15),
        );

        expect(sum, 400000);
      });

      test('returns 0 when no income in month', () async {
        // Only expenses
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 5000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final sum = await repository.getIncomeSumForMonth(
          DateTime(2026, 1, 15),
        );

        expect(sum, 0);
      });
    });

    // ============== REACTIVE STREAMS ==============

    group('watchAllTransactions', () {
      test('emits TransactionModel list', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final emission = await repository.watchAllTransactions().first;

        expect(emission.length, 1);
        expect(emission[0], isA<TransactionModel>());
      });
    });

    group('watchTransactionsForMonth', () {
      test('emits only transactions for specified month', () async {
        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 1000,
          category: 'food',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        await repository.createTransactionFromModel(TransactionModel(
          id: 0,
          amountFcfa: 2000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 2, 15),
          createdAt: DateTime(2026, 1, 1),
        ));

        final janEmission = await repository.watchTransactionsForMonth(
          DateTime(2026, 1, 15),
        ).first;

        expect(janEmission.length, 1);
        expect(janEmission[0].amountFcfa, 1000);
      });
    });

    // ============== DOMAIN MODEL MAPPING ==============

    group('domain model mapping', () {
      test('correctly maps TransactionType from database', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 25000,
          category: 'transport',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved!.type, TransactionType.expense);
        expect(retrieved.type.toDbValue(), 'expense');
      });

      test('correctly maps income type from database', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 350000,
          category: 'salary',
          type: TransactionType.income,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved!.type, TransactionType.income);
        expect(retrieved.type.toDbValue(), 'income');
      });

      test('preserves FCFA amount as int through round trip', () async {
        final transaction = TransactionModel(
          id: 0,
          amountFcfa: 999999999, // Max edge case
          category: 'other',
          type: TransactionType.expense,
          date: DateTime(2026, 1, 15),
          createdAt: DateTime(2026, 1, 1),
        );

        final id = await repository.createTransactionFromModel(transaction);
        final retrieved = await repository.getTransactionById(id);

        expect(retrieved!.amountFcfa, 999999999);
      });
    });
  });
}
