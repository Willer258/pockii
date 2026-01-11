import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/budget_periods_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/features/budget/data/repositories/budget_period_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BudgetPeriodsDao dao;
  late BudgetPeriodRepository repository;
  late TestClock testClock;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = BudgetPeriodsDao(db);
    testClock = TestClock(DateTime(2026, 1, 15, 10, 30));
    repository = BudgetPeriodRepository(
      budgetPeriodsDao: dao,
      clock: testClock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetPeriodRepository', () {
    group('getCurrentPeriod', () {
      test('returns null when no period exists', () async {
        final period = await repository.getCurrentPeriod();

        expect(period, isNull);
      });

      test('returns period for current date', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final period = await repository.getCurrentPeriod();

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });

      test('returns null when date is outside all periods', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2025, 12),
            endDate: DateTime(2025, 12, 31, 23, 59, 59),
          ),
        );

        final period = await repository.getCurrentPeriod();

        expect(period, isNull);
      });
    });

    group('getPeriodForDate', () {
      test('returns period for specific date', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 2),
            endDate: DateTime(2026, 2, 28, 23, 59, 59),
          ),
        );

        final period = await repository.getPeriodForDate(DateTime(2026, 2, 15));

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });

      test('returns null when no period covers date', () async {
        final period = await repository.getPeriodForDate(DateTime(2030, 1));

        expect(period, isNull);
      });
    });

    group('getAllPeriods', () {
      test('returns empty list when no periods exist', () async {
        final periods = await repository.getAllPeriods();

        expect(periods, isEmpty);
      });

      test('returns all periods ordered by start date descending', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 300000,
            startDate: DateTime(2025, 11),
            endDate: DateTime(2025, 11, 30, 23, 59, 59),
          ),
        );

        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2025, 12),
            endDate: DateTime(2025, 12, 31, 23, 59, 59),
          ),
        );

        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 400000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final periods = await repository.getAllPeriods();

        expect(periods.length, 3);
        expect(periods[0].monthlyBudgetFcfa, 400000); // Most recent first
        expect(periods[1].monthlyBudgetFcfa, 350000);
        expect(periods[2].monthlyBudgetFcfa, 300000);
      });
    });

    group('createPeriodForCurrentMonth', () {
      test('creates period with correct start and end dates', () async {
        final id = await repository.createPeriodForCurrentMonth(350000);

        expect(id, greaterThan(0));

        final period = await dao.getBudgetPeriodById(id);
        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
        expect(period.startDate, DateTime(2026, 1));
        expect(period.endDate, DateTime(2026, 1, 31, 23, 59, 59));
      });

      test('creates different periods for different months', () async {
        // January
        var id = await repository.createPeriodForCurrentMonth(350000);
        var period = await dao.getBudgetPeriodById(id);
        expect(period!.startDate.month, 1);

        // February
        testClock.setNow(DateTime(2026, 2, 10));
        id = await repository.createPeriodForCurrentMonth(350000);
        period = await dao.getBudgetPeriodById(id);
        expect(period!.startDate.month, 2);
        expect(period.endDate, DateTime(2026, 2, 28, 23, 59, 59));
      });
    });

    group('createPeriodForMonth', () {
      test('creates period for specific month', () async {
        final id = await repository.createPeriodForMonth(2026, 6, 500000);

        final period = await dao.getBudgetPeriodById(id);
        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 500000);
        expect(period.startDate, DateTime(2026, 6));
        expect(period.endDate, DateTime(2026, 6, 30, 23, 59, 59));
      });

      test('handles leap year February correctly', () async {
        final id = await repository.createPeriodForMonth(2024, 2, 350000);

        final period = await dao.getBudgetPeriodById(id);
        expect(period!.endDate, DateTime(2024, 2, 29, 23, 59, 59));
      });

      test('handles year boundary December correctly', () async {
        final id = await repository.createPeriodForMonth(2025, 12, 350000);

        final period = await dao.getBudgetPeriodById(id);
        expect(period!.endDate, DateTime(2025, 12, 31, 23, 59, 59));
      });
    });

    group('updatePeriodBudget', () {
      test('updates existing period budget', () async {
        final id = await repository.createPeriodForCurrentMonth(350000);

        final result = await repository.updatePeriodBudget(id, 500000);

        expect(result, true);

        final period = await dao.getBudgetPeriodById(id);
        expect(period!.monthlyBudgetFcfa, 500000);
      });

      test('returns false for non-existent period', () async {
        final result = await repository.updatePeriodBudget(999, 500000);

        expect(result, false);
      });
    });

    group('getLastPeriodBudget', () {
      test('returns null when no periods exist', () async {
        final budget = await repository.getLastPeriodBudget();

        expect(budget, isNull);
      });

      test('returns most recent period budget', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 300000,
            startDate: DateTime(2025, 11),
            endDate: DateTime(2025, 11, 30, 23, 59, 59),
          ),
        );

        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 450000,
            startDate: DateTime(2025, 12),
            endDate: DateTime(2025, 12, 31, 23, 59, 59),
          ),
        );

        final budget = await repository.getLastPeriodBudget();

        expect(budget, 450000);
      });
    });

    group('ensureCurrentPeriodExists', () {
      test('returns existing period when one exists', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final period = await repository.ensureCurrentPeriodExists();

        expect(period.monthlyBudgetFcfa, 350000);
      });

      test('creates new period using last period budget when no current exists', () async {
        // Create previous month period
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 450000,
            startDate: DateTime(2025, 12),
            endDate: DateTime(2025, 12, 31, 23, 59, 59),
          ),
        );

        final period = await repository.ensureCurrentPeriodExists();

        expect(period.monthlyBudgetFcfa, 450000); // Carried forward
        expect(period.startDate, DateTime(2026, 1));
      });

      test('creates new period using default budget when no periods exist', () async {
        final period = await repository.ensureCurrentPeriodExists(defaultBudget: 500000);

        expect(period.monthlyBudgetFcfa, 500000);
        expect(period.startDate, DateTime(2026, 1));
      });

      test('creates new period with 0 budget when no periods and no default', () async {
        final period = await repository.ensureCurrentPeriodExists();

        expect(period.monthlyBudgetFcfa, 0);
      });
    });

    group('hasMonthChanged', () {
      test('returns true when month is different', () async {
        final lastKnown = DateTime(2025, 12, 15);

        final result = repository.hasMonthChanged(lastKnown);

        expect(result, true);
      });

      test('returns false when month is same', () async {
        final lastKnown = DateTime(2026, 1, 5);

        final result = repository.hasMonthChanged(lastKnown);

        expect(result, false);
      });

      test('returns true when year changes even same month number', () async {
        final lastKnown = DateTime(2025, 1, 15); // Same month (1) but different year

        final result = repository.hasMonthChanged(lastKnown);

        expect(result, true);
      });
    });

    group('detectTimeInconsistency', () {
      test('returns true when clock moved backward', () async {
        final lastRecorded = DateTime(2026, 1, 20); // Future compared to clock (Jan 15)

        final result = repository.detectTimeInconsistency(lastRecorded);

        expect(result, true);
      });

      test('returns false when clock moved forward', () async {
        final lastRecorded = DateTime(2026, 1, 10); // Past compared to clock (Jan 15)

        final result = repository.detectTimeInconsistency(lastRecorded);

        expect(result, false);
      });

      test('returns false when same time', () async {
        final lastRecorded = DateTime(2026, 1, 15, 10, 30);

        final result = repository.detectTimeInconsistency(lastRecorded);

        expect(result, false);
      });
    });

    group('watchCurrentPeriod', () {
      test('emits null when no current period exists', () async {
        final firstValue = await repository.watchCurrentPeriod().first;

        expect(firstValue, isNull);
      });

      test('emits period when one exists', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final period = await repository.watchCurrentPeriod().first;

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });
    });
  });
}
