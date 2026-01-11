import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/budget_periods_dao.dart';
import 'package:accountapp/core/database/daos/planned_expenses_dao.dart';
import 'package:accountapp/core/database/daos/subscriptions_dao.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/features/budget/data/repositories/budget_period_repository.dart';
import 'package:accountapp/features/budget/domain/services/budget_calculation_service.dart';
import 'package:accountapp/features/planned_expenses/data/planned_expense_repository.dart';
import 'package:accountapp/features/subscriptions/data/subscription_repository.dart';
import 'package:accountapp/features/transactions/data/transaction_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BudgetPeriodsDao dao;
  late TransactionsDao transactionsDao;
  late SubscriptionsDao subscriptionsDao;
  late PlannedExpensesDao plannedExpensesDao;
  late BudgetPeriodRepository repository;
  late TransactionRepository transactionRepository;
  late SubscriptionRepository subscriptionRepository;
  late PlannedExpenseRepository plannedExpenseRepository;
  late BudgetCalculationService service;
  late TestClock testClock;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = BudgetPeriodsDao(db);
    transactionsDao = TransactionsDao(db);
    subscriptionsDao = SubscriptionsDao(db);
    plannedExpensesDao = PlannedExpensesDao(db);
    testClock = TestClock(DateTime(2026, 1, 15, 10, 30));
    repository = BudgetPeriodRepository(
      budgetPeriodsDao: dao,
      clock: testClock,
    );
    transactionRepository = TransactionRepository(transactionsDao);
    subscriptionRepository = SubscriptionRepository(subscriptionsDao);
    plannedExpenseRepository = PlannedExpenseRepository(plannedExpensesDao);
    service = BudgetCalculationService(
      budgetPeriodRepository: repository,
      transactionRepository: transactionRepository,
      subscriptionRepository: subscriptionRepository,
      plannedExpenseRepository: plannedExpenseRepository,
      clock: testClock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetCalculationResult', () {
    test('percentageRemaining returns 0 when totalBudget is 0', () {
      final result = BudgetCalculationResult(
        totalBudget: 0,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: 0,
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.percentageRemaining, 0);
    });

    test('percentageRemaining calculates correctly', () {
      final result = BudgetCalculationResult(
        totalBudget: 100000,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: 60000,
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.percentageRemaining, 0.6);
    });

    test('percentageRemaining is clamped to 1.0 max', () {
      final result = BudgetCalculationResult(
        totalBudget: 100000,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: 150000, // More remaining than total (overfunded)
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.percentageRemaining, 1.0);
    });

    test('percentageRemaining is clamped to 0.0 min', () {
      final result = BudgetCalculationResult(
        totalBudget: 100000,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: -50000, // Negative (overspent)
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.percentageRemaining, 0.0);
    });

    test('isOverspent returns true when remaining is negative', () {
      final result = BudgetCalculationResult(
        totalBudget: 100000,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: -1,
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.isOverspent, true);
    });

    test('isOverspent returns false when remaining is non-negative', () {
      final result = BudgetCalculationResult(
        totalBudget: 100000,
        totalExpenses: 0,
        totalSubscriptions: 0,
        totalPlannedExpenses: 0,
        remainingBudget: 0,
        periodStart: DateTime(2026, 1),
        periodEnd: DateTime(2026, 1, 31),
      );

      expect(result.isOverspent, false);
    });
  });

  group('BudgetCalculationService', () {
    group('calculateRemainingBudget', () {
      test('creates period automatically when none exists', () async {
        // No period exists yet
        final result = await service.calculateRemainingBudget();

        expect(result.totalBudget, 0); // Default budget
        expect(result.remainingBudget, 0);
        expect(result.periodStart, DateTime(2026, 1));
        expect(result.periodEnd, DateTime(2026, 1, 31, 23, 59, 59));
      });

      test('uses existing period when one exists', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalBudget, 350000);
        expect(result.remainingBudget, 350000); // MVP: no expenses
      });

      test('returns correct period dates', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.periodStart, DateTime(2026, 1));
        expect(result.periodEnd, DateTime(2026, 1, 31, 23, 59, 59));
      });

      test('returns 0 for subscriptions and planned when none exist', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalExpenses, 0);
        expect(result.totalSubscriptions, 0);
        expect(result.totalPlannedExpenses, 0);
      });

      test('carries forward budget from previous period', () async {
        // Create previous month period
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 450000,
            startDate: DateTime(2025, 12),
            endDate: DateTime(2025, 12, 31, 23, 59, 59),
          ),
        );

        final result = await service.calculateRemainingBudget();

        // Should create January period with carried-forward budget
        expect(result.totalBudget, 450000);
      });
    });

    group('time inconsistency detection', () {
      test('hasTimeInconsistency is false on first calculation', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.hasTimeInconsistency, false);
      });

      test('hasTimeInconsistency is false when time moves forward', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // First calculation
        await service.calculateRemainingBudget();

        // Move time forward
        testClock.setNow(DateTime(2026, 1, 16, 10, 30));

        // Second calculation
        final result = await service.calculateRemainingBudget();

        expect(result.hasTimeInconsistency, false);
      });

      test('hasTimeInconsistency is true when time moves backward', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // First calculation
        await service.calculateRemainingBudget();

        // Move time backward (simulating clock manipulation)
        testClock.setNow(DateTime(2026, 1, 14, 10, 30));

        // Second calculation
        final result = await service.calculateRemainingBudget();

        expect(result.hasTimeInconsistency, true);
      });

      test('resetTimeInconsistencyDetection clears detection', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // First calculation
        await service.calculateRemainingBudget();

        // Move time backward
        testClock.setNow(DateTime(2026, 1, 14, 10, 30));

        // Reset detection
        service.resetTimeInconsistencyDetection();

        // Next calculation should not detect inconsistency
        final result = await service.calculateRemainingBudget();

        expect(result.hasTimeInconsistency, false);
      });
    });

    group('getCurrentPeriod', () {
      test('returns null when no period exists', () async {
        final period = await service.getCurrentPeriod();

        expect(period, isNull);
      });

      test('returns current period when one exists', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final period = await service.getCurrentPeriod();

        expect(period, isNotNull);
        expect(period!.monthlyBudgetFcfa, 350000);
      });
    });

    group('hasMonthChanged', () {
      test('returns true when month changed', () async {
        final lastKnown = DateTime(2025, 12, 31);

        final result = service.hasMonthChanged(lastKnown);

        expect(result, true);
      });

      test('returns false when same month', () async {
        final lastKnown = DateTime(2026, 1);

        final result = service.hasMonthChanged(lastKnown);

        expect(result, false);
      });
    });

    group('performance', () {
      test('calculateRemainingBudget completes in under 100ms', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        final stopwatch = Stopwatch()..start();
        await service.calculateRemainingBudget();
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });

    group('subscription integration', () {
      test('includes monthly subscription in total subscriptions', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Add a monthly subscription
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalSubscriptions, 5000);
        expect(result.remainingBudget, 350000 - 5000);
      });

      test('includes weekly subscription with 4.33x proration', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Add a weekly subscription of 1000 FCFA
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Weekly Tontine',
            amountFcfa: 1000,
            category: 'family',
            frequency: 'weekly',
            dueDay: 1, // Monday
          ),
        );

        final result = await service.calculateRemainingBudget();

        // 1000 * 4.33 = 4330 (rounded)
        expect(result.totalSubscriptions, 4330);
      });

      test('includes yearly subscription with 1/12 proration', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Add a yearly subscription of 12000 FCFA
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Annual Insurance',
            amountFcfa: 12000,
            category: 'insurance',
            frequency: 'yearly',
            dueDay: 1,
          ),
        );

        final result = await service.calculateRemainingBudget();

        // 12000 / 12 = 1000
        expect(result.totalSubscriptions, 1000);
      });

      test('sums multiple subscriptions of different frequencies', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Monthly: 5000
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        // Weekly: 1000 * 4.33 = 4330
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Weekly Tontine',
            amountFcfa: 1000,
            category: 'family',
            frequency: 'weekly',
            dueDay: 1,
          ),
        );

        // Yearly: 12000 / 12 = 1000
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Annual Insurance',
            amountFcfa: 12000,
            category: 'insurance',
            frequency: 'yearly',
            dueDay: 1,
          ),
        );

        final result = await service.calculateRemainingBudget();

        // 5000 + 4330 + 1000 = 10330
        expect(result.totalSubscriptions, 10330);
        expect(result.remainingBudget, 350000 - 10330);
      });

      test('excludes inactive subscriptions from total', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Active subscription
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        // Inactive subscription (should be excluded)
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Cancelled Gym',
            amountFcfa: 20000,
            category: 'other',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final result = await service.calculateRemainingBudget();

        // Only active subscription counts
        expect(result.totalSubscriptions, 5000);
      });

      test('subtracts subscriptions from remaining budget', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 100000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 10000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalBudget, 100000);
        expect(result.totalSubscriptions, 10000);
        expect(result.remainingBudget, 90000);
      });
    });

    group('planned expenses integration', () {
      test('includes pending planned expenses in budget calculation', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Add a pending planned expense for January
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'New Phone',
            amountFcfa: 150000,
            expectedDate: DateTime(2026, 1, 20),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalPlannedExpenses, 150000);
        expect(result.remainingBudget, 350000 - 150000);
      });

      test('sums multiple pending planned expenses', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Phone',
            amountFcfa: 100000,
            expectedDate: DateTime(2026, 1, 15),
          ),
        );

        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Laptop',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 1, 25),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalPlannedExpenses, 150000);
      });

      test('excludes converted planned expenses from total', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Pending expense
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Pending',
            amountFcfa: 100000,
            expectedDate: DateTime(2026, 1, 15),
          ),
        );

        // Converted expense (should be excluded)
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Converted',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 1, 10),
            status: const Value('converted'),
          ),
        );

        final result = await service.calculateRemainingBudget();

        // Only pending expense counts
        expect(result.totalPlannedExpenses, 100000);
      });

      test('excludes cancelled planned expenses from total', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Pending expense
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Pending',
            amountFcfa: 100000,
            expectedDate: DateTime(2026, 1, 15),
          ),
        );

        // Cancelled expense (should be excluded)
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Cancelled',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 1, 10),
            status: const Value('cancelled'),
          ),
        );

        final result = await service.calculateRemainingBudget();

        // Only pending expense counts
        expect(result.totalPlannedExpenses, 100000);
      });

      test('only includes planned expenses for current month', () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // January expense (should be included)
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'January',
            amountFcfa: 100000,
            expectedDate: DateTime(2026, 1, 15),
          ),
        );

        // February expense (should be excluded)
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'February',
            amountFcfa: 50000,
            expectedDate: DateTime(2026, 2, 15),
          ),
        );

        final result = await service.calculateRemainingBudget();

        // Only January expense counts
        expect(result.totalPlannedExpenses, 100000);
      });

      test('combines subscriptions and planned expenses in calculation',
          () async {
        await dao.createBudgetPeriod(
          BudgetPeriodsCompanion.insert(
            monthlyBudgetFcfa: 350000,
            startDate: DateTime(2026, 1),
            endDate: DateTime(2026, 1, 31, 23, 59, 59),
          ),
        );

        // Add subscription
        await subscriptionsDao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        // Add planned expense
        await plannedExpensesDao.createPlannedExpense(
          PlannedExpensesCompanion.insert(
            description: 'Phone',
            amountFcfa: 100000,
            expectedDate: DateTime(2026, 1, 20),
          ),
        );

        final result = await service.calculateRemainingBudget();

        expect(result.totalSubscriptions, 5000);
        expect(result.totalPlannedExpenses, 100000);
        expect(result.remainingBudget, 350000 - 5000 - 100000);
      });
    });
  });
}
