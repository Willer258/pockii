import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/planned_expenses_dao.dart';
import 'package:pockii/core/database/daos/transactions_dao.dart';
import 'package:pockii/features/planned_expenses/data/planned_expense_repository.dart';
import 'package:pockii/features/planned_expenses/domain/services/planned_expense_conversion_service.dart';
import 'package:pockii/features/transactions/data/transaction_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlannedExpensesDao plannedExpensesDao;
  late TransactionsDao transactionsDao;
  late PlannedExpenseRepository plannedExpenseRepository;
  late TransactionRepository transactionRepository;
  late PlannedExpenseConversionService service;

  setUp(() {
    db = AppDatabase.inMemory();
    plannedExpensesDao = PlannedExpensesDao(db);
    transactionsDao = TransactionsDao(db);
    plannedExpenseRepository = PlannedExpenseRepository(plannedExpensesDao);
    transactionRepository = TransactionRepository(transactionsDao);
    service = PlannedExpenseConversionService(
      plannedExpenseRepository: plannedExpenseRepository,
      transactionRepository: transactionRepository,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('PlannedExpenseConversionService', () {
    group('convertToTransaction', () {
      test('successfully converts pending planned expense to transaction',
          () async {
        // Create a pending planned expense
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'New Phone',
            amountFcfa: 150000,
            expectedDate: DateTime(2026, 2, 15),
            category: const Value('other'),
          ),
        );

        final transactionDate = DateTime(2026, 2, 10);

        // Convert to transaction
        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 150000,
          transactionDate: transactionDate,
        );

        // Verify success
        expect(result.success, isTrue);
        expect(result.transactionId, greaterThan(0));
        expect(result.errorMessage, isNull);

        // Verify planned expense is marked as converted
        final updatedExpense =
            await plannedExpenseRepository.getPlannedExpenseById(expenseId);
        expect(updatedExpense!.isConverted, isTrue);

        // Verify transaction was created
        final transaction =
            await transactionRepository.getTransactionById(result.transactionId);
        expect(transaction, isNotNull);
        expect(transaction!.amountFcfa, 150000);
        expect(transaction.category, 'other');
        expect(transaction.note, 'New Phone');
      });

      test('allows adjusting amount during conversion', () async {
        // Create a pending planned expense
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'New Phone',
            amountFcfa: 150000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        // Convert with different amount
        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 145000, // Adjusted amount
          transactionDate: DateTime(2026, 2, 10),
        );

        // Verify success
        expect(result.success, isTrue);

        // Verify transaction has adjusted amount
        final transaction =
            await transactionRepository.getTransactionById(result.transactionId);
        expect(transaction!.amountFcfa, 145000);
      });

      test('fails with invalid amount (zero)', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 0,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Montant invalide');
      });

      test('fails with invalid amount (negative)', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: -5000,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Montant invalide');
      });

      test('fails when planned expense does not exist', () async {
        final result = await service.convertToTransaction(
          plannedExpenseId: 999,
          actualAmount: 10000,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isFalse);
        expect(result.errorMessage, 'Dépense prévue introuvable');
      });

      test('fails when planned expense is already converted', () async {
        // Create and convert a planned expense
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );
        await plannedExpensesDao.markAsConverted(expenseId);

        // Try to convert again
        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 10000,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isFalse);
        expect(
          result.errorMessage,
          'Cette dépense a déjà été convertie ou annulée',
        );
      });

      test('fails when planned expense is cancelled', () async {
        // Create and cancel a planned expense
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );
        await plannedExpensesDao.markAsCancelled(expenseId);

        // Try to convert
        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 10000,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isFalse);
        expect(
          result.errorMessage,
          'Cette dépense a déjà été convertie ou annulée',
        );
      });

      test('uses default category "other" when expense has no category',
          () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
            // No category specified
          ),
        );

        final result = await service.convertToTransaction(
          plannedExpenseId: expenseId,
          actualAmount: 10000,
          transactionDate: DateTime(2026, 2, 10),
        );

        expect(result.success, isTrue);
        final transaction =
            await transactionRepository.getTransactionById(result.transactionId);
        expect(transaction!.category, 'other');
      });
    });

    group('cancelPlannedExpense', () {
      test('successfully cancels pending planned expense', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final result = await service.cancelPlannedExpense(expenseId);

        expect(result, isTrue);

        final expense =
            await plannedExpenseRepository.getPlannedExpenseById(expenseId);
        expect(expense!.isCancelled, isTrue);
      });

      test('fails when planned expense does not exist', () async {
        final result = await service.cancelPlannedExpense(999);

        expect(result, isFalse);
      });

      test('fails when planned expense is already converted', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );
        await plannedExpensesDao.markAsConverted(expenseId);

        final result = await service.cancelPlannedExpense(expenseId);

        expect(result, isFalse);
      });

      test('fails when planned expense is already cancelled', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );
        await plannedExpensesDao.markAsCancelled(expenseId);

        final result = await service.cancelPlannedExpense(expenseId);

        expect(result, isFalse);
      });
    });

    group('getPlannedExpenseById', () {
      test('returns expense when found', () async {
        final expenseId = await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final expense = await service.getPlannedExpenseById(expenseId);

        expect(expense, isNotNull);
        expect(expense!.description, 'Test');
      });

      test('returns null when not found', () async {
        final expense = await service.getPlannedExpenseById(999);

        expect(expense, isNull);
      });
    });
  });

  group('ConversionResult', () {
    test('success factory creates successful result', () {
      const result = ConversionResult.success(123);

      expect(result.success, isTrue);
      expect(result.transactionId, 123);
      expect(result.errorMessage, isNull);
    });

    test('failure factory creates failed result', () {
      const result = ConversionResult.failure('Error message');

      expect(result.success, isFalse);
      expect(result.transactionId, 0);
      expect(result.errorMessage, 'Error message');
    });
  });
}
