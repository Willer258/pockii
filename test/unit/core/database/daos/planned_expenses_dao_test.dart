import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/planned_expenses_dao.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PlannedExpensesDao dao;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = PlannedExpensesDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PlannedExpensesDao', () {
    group('createPlannedExpense', () {
      test('creates a planned expense and returns ID', () async {
        final id = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'New Phone',
            amountFcfa: 150000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        expect(id, greaterThan(0));
      });

      test('creates multiple expenses with unique IDs', () async {
        final id1 = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Expense 1',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        final id2 = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Expense 2',
            amountFcfa: 20000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        expect(id1, isNot(id2));
      });
    });

    group('getPlannedExpenseById', () {
      test('returns expense when found', () async {
        final id = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test Expense',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 2, 10),
          ),
        );

        final expense = await dao.getPlannedExpenseById(id);

        expect(expense, isNotNull);
        expect(expense!.description, 'Test Expense');
        expect(expense.amountFcfa, 50000);
      });

      test('returns null when not found', () async {
        final expense = await dao.getPlannedExpenseById(999);

        expect(expense, isNull);
      });
    });

    group('getPendingPlannedExpenses', () {
      test('returns only pending expenses', () async {
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Pending 1',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Converted',
            amountFcfa: 20000,
            expectedDate: DateTime(2026, 2, 5),
            status: const Value('converted'),
          ),
        );

        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Pending 2',
            amountFcfa: 30000,
            expectedDate: DateTime(2026, 2, 10),
          ),
        );

        final pending = await dao.getPendingPlannedExpenses();

        expect(pending.length, 2);
        expect(pending.every((e) => e.status == 'pending'), isTrue);
      });

      test('returns expenses ordered by expected date', () async {
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Later',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 3, 1),
          ),
        );

        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Earlier',
            amountFcfa: 20000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        final pending = await dao.getPendingPlannedExpenses();

        expect(pending.first.description, 'Earlier');
        expect(pending.last.description, 'Later');
      });
    });

    group('getTotalPendingAmount', () {
      test('returns sum of pending expenses', () async {
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Expense 1',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Expense 2',
            amountFcfa: 20000,
            expectedDate: DateTime(2026, 2, 5),
          ),
        );

        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Converted',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 2, 10),
            status: const Value('converted'),
          ),
        );

        final total = await dao.getTotalPendingAmount();

        expect(total, 30000); // Only pending: 10000 + 20000
      });

      test('returns 0 when no pending expenses', () async {
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Converted',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 2, 10),
            status: const Value('converted'),
          ),
        );

        final total = await dao.getTotalPendingAmount();

        expect(total, 0);
      });
    });

    group('markAsConverted', () {
      test('updates status to converted', () async {
        final id = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        final result = await dao.markAsConverted(id);

        expect(result, isTrue);

        final expense = await dao.getPlannedExpenseById(id);
        expect(expense!.status, 'converted');
        expect(expense.updatedAt, isNotNull);
      });

      test('returns false for non-existent expense', () async {
        final result = await dao.markAsConverted(999);

        expect(result, isFalse);
      });
    });

    group('markAsCancelled', () {
      test('updates status to cancelled', () async {
        final id = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        final result = await dao.markAsCancelled(id);

        expect(result, isTrue);

        final expense = await dao.getPlannedExpenseById(id);
        expect(expense!.status, 'cancelled');
      });
    });

    group('getPendingPlannedExpensesForMonth', () {
      test('returns only expenses for specified month', () async {
        // January expense
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'January',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 1, 15),
          ),
        );

        // February expense
        await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'February',
            amountFcfa: 20000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final januaryExpenses =
            await dao.getPendingPlannedExpensesForMonth(DateTime(2026, 1));

        expect(januaryExpenses.length, 1);
        expect(januaryExpenses.first.description, 'January');
      });
    });

    group('deletePlannedExpense', () {
      test('deletes expense and returns count', () async {
        final id = await dao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Test',
            amountFcfa: 10000,
            expectedDate: DateTime(2026, 2, 1),
          ),
        );

        final count = await dao.deletePlannedExpense(id);

        expect(count, 1);

        final expense = await dao.getPlannedExpenseById(id);
        expect(expense, isNull);
      });
    });
  });
}
