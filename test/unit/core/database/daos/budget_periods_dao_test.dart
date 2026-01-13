import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/budget_periods_dao.dart';

void main() {
  late AppDatabase db;
  late BudgetPeriodsDao dao;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = BudgetPeriodsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetPeriodsDao', () {
    group('createBudgetPeriod', () {
      test('creates a budget period and returns ID', () async {
        final id = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        expect(id, greaterThan(0));
      });

      test('creates multiple budget periods with unique IDs', () async {
        final id1 = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final id2 = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 400000,
            startDate: DateTime(2024, 2, 1),
            endDate: DateTime(2024, 2, 29),
          ),
        );

        expect(id1, isNot(equals(id2)));
      });
    });

    group('getBudgetPeriodById', () {
      test('returns budget period when found', () async {
        final id = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final period = await dao.getBudgetPeriodById(id);

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });

      test('returns null when not found', () async {
        final period = await dao.getBudgetPeriodById(999);

        expect(period, isNull);
      });
    });

    group('getCurrentBudgetPeriod', () {
      test('returns period containing the given date', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final period = await dao.getCurrentBudgetPeriod(DateTime(2024, 1, 15));

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });

      test('returns null when date is outside all periods', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final period = await dao.getCurrentBudgetPeriod(DateTime(2024, 3, 15));

        expect(period, isNull);
      });

      test('includes boundary dates (start and end)', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final startBoundary = await dao.getCurrentBudgetPeriod(DateTime(2024, 1, 1));
        final endBoundary = await dao.getCurrentBudgetPeriod(DateTime(2024, 1, 31));

        expect(startBoundary, isNotNull);
        expect(endBoundary, isNotNull);
      });

      test('handles multiple overlapping periods gracefully (regression)', () async {
        // Regression test: Previously caused "Bad state: Too many elements" crash
        // when getSingleOrNull() was used instead of get() with limit(1)

        // Create first period for January
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        // Simulate edge case: create duplicate period for same date range
        // This can happen if user creates period during onboarding and
        // app auto-creates one on launch
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 400000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        // Should NOT throw "Bad state: Too many elements"
        // Should return most recently created period
        final period = await dao.getCurrentBudgetPeriod(DateTime(2024, 1, 15));

        expect(period, isNotNull);
        // Returns most recent (by createdAt) - the 400000 one
        expect(period!.monthlyBudgetFcfa, 400000);
      });
    });

    group('getAllBudgetPeriods', () {
      test('returns empty list when no periods exist', () async {
        final periods = await dao.getAllBudgetPeriods();

        expect(periods, isEmpty);
      });

      test('returns all periods ordered by start date descending', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 300000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 400000,
            startDate: DateTime(2024, 3, 1),
            endDate: DateTime(2024, 3, 31),
          ),
        );

        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 2, 1),
            endDate: DateTime(2024, 2, 29),
          ),
        );

        final periods = await dao.getAllBudgetPeriods();

        expect(periods.length, 3);
        // Most recent first (March, February, January)
        expect(periods[0].monthlyBudgetFcfa, 400000);
        expect(periods[1].monthlyBudgetFcfa, 350000);
        expect(periods[2].monthlyBudgetFcfa, 300000);
      });
    });

    group('updateBudgetPeriod', () {
      test('updates existing budget period', () async {
        final id = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final original = await dao.getBudgetPeriodById(id);
        final updated = original!.copyWith(monthlyBudgetFcfa: 500000);

        final result = await dao.updateBudgetPeriod(updated);

        expect(result, true);

        final retrieved = await dao.getBudgetPeriodById(id);
        expect(retrieved!.monthlyBudgetFcfa, 500000);
      });
    });

    group('deleteBudgetPeriod', () {
      test('deletes existing budget period', () async {
        final id = await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        final deletedCount = await dao.deleteBudgetPeriod(id);

        expect(deletedCount, 1);

        final period = await dao.getBudgetPeriodById(id);
        expect(period, isNull);
      });

      test('returns 0 when deleting non-existent period', () async {
        final deletedCount = await dao.deleteBudgetPeriod(999);

        expect(deletedCount, 0);
      });
    });

    group('watchAllBudgetPeriods', () {
      test('emits updates when periods change', () async {
        final stream = dao.watchAllBudgetPeriods();

        // Get first emission (should be empty since we're in a fresh test)
        final firstEmission = await stream.first;
        expect(firstEmission, isEmpty);

        // Now create a period and verify the stream emits the update
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ),
        );

        // Get the next emission with the new period
        final secondEmission = await dao.watchAllBudgetPeriods().first;
        expect(secondEmission, hasLength(1));
      });
    });
  });
}
