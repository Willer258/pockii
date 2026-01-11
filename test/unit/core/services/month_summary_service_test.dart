import 'package:accountapp/core/database/daos/app_settings_dao.dart';
import 'package:accountapp/core/database/daos/budget_periods_dao.dart';
import 'package:accountapp/core/database/daos/subscriptions_dao.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/core/services/month_summary_service.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

class MockTransactionsDao extends Mock implements TransactionsDao {}

class MockBudgetPeriodsDao extends Mock implements BudgetPeriodsDao {}

class MockSubscriptionsDao extends Mock implements SubscriptionsDao {}

class MockClock extends Mock implements Clock {}

// Fake classes for Value
class FakeBudgetPeriod {
  final int id;
  final int monthlyBudgetFcfa;
  final int year;
  final int month;

  FakeBudgetPeriod({
    required this.id,
    required this.monthlyBudgetFcfa,
    required this.year,
    required this.month,
  });
}

class FakeTransaction {
  final int id;
  final int amountFcfa;
  final String type;
  final String category;
  final DateTime date;

  FakeTransaction({
    required this.id,
    required this.amountFcfa,
    required this.type,
    required this.category,
    required this.date,
  });
}

class FakeSubscription {
  final int id;
  final String name;
  final int amountFcfa;
  final String frequency;

  FakeSubscription({
    required this.id,
    required this.name,
    required this.amountFcfa,
    required this.frequency,
  });
}

void main() {
  late MockAppSettingsDao mockSettingsDao;
  late MockTransactionsDao mockTransactionsDao;
  late MockBudgetPeriodsDao mockBudgetPeriodsDao;
  late MockSubscriptionsDao mockSubscriptionsDao;
  late MockClock mockClock;
  late MonthSummaryService service;

  setUp(() {
    mockSettingsDao = MockAppSettingsDao();
    mockTransactionsDao = MockTransactionsDao();
    mockBudgetPeriodsDao = MockBudgetPeriodsDao();
    mockSubscriptionsDao = MockSubscriptionsDao();
    mockClock = MockClock();

    service = MonthSummaryService(
      settingsDao: mockSettingsDao,
      transactionsDao: mockTransactionsDao,
      budgetPeriodsDao: mockBudgetPeriodsDao,
      subscriptionsDao: mockSubscriptionsDao,
      clock: mockClock,
    );

    // Default: no dismissed month
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any())).thenAnswer((_) async => 1);
  });

  group('MonthSummaryService', () {
    group('isLastDayOfMonth', () {
      test('returns true on last day of month', () {
        // January 31st
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 31));

        final result = service.isLastDayOfMonth();

        expect(result, isTrue);
      });

      test('returns false on non-last day', () {
        // January 15th
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));

        final result = service.isLastDayOfMonth();

        expect(result, isFalse);
      });

      test('handles February correctly', () {
        // February 28th (non-leap year)
        when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 28));

        final result = service.isLastDayOfMonth();

        expect(result, isTrue);
      });

      test('handles leap year February', () {
        // February 29th (leap year 2024)
        when(() => mockClock.now()).thenReturn(DateTime(2024, 2, 29));

        final result = service.isLastDayOfMonth();

        expect(result, isTrue);
      });
    });

    group('shouldShowSummary', () {
      test('returns false when not end of month', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));

        final result = await service.shouldShowSummary();

        expect(result, isFalse);
      });

      test('returns true on last day when not dismissed', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 31));

        final result = await service.shouldShowSummary();

        expect(result, isTrue);
      });

      test('returns true on second to last day', () async {
        // January 30th (31 days in January, so this is 2nd to last)
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 30));

        final result = await service.shouldShowSummary();

        expect(result, isTrue);
      });

      test('returns false when already dismissed this month', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 31));
        when(() => mockSettingsDao.getValue(MonthSummaryKeys.lastDismissedMonth))
            .thenAnswer((_) async => '2026-01');

        final result = await service.shouldShowSummary();

        expect(result, isFalse);
      });

      test('returns true when dismissed different month', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 28));
        when(() => mockSettingsDao.getValue(MonthSummaryKeys.lastDismissedMonth))
            .thenAnswer((_) async => '2026-01');

        final result = await service.shouldShowSummary();

        expect(result, isTrue);
      });
    });

    group('dismissSummary', () {
      test('saves current month key', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 31));

        await service.dismissSummary();

        verify(() => mockSettingsDao.setValue(
              MonthSummaryKeys.lastDismissedMonth,
              '2026-01',
            )).called(1);
      });

      test('pads single digit month', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 3, 31));

        await service.dismissSummary();

        verify(() => mockSettingsDao.setValue(
              MonthSummaryKeys.lastDismissedMonth,
              '2026-03',
            )).called(1);
      });
    });
  });

  group('MonthSummary', () {
    test('monthName returns correct French month', () {
      final summary = MonthSummary(
        month: 1,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 0,
        totalSubscriptions: 0,
        remainingBudget: 300000,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.monthName, equals('Janvier'));
    });

    test('monthName returns December correctly', () {
      final summary = MonthSummary(
        month: 12,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 0,
        totalSubscriptions: 0,
        remainingBudget: 300000,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.monthName, equals('Décembre'));
    });

    test('isPositive returns true for positive balance', () {
      final summary = MonthSummary(
        month: 1,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 100000,
        totalSubscriptions: 50000,
        remainingBudget: 150000,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.isPositive, isTrue);
    });

    test('isPositive returns true for zero balance', () {
      final summary = MonthSummary(
        month: 1,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 300000,
        totalSubscriptions: 0,
        remainingBudget: 0,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.isPositive, isTrue);
    });

    test('isPositive returns false for negative balance', () {
      final summary = MonthSummary(
        month: 1,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 350000,
        totalSubscriptions: 0,
        remainingBudget: -50000,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.isPositive, isFalse);
    });

    test('totalSpent combines expenses and subscriptions', () {
      final summary = MonthSummary(
        month: 1,
        year: 2026,
        monthlyBudget: 300000,
        totalIncome: 0,
        totalExpenses: 100000,
        totalSubscriptions: 50000,
        remainingBudget: 150000,
        topCategory: null,
        topCategoryAmount: 0,
      );

      expect(summary.totalSpent, equals(150000));
    });
  });

  group('MonthSummaryKeys', () {
    test('lastDismissedMonth key is defined', () {
      expect(MonthSummaryKeys.lastDismissedMonth, equals('month_summary_last_dismissed'));
    });
  });
}
