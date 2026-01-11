import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/core/services/pattern_analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionsDao extends Mock implements TransactionsDao {}

class MockClock extends Mock implements Clock {}

class MockTransaction extends Mock implements Transaction {}

void main() {
  late MockTransactionsDao mockTransactionsDao;
  late MockClock mockClock;
  late PatternAnalysisService service;

  setUp(() {
    mockTransactionsDao = MockTransactionsDao();
    mockClock = MockClock();

    service = PatternAnalysisService(
      transactionsDao: mockTransactionsDao,
      clock: mockClock,
    );

    when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));
  });

  Transaction _createMockTransaction({
    required int id,
    required int amount,
    required String type,
    required String category,
    required DateTime date,
  }) {
    final mock = MockTransaction();
    when(() => mock.id).thenReturn(id);
    when(() => mock.amountFcfa).thenReturn(amount);
    when(() => mock.type).thenReturn(type);
    when(() => mock.category).thenReturn(category);
    when(() => mock.date).thenReturn(date);
    return mock;
  }

  group('PatternAnalysisService', () {
    group('getCategoryBreakdown', () {
      test('returns empty list when no transactions', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => []);

        final result = await service.getCategoryBreakdown();

        expect(result, isEmpty);
      });

      test('returns empty list when only income transactions', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 50000,
                    type: 'income',
                    category: 'salary',
                    date: DateTime(2026, 1, 10),
                  ),
                ]);

        final result = await service.getCategoryBreakdown();

        expect(result, isEmpty);
      });

      test('returns category breakdown sorted by amount', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000,
                    type: 'expense',
                    category: 'transport',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 30000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 11),
                  ),
                  _createMockTransaction(
                    id: 3,
                    amount: 20000,
                    type: 'expense',
                    category: 'leisure',
                    date: DateTime(2026, 1, 12),
                  ),
                ]);

        final result = await service.getCategoryBreakdown();

        expect(result.length, equals(3));
        expect(result[0].categoryId, equals('food'));
        expect(result[0].totalAmount, equals(30000));
        expect(result[1].categoryId, equals('leisure'));
        expect(result[1].totalAmount, equals(20000));
        expect(result[2].categoryId, equals('transport'));
        expect(result[2].totalAmount, equals(10000));
      });

      test('calculates correct percentages', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 25000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 75000,
                    type: 'expense',
                    category: 'transport',
                    date: DateTime(2026, 1, 11),
                  ),
                ]);

        final result = await service.getCategoryBreakdown();

        expect(result.length, equals(2));
        expect(result[0].categoryId, equals('transport'));
        expect(result[0].percentage, closeTo(0.75, 0.01));
        expect(result[1].categoryId, equals('food'));
        expect(result[1].percentage, closeTo(0.25, 0.01));
      });

      test('aggregates multiple transactions in same category', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 15000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 11),
                  ),
                  _createMockTransaction(
                    id: 3,
                    amount: 5000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 12),
                  ),
                ]);

        final result = await service.getCategoryBreakdown();

        expect(result.length, equals(1));
        expect(result[0].categoryId, equals('food'));
        expect(result[0].totalAmount, equals(30000));
        expect(result[0].transactionCount, equals(3));
      });

      test('includes category label and icon', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000,
                    type: 'expense',
                    category: 'transport',
                    date: DateTime(2026, 1, 10),
                  ),
                ]);

        final result = await service.getCategoryBreakdown();

        expect(result[0].categoryLabel, equals('Transport'));
        expect(result[0].categoryIcon, equals(Icons.directions_car));
      });
    });

    group('getCategoryBreakdownForMonth', () {
      test('filters transactions to specified month', () async {
        when(() => mockTransactionsDao.getTransactionsByDateRange(
              any(),
              any(),
            )).thenAnswer((_) async => [
              _createMockTransaction(
                id: 1,
                amount: 20000,
                type: 'expense',
                category: 'food',
                date: DateTime(2026, 1, 15),
              ),
            ]);

        final result = await service.getCategoryBreakdownForMonth(2026, 1);

        expect(result.length, equals(1));
        expect(result[0].totalAmount, equals(20000));

        // Verify date range was called correctly
        final captured = verify(() => mockTransactionsDao.getTransactionsByDateRange(
              captureAny(),
              captureAny(),
            )).captured;

        final startDate = captured[0] as DateTime;
        final endDate = captured[1] as DateTime;

        expect(startDate.year, equals(2026));
        expect(startDate.month, equals(1));
        expect(startDate.day, equals(1));
        expect(endDate.month, equals(1));
        expect(endDate.day, equals(31));
      });
    });

    group('getCategoryDetail', () {
      test('returns zero values for category with no transactions', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => []);

        final result = await service.getCategoryDetail('food');

        expect(result.spending.totalAmount, equals(0));
        expect(result.spending.percentage, equals(0));
        expect(result.averagePerMonth, equals(0));
        expect(result.trend, equals('stable'));
        expect(result.monthsOfData, equals(0));
      });

      test('calculates average per month correctly', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 20000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2025, 12, 15),
                  ),
                ]);

        final result = await service.getCategoryDetail('food');

        expect(result.spending.totalAmount, equals(30000));
        expect(result.monthsOfData, equals(2));
        expect(result.averagePerMonth, equals(15000));
      });

      test('detects upward trend when current month higher', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 50000, // Current month - higher
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 20000, // Last month - lower
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2025, 12, 15),
                  ),
                ]);

        final result = await service.getCategoryDetail('food');

        expect(result.trend, equals('up'));
        expect(result.trendArrow, equals('↑'));
        expect(result.trendColor, equals(Colors.red));
      });

      test('detects downward trend when current month lower', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000, // Current month - lower
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 50000, // Last month - higher
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2025, 12, 15),
                  ),
                ]);

        final result = await service.getCategoryDetail('food');

        expect(result.trend, equals('down'));
        expect(result.trendArrow, equals('↓'));
        expect(result.trendColor, equals(Colors.green));
      });

      test('returns stable when change is small', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 50000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 52000, // Only ~4% difference
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2025, 12, 15),
                  ),
                ]);

        final result = await service.getCategoryDetail('food');

        expect(result.trend, equals('stable'));
        expect(result.trendArrow, equals('→'));
        expect(result.trendColor, equals(Colors.grey));
      });
    });

    group('getTotalSpending', () {
      test('returns 0 when no transactions', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => []);

        final result = await service.getTotalSpending();

        expect(result, equals(0));
      });

      test('returns sum of all expense transactions', () async {
        when(() => mockTransactionsDao.getAllTransactions())
            .thenAnswer((_) async => [
                  _createMockTransaction(
                    id: 1,
                    amount: 10000,
                    type: 'expense',
                    category: 'food',
                    date: DateTime(2026, 1, 10),
                  ),
                  _createMockTransaction(
                    id: 2,
                    amount: 20000,
                    type: 'expense',
                    category: 'transport',
                    date: DateTime(2026, 1, 11),
                  ),
                  _createMockTransaction(
                    id: 3,
                    amount: 100000,
                    type: 'income',
                    category: 'salary',
                    date: DateTime(2026, 1, 5),
                  ),
                ]);

        final result = await service.getTotalSpending();

        expect(result, equals(30000)); // Only expenses
      });
    });
  });

  group('CategorySpending', () {
    test('stores all properties correctly', () {
      const spending = CategorySpending(
        categoryId: 'food',
        categoryLabel: 'Repas',
        categoryIcon: Icons.restaurant,
        totalAmount: 50000,
        percentage: 0.5,
        transactionCount: 10,
      );

      expect(spending.categoryId, equals('food'));
      expect(spending.categoryLabel, equals('Repas'));
      expect(spending.categoryIcon, equals(Icons.restaurant));
      expect(spending.totalAmount, equals(50000));
      expect(spending.percentage, equals(0.5));
      expect(spending.transactionCount, equals(10));
    });
  });

  group('CategoryDetail', () {
    test('trendArrow returns correct symbols', () {
      expect(
        const CategoryDetail(
          spending: CategorySpending(
            categoryId: 'food',
            categoryLabel: 'Repas',
            categoryIcon: Icons.restaurant,
            totalAmount: 0,
            percentage: 0,
            transactionCount: 0,
          ),
          averagePerMonth: 0,
          trend: 'up',
          monthsOfData: 0,
        ).trendArrow,
        equals('↑'),
      );

      expect(
        const CategoryDetail(
          spending: CategorySpending(
            categoryId: 'food',
            categoryLabel: 'Repas',
            categoryIcon: Icons.restaurant,
            totalAmount: 0,
            percentage: 0,
            transactionCount: 0,
          ),
          averagePerMonth: 0,
          trend: 'down',
          monthsOfData: 0,
        ).trendArrow,
        equals('↓'),
      );

      expect(
        const CategoryDetail(
          spending: CategorySpending(
            categoryId: 'food',
            categoryLabel: 'Repas',
            categoryIcon: Icons.restaurant,
            totalAmount: 0,
            percentage: 0,
            transactionCount: 0,
          ),
          averagePerMonth: 0,
          trend: 'stable',
          monthsOfData: 0,
        ).trendArrow,
        equals('→'),
      );
    });
  });

  group('MonthComparison', () {
    test('changePercent calculates correctly', () {
      const comparison = MonthComparison(
        currentMonthSpending: 60000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.changePercent, closeTo(0.2, 0.01)); // +20%
    });

    test('changePercent returns 0 when lastMonth is 0', () {
      const comparison = MonthComparison(
        currentMonthSpending: 50000,
        lastMonthSpending: 0,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.changePercent, equals(0));
    });

    test('isImprovement returns true when spending less', () {
      const comparison = MonthComparison(
        currentMonthSpending: 40000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.isImprovement, isTrue);
      expect(comparison.isWorse, isFalse);
    });

    test('isWorse returns true when spending more', () {
      const comparison = MonthComparison(
        currentMonthSpending: 60000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.isImprovement, isFalse);
      expect(comparison.isWorse, isTrue);
    });

    test('changePercentFormatted shows positive change', () {
      const comparison = MonthComparison(
        currentMonthSpending: 60000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.changePercentFormatted, equals('+20%'));
    });

    test('changePercentFormatted shows negative change', () {
      const comparison = MonthComparison(
        currentMonthSpending: 40000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.changePercentFormatted, equals('-20%'));
    });

    test('changePercentFormatted shows 0% when no change', () {
      const comparison = MonthComparison(
        currentMonthSpending: 50000,
        lastMonthSpending: 50000,
        hasEnoughData: true,
        currentMonthName: 'Janvier',
        lastMonthName: 'Décembre',
      );

      expect(comparison.changePercentFormatted, equals('0%'));
    });
  });

  group('PatternAnalysisService getMonthComparison', () {
    test('returns not enough data when last month has no transactions',
        () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));

      // Current month has data
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 1, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 50000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 10),
            ),
          ]);

      // Last month has no data
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2025, 12, 1),
            any(),
          )).thenAnswer((_) async => []);

      final result = await service.getMonthComparison();

      expect(result.hasEnoughData, isFalse);
      expect(result.currentMonthName, equals('Janvier'));
      expect(result.lastMonthName, equals('Décembre'));
    });

    test('returns comparison data when both months have data', () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 15));

      // Current month (February)
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 2, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 40000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 2, 10),
            ),
          ]);

      // Last month (January)
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 1, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 2,
              amount: 50000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 15),
            ),
          ]);

      final result = await service.getMonthComparison();

      expect(result.hasEnoughData, isTrue);
      expect(result.currentMonthSpending, equals(40000));
      expect(result.lastMonthSpending, equals(50000));
      expect(result.currentMonthName, equals('Février'));
      expect(result.lastMonthName, equals('Janvier'));
      expect(result.isImprovement, isTrue);
    });

    test('only counts expenses, not income', () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 15));

      // Current month with mix of income and expense
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 2, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 30000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 2, 10),
            ),
            _createMockTransaction(
              id: 2,
              amount: 200000,
              type: 'income',
              category: 'salary',
              date: DateTime(2026, 2, 1),
            ),
          ]);

      // Last month
      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 1, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 3,
              amount: 50000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 15),
            ),
          ]);

      final result = await service.getMonthComparison();

      expect(result.currentMonthSpending, equals(30000)); // Only expense
      expect(result.lastMonthSpending, equals(50000));
    });
  });

  group('IncomeExpenseOverview', () {
    test('netBalance calculates correctly', () {
      const overview = IncomeExpenseOverview(
        totalIncome: 200000,
        totalExpenses: 150000,
        monthName: 'Janvier',
      );

      expect(overview.netBalance, equals(50000));
    });

    test('netBalance is negative when expenses exceed income', () {
      const overview = IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 150000,
        monthName: 'Janvier',
      );

      expect(overview.netBalance, equals(-50000));
    });

    test('isPositive returns true when income >= expenses', () {
      const positive = IncomeExpenseOverview(
        totalIncome: 200000,
        totalExpenses: 150000,
        monthName: 'Janvier',
      );

      const equal = IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 100000,
        monthName: 'Janvier',
      );

      expect(positive.isPositive, isTrue);
      expect(positive.isNegative, isFalse);
      expect(equal.isPositive, isTrue);
    });

    test('isNegative returns true when expenses > income', () {
      const negative = IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 150000,
        monthName: 'Janvier',
      );

      expect(negative.isNegative, isTrue);
      expect(negative.isPositive, isFalse);
    });

    test('hasIncome returns true when totalIncome > 0', () {
      const withIncome = IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 0,
        monthName: 'Janvier',
      );

      const noIncome = IncomeExpenseOverview(
        totalIncome: 0,
        totalExpenses: 50000,
        monthName: 'Janvier',
      );

      expect(withIncome.hasIncome, isTrue);
      expect(noIncome.hasIncome, isFalse);
    });

    test('hasExpenses returns true when totalExpenses > 0', () {
      const withExpenses = IncomeExpenseOverview(
        totalIncome: 0,
        totalExpenses: 50000,
        monthName: 'Janvier',
      );

      const noExpenses = IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 0,
        monthName: 'Janvier',
      );

      expect(withExpenses.hasExpenses, isTrue);
      expect(noExpenses.hasExpenses, isFalse);
    });
  });

  group('PatternAnalysisService getIncomeExpenseOverview', () {
    test('returns overview with correct values for current month', () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));

      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 1, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 200000,
              type: 'income',
              category: 'salary',
              date: DateTime(2026, 1, 5),
            ),
            _createMockTransaction(
              id: 2,
              amount: 50000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 10),
            ),
            _createMockTransaction(
              id: 3,
              amount: 30000,
              type: 'expense',
              category: 'transport',
              date: DateTime(2026, 1, 12),
            ),
          ]);

      final result = await service.getIncomeExpenseOverview();

      expect(result.totalIncome, equals(200000));
      expect(result.totalExpenses, equals(80000));
      expect(result.monthName, equals('Janvier'));
      expect(result.netBalance, equals(120000));
      expect(result.isPositive, isTrue);
    });

    test('returns 0 values when no transactions', () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));

      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 1, 1),
            any(),
          )).thenAnswer((_) async => []);

      final result = await service.getIncomeExpenseOverview();

      expect(result.totalIncome, equals(0));
      expect(result.totalExpenses, equals(0));
      expect(result.monthName, equals('Janvier'));
      expect(result.hasIncome, isFalse);
      expect(result.hasExpenses, isFalse);
    });

    test('returns negative balance when expenses exceed income', () async {
      when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 15));

      when(() => mockTransactionsDao.getTransactionsByDateRange(
            DateTime(2026, 2, 1),
            any(),
          )).thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 50000,
              type: 'income',
              category: 'bonus',
              date: DateTime(2026, 2, 5),
            ),
            _createMockTransaction(
              id: 2,
              amount: 100000,
              type: 'expense',
              category: 'rent',
              date: DateTime(2026, 2, 1),
            ),
          ]);

      final result = await service.getIncomeExpenseOverview();

      expect(result.totalIncome, equals(50000));
      expect(result.totalExpenses, equals(100000));
      expect(result.monthName, equals('Février'));
      expect(result.netBalance, equals(-50000));
      expect(result.isNegative, isTrue);
    });
  });

  group('DaySpending', () {
    test('stores all properties correctly', () {
      const day = DaySpending(
        dayIndex: 1,
        dayName: 'Lundi',
        dayShortName: 'Lun',
        totalAmount: 50000,
        averageAmount: 25000,
        transactionCount: 5,
        topCategory: 'food',
        topCategoryLabel: 'Repas',
      );

      expect(day.dayIndex, equals(1));
      expect(day.dayName, equals('Lundi'));
      expect(day.dayShortName, equals('Lun'));
      expect(day.totalAmount, equals(50000));
      expect(day.averageAmount, equals(25000));
      expect(day.transactionCount, equals(5));
      expect(day.topCategory, equals('food'));
      expect(day.topCategoryLabel, equals('Repas'));
    });

    test('handles null category', () {
      const day = DaySpending(
        dayIndex: 2,
        dayName: 'Mardi',
        dayShortName: 'Mar',
        totalAmount: 0,
        averageAmount: 0,
        transactionCount: 0,
        topCategory: null,
        topCategoryLabel: null,
      );

      expect(day.topCategory, isNull);
      expect(day.topCategoryLabel, isNull);
    });
  });

  group('DayOfWeekDistribution', () {
    List<DaySpending> createTestDays({int highestIndex = 5}) {
      return List.generate(7, (i) {
        final index = i + 1;
        return DaySpending(
          dayIndex: index,
          dayName: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][i],
          dayShortName: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][i],
          totalAmount: index == highestIndex ? 100000 : 20000,
          averageAmount: index == highestIndex ? 50000 : 10000,
          transactionCount: index == highestIndex ? 10 : 2,
          topCategory: 'food',
          topCategoryLabel: 'Repas',
        );
      });
    }

    test('highestDay returns correct day', () {
      final distribution = DayOfWeekDistribution(
        days: createTestDays(highestIndex: 5),
        highestDayIndex: 5,
        insightMessage: 'Tu depenses 2x plus le vendredi',
        isEvenlyDistributed: false,
        highestToAverageRatio: 2.0,
      );

      expect(distribution.highestDay, isNotNull);
      expect(distribution.highestDay!.dayIndex, equals(5));
      expect(distribution.highestDay!.dayName, equals('Vendredi'));
    });

    test('highestDay returns null when no data', () {
      final emptyDays = List.generate(7, (i) => DaySpending(
        dayIndex: i + 1,
        dayName: 'Day',
        dayShortName: 'D',
        totalAmount: 0,
        averageAmount: 0,
        transactionCount: 0,
        topCategory: null,
        topCategoryLabel: null,
      ));

      final distribution = DayOfWeekDistribution(
        days: emptyDays,
        highestDayIndex: 0,
        insightMessage: 'Pas encore de donnees',
        isEvenlyDistributed: true,
        highestToAverageRatio: 0,
      );

      expect(distribution.highestDay, isNull);
    });

    test('hasData returns true when any day has spending', () {
      final distribution = DayOfWeekDistribution(
        days: createTestDays(),
        highestDayIndex: 5,
        insightMessage: 'Test',
        isEvenlyDistributed: false,
        highestToAverageRatio: 2.0,
      );

      expect(distribution.hasData, isTrue);
    });

    test('hasData returns false when no spending', () {
      final emptyDays = List.generate(7, (i) => DaySpending(
        dayIndex: i + 1,
        dayName: 'Day',
        dayShortName: 'D',
        totalAmount: 0,
        averageAmount: 0,
        transactionCount: 0,
        topCategory: null,
        topCategoryLabel: null,
      ));

      final distribution = DayOfWeekDistribution(
        days: emptyDays,
        highestDayIndex: 0,
        insightMessage: 'Pas encore de donnees',
        isEvenlyDistributed: true,
        highestToAverageRatio: 0,
      );

      expect(distribution.hasData, isFalse);
    });
  });

  group('PatternAnalysisService getDayOfWeekDistribution', () {
    test('returns no data message when no expenses', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => []);

      final result = await service.getDayOfWeekDistribution();

      expect(result.hasData, isFalse);
      expect(result.insightMessage, equals('Pas encore de donnees'));
      expect(result.highestDayIndex, equals(0));
    });

    test('returns distribution with highest day highlighted', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => [
            // Monday: 10K (Jan 5, 2026 is Monday)
            _createMockTransaction(
              id: 1,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 5), // Monday
            ),
            // Friday: 50K (Jan 9, 2026 is Friday)
            _createMockTransaction(
              id: 2,
              amount: 30000,
              type: 'expense',
              category: 'leisure',
              date: DateTime(2026, 1, 9), // Friday
            ),
            _createMockTransaction(
              id: 3,
              amount: 20000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 9), // Friday
            ),
          ]);

      final result = await service.getDayOfWeekDistribution();

      expect(result.hasData, isTrue);
      expect(result.highestDayIndex, equals(5)); // Friday
      expect(result.days.length, equals(7));
      expect(result.days[4].totalAmount, equals(50000)); // Friday (index 4)
      expect(result.days[0].totalAmount, equals(10000)); // Monday (index 0)
    });

    test('identifies top category per day', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 30000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 5), // Monday
            ),
            _createMockTransaction(
              id: 2,
              amount: 10000,
              type: 'expense',
              category: 'transport',
              date: DateTime(2026, 1, 5), // Monday
            ),
          ]);

      final result = await service.getDayOfWeekDistribution();

      expect(result.days[0].topCategory, equals('food'));
    });

    test('shows evenly distributed message when ratio < 1.5', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 5), // Monday
            ),
            _createMockTransaction(
              id: 2,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 6), // Tuesday
            ),
            _createMockTransaction(
              id: 3,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 7), // Wednesday
            ),
          ]);

      final result = await service.getDayOfWeekDistribution();

      expect(result.isEvenlyDistributed, isTrue);
      expect(result.insightMessage, contains('bien reparties'));
    });

    test('shows insight message with ratio when pattern exists', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => [
            // Monday: 10K (Jan 5, 2026 is Monday)
            _createMockTransaction(
              id: 1,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 5), // Monday
            ),
            // Friday: 30K (Jan 9, 2026 is Friday)
            _createMockTransaction(
              id: 2,
              amount: 30000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 9), // Friday
            ),
          ]);

      final result = await service.getDayOfWeekDistribution();

      expect(result.isEvenlyDistributed, isFalse);
      expect(result.insightMessage, contains('vendredi'));
    });

    test('excludes income transactions', () async {
      when(() => mockTransactionsDao.getAllTransactions())
          .thenAnswer((_) async => [
            _createMockTransaction(
              id: 1,
              amount: 200000,
              type: 'income',
              category: 'salary',
              date: DateTime(2026, 1, 5), // Monday
            ),
            _createMockTransaction(
              id: 2,
              amount: 10000,
              type: 'expense',
              category: 'food',
              date: DateTime(2026, 1, 9), // Friday
            ),
          ]);

      final result = await service.getDayOfWeekDistribution();

      expect(result.days[0].totalAmount, equals(0)); // Monday has only income
      expect(result.days[4].totalAmount, equals(10000)); // Friday has expense
    });
  });
}
