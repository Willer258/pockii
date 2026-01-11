import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/presentation/widgets/category_chip_row.dart';
import '../database/daos/transactions_dao.dart';
import '../database/database_provider.dart';
import 'clock_service.dart';

/// Spending data for a single category.
class CategorySpending {
  const CategorySpending({
    required this.categoryId,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.totalAmount,
    required this.percentage,
    required this.transactionCount,
  });

  /// Category identifier.
  final String categoryId;

  /// Display label in French.
  final String categoryLabel;

  /// Material icon for this category.
  final IconData categoryIcon;

  /// Total amount spent in this category (FCFA).
  final int totalAmount;

  /// Percentage of total spending (0.0 to 1.0).
  final double percentage;

  /// Number of transactions in this category.
  final int transactionCount;
}

/// Month-over-month comparison data.
class MonthComparison {
  const MonthComparison({
    required this.currentMonthSpending,
    required this.lastMonthSpending,
    required this.hasEnoughData,
    required this.currentMonthName,
    required this.lastMonthName,
  });

  /// Spending in current month (FCFA).
  final int currentMonthSpending;

  /// Spending in last month (FCFA).
  final int lastMonthSpending;

  /// Whether there's enough data (2+ months) for comparison.
  final bool hasEnoughData;

  /// Current month name in French.
  final String currentMonthName;

  /// Last month name in French.
  final String lastMonthName;

  /// Percentage change from last month.
  /// Positive means spending increased, negative means decreased.
  double get changePercent {
    if (lastMonthSpending == 0) return 0;
    return (currentMonthSpending - lastMonthSpending) / lastMonthSpending;
  }

  /// Whether spending is lower this month (good).
  bool get isImprovement => currentMonthSpending < lastMonthSpending;

  /// Whether spending is higher this month (warning).
  bool get isWorse => currentMonthSpending > lastMonthSpending;

  /// Formatted percentage string (e.g., "+15%" or "-10%").
  String get changePercentFormatted {
    final percent = (changePercent * 100).abs().toStringAsFixed(0);
    if (changePercent > 0) return '+$percent%';
    if (changePercent < 0) return '-$percent%';
    return '0%';
  }
}

/// Income vs expenses overview data for current month.
class IncomeExpenseOverview {
  const IncomeExpenseOverview({
    required this.totalIncome,
    required this.totalExpenses,
    required this.monthName,
  });

  /// Total income for the month (FCFA).
  final int totalIncome;

  /// Total expenses for the month (FCFA).
  final int totalExpenses;

  /// Month name in French.
  final String monthName;

  /// Net balance (income - expenses).
  int get netBalance => totalIncome - totalExpenses;

  /// Whether the balance is positive (income >= expenses).
  bool get isPositive => netBalance >= 0;

  /// Whether the balance is negative (expenses > income).
  bool get isNegative => netBalance < 0;

  /// Whether there's any income recorded.
  bool get hasIncome => totalIncome > 0;

  /// Whether there's any expenses recorded.
  bool get hasExpenses => totalExpenses > 0;
}

/// Spending data for a single day of the week.
class DaySpending {
  const DaySpending({
    required this.dayIndex,
    required this.dayName,
    required this.dayShortName,
    required this.totalAmount,
    required this.averageAmount,
    required this.transactionCount,
    required this.topCategory,
    required this.topCategoryLabel,
  });

  /// Day index (1 = Monday, 7 = Sunday).
  final int dayIndex;

  /// Full day name in French.
  final String dayName;

  /// Short day name (3 letters) in French.
  final String dayShortName;

  /// Total spending on this day (FCFA).
  final int totalAmount;

  /// Average spending per occurrence of this day (FCFA).
  final int averageAmount;

  /// Number of transactions on this day.
  final int transactionCount;

  /// Top category ID for this day (null if no transactions).
  final String? topCategory;

  /// Top category label in French (null if no transactions).
  final String? topCategoryLabel;
}

/// Day-of-week spending distribution analysis.
class DayOfWeekDistribution {
  const DayOfWeekDistribution({
    required this.days,
    required this.highestDayIndex,
    required this.insightMessage,
    required this.isEvenlyDistributed,
    required this.highestToAverageRatio,
  });

  /// Spending data for each day (Monday-Sunday).
  final List<DaySpending> days;

  /// Index of the highest spending day (1-7, 0 if no data).
  final int highestDayIndex;

  /// Insight message in French.
  final String insightMessage;

  /// Whether spending is evenly distributed across days.
  final bool isEvenlyDistributed;

  /// Ratio of highest day spending to average (e.g., 2.0 means "2x more").
  final double highestToAverageRatio;

  /// Get the highest spending day.
  DaySpending? get highestDay {
    if (highestDayIndex == 0) return null;
    return days.firstWhere((d) => d.dayIndex == highestDayIndex);
  }

  /// Whether there's any spending data.
  bool get hasData => days.any((d) => d.totalAmount > 0);
}

/// French day names.
const List<String> _frenchDayNames = [
  'Lundi',
  'Mardi',
  'Mercredi',
  'Jeudi',
  'Vendredi',
  'Samedi',
  'Dimanche',
];

/// French day short names.
const List<String> _frenchDayShortNames = [
  'Lun',
  'Mar',
  'Mer',
  'Jeu',
  'Ven',
  'Sam',
  'Dim',
];

/// French month names.
const List<String> _frenchMonthNames = [
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

/// Detailed category analysis with trend.
class CategoryDetail {
  const CategoryDetail({
    required this.spending,
    required this.averagePerMonth,
    required this.trend,
    required this.monthsOfData,
  });

  /// Basic spending data.
  final CategorySpending spending;

  /// Average spending per month (FCFA).
  final int averagePerMonth;

  /// Trend indicator: 'up', 'down', or 'stable'.
  final String trend;

  /// Number of months with data for this category.
  final int monthsOfData;

  /// Trend arrow for display.
  String get trendArrow {
    switch (trend) {
      case 'up':
        return '↑';
      case 'down':
        return '↓';
      default:
        return '→';
    }
  }

  /// Trend color for display.
  Color get trendColor {
    switch (trend) {
      case 'up':
        return Colors.red;
      case 'down':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// Service for analyzing spending patterns.
///
/// Provides category breakdown, trend analysis, and spending statistics.
/// Used by the Patterns feature (FR19, UX-9).
class PatternAnalysisService {
  PatternAnalysisService({
    required TransactionsDao transactionsDao,
    required Clock clock,
  })  : _transactionsDao = transactionsDao,
        _clock = clock;

  final TransactionsDao _transactionsDao;
  final Clock _clock;

  /// Get spending breakdown by category for all time.
  ///
  /// Returns categories sorted by amount (highest first).
  /// Excludes categories with 0 spending.
  Future<List<CategorySpending>> getCategoryBreakdown() async {
    final transactions = await _transactionsDao.getAllTransactions();

    // Filter to expenses only
    final expenses =
        transactions.where((t) => t.type == 'expense').toList();

    if (expenses.isEmpty) return [];

    // Group by category and sum amounts
    final categoryTotals = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final expense in expenses) {
      final category = expense.category;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + expense.amountFcfa;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Calculate total for percentages
    final totalSpending =
        categoryTotals.values.fold<int>(0, (sum, amount) => sum + amount);

    if (totalSpending == 0) return [];

    // Build CategorySpending objects
    final result = <CategorySpending>[];

    for (final entry in categoryTotals.entries) {
      final categoryId = entry.key;
      final amount = entry.value;
      final count = categoryCounts[categoryId] ?? 0;

      // Find category metadata
      final categoryInfo = _getCategoryInfo(categoryId);

      result.add(CategorySpending(
        categoryId: categoryId,
        categoryLabel: categoryInfo.label,
        categoryIcon: categoryInfo.icon,
        totalAmount: amount,
        percentage: amount / totalSpending,
        transactionCount: count,
      ));
    }

    // Sort by amount descending
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return result;
  }

  /// Get spending breakdown for a specific month.
  Future<List<CategorySpending>> getCategoryBreakdownForMonth(
    int year,
    int month,
  ) async {
    final startOfMonth = DateTime(year, month);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = await _transactionsDao.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    // Filter to expenses only
    final expenses =
        transactions.where((t) => t.type == 'expense').toList();

    if (expenses.isEmpty) return [];

    // Group by category and sum amounts
    final categoryTotals = <String, int>{};
    final categoryCounts = <String, int>{};

    for (final expense in expenses) {
      final category = expense.category;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0) + expense.amountFcfa;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Calculate total for percentages
    final totalSpending =
        categoryTotals.values.fold<int>(0, (sum, amount) => sum + amount);

    if (totalSpending == 0) return [];

    // Build CategorySpending objects
    final result = <CategorySpending>[];

    for (final entry in categoryTotals.entries) {
      final categoryId = entry.key;
      final amount = entry.value;
      final count = categoryCounts[categoryId] ?? 0;

      // Find category metadata
      final categoryInfo = _getCategoryInfo(categoryId);

      result.add(CategorySpending(
        categoryId: categoryId,
        categoryLabel: categoryInfo.label,
        categoryIcon: categoryInfo.icon,
        totalAmount: amount,
        percentage: amount / totalSpending,
        transactionCount: count,
      ));
    }

    // Sort by amount descending
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return result;
  }

  /// Get detailed analysis for a specific category.
  ///
  /// Includes average per month and trend analysis.
  Future<CategoryDetail> getCategoryDetail(String categoryId) async {
    final transactions = await _transactionsDao.getAllTransactions();

    // Filter to expenses in this category
    final categoryExpenses = transactions
        .where((t) => t.type == 'expense' && t.category == categoryId)
        .toList();

    if (categoryExpenses.isEmpty) {
      final categoryInfo = _getCategoryInfo(categoryId);
      return CategoryDetail(
        spending: CategorySpending(
          categoryId: categoryId,
          categoryLabel: categoryInfo.label,
          categoryIcon: categoryInfo.icon,
          totalAmount: 0,
          percentage: 0,
          transactionCount: 0,
        ),
        averagePerMonth: 0,
        trend: 'stable',
        monthsOfData: 0,
      );
    }

    // Calculate total and count
    final totalAmount =
        categoryExpenses.fold<int>(0, (sum, t) => sum + t.amountFcfa);

    // Get all expenses for total percentage
    final allExpenses =
        transactions.where((t) => t.type == 'expense').toList();
    final totalSpending =
        allExpenses.fold<int>(0, (sum, t) => sum + t.amountFcfa);

    // Group by month for average calculation
    final monthlyTotals = <String, int>{};
    for (final expense in categoryExpenses) {
      final monthKey = '${expense.date.year}-${expense.date.month}';
      monthlyTotals[monthKey] =
          (monthlyTotals[monthKey] ?? 0) + expense.amountFcfa;
    }

    final monthsOfData = monthlyTotals.length;
    final averagePerMonth =
        monthsOfData > 0 ? totalAmount ~/ monthsOfData : 0;

    // Calculate trend (compare last 2 months if available)
    final trend = _calculateTrend(monthlyTotals);

    final categoryInfo = _getCategoryInfo(categoryId);

    return CategoryDetail(
      spending: CategorySpending(
        categoryId: categoryId,
        categoryLabel: categoryInfo.label,
        categoryIcon: categoryInfo.icon,
        totalAmount: totalAmount,
        percentage: totalSpending > 0 ? totalAmount / totalSpending : 0,
        transactionCount: categoryExpenses.length,
      ),
      averagePerMonth: averagePerMonth,
      trend: trend,
      monthsOfData: monthsOfData,
    );
  }

  /// Get total spending amount.
  Future<int> getTotalSpending() async {
    final transactions = await _transactionsDao.getAllTransactions();
    final expenses =
        transactions.where((t) => t.type == 'expense').toList();
    return expenses.fold<int>(0, (sum, t) => sum + t.amountFcfa);
  }

  /// Get month-over-month comparison data.
  ///
  /// Compares current month spending vs previous month.
  /// Returns [MonthComparison] with hasEnoughData=false if < 2 months of data.
  Future<MonthComparison> getMonthComparison() async {
    final now = _clock.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);

    // Get spending for both months
    final currentMonthSpending = await _getSpendingForMonth(
      currentMonth.year,
      currentMonth.month,
    );
    final lastMonthSpending = await _getSpendingForMonth(
      lastMonth.year,
      lastMonth.month,
    );

    // Check if we have data for last month
    final hasLastMonthData = await _hasDataForMonth(
      lastMonth.year,
      lastMonth.month,
    );

    return MonthComparison(
      currentMonthSpending: currentMonthSpending,
      lastMonthSpending: lastMonthSpending,
      hasEnoughData: hasLastMonthData,
      currentMonthName: _frenchMonthNames[currentMonth.month - 1],
      lastMonthName: _frenchMonthNames[lastMonth.month - 1],
    );
  }

  /// Get total spending for a specific month.
  Future<int> _getSpendingForMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = await _transactionsDao.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    final expenses = transactions.where((t) => t.type == 'expense');
    return expenses.fold<int>(0, (sum, t) => sum + t.amountFcfa);
  }

  /// Check if there's any data for a specific month.
  Future<bool> _hasDataForMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = await _transactionsDao.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    return transactions.isNotEmpty;
  }

  /// Get income vs expenses overview for current month.
  ///
  /// Shows total income, total expenses, and net balance.
  Future<IncomeExpenseOverview> getIncomeExpenseOverview() async {
    final now = _clock.now();

    final totalIncome = await _getIncomeForMonth(now.year, now.month);
    final totalExpenses = await _getSpendingForMonth(now.year, now.month);

    return IncomeExpenseOverview(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      monthName: _frenchMonthNames[now.month - 1],
    );
  }

  /// Get day-of-week spending distribution.
  ///
  /// Analyzes all expense transactions to show spending patterns by day.
  /// Returns insight message about highest spending day or even distribution.
  Future<DayOfWeekDistribution> getDayOfWeekDistribution() async {
    final transactions = await _transactionsDao.getAllTransactions();

    // Filter to expenses only
    final expenses =
        transactions.where((t) => t.type == 'expense').toList();

    // Initialize day data structures
    final dayTotals = <int, int>{};
    final dayCounts = <int, int>{};
    final dayOccurrences = <int, Set<String>>{};
    final dayCategories = <int, Map<String, int>>{};

    for (var i = 1; i <= 7; i++) {
      dayTotals[i] = 0;
      dayCounts[i] = 0;
      dayOccurrences[i] = {};
      dayCategories[i] = {};
    }

    // Analyze expenses by day of week
    for (final expense in expenses) {
      final dayIndex = expense.date.weekday; // 1 = Monday, 7 = Sunday
      final dateKey = '${expense.date.year}-${expense.date.month}-${expense.date.day}';

      dayTotals[dayIndex] = dayTotals[dayIndex]! + expense.amountFcfa;
      dayCounts[dayIndex] = dayCounts[dayIndex]! + 1;
      dayOccurrences[dayIndex]!.add(dateKey);

      // Track category spending per day
      final categorySpending = dayCategories[dayIndex]!;
      categorySpending[expense.category] =
          (categorySpending[expense.category] ?? 0) + expense.amountFcfa;
    }

    // Build DaySpending list
    final days = <DaySpending>[];
    for (var i = 1; i <= 7; i++) {
      final total = dayTotals[i]!;
      final occurrences = dayOccurrences[i]!.length;
      final average = occurrences > 0 ? total ~/ occurrences : 0;
      final count = dayCounts[i]!;

      // Find top category for this day
      String? topCategory;
      String? topCategoryLabel;
      final categories = dayCategories[i]!;
      if (categories.isNotEmpty) {
        final sorted = categories.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topCategory = sorted.first.key;
        topCategoryLabel = _getCategoryInfo(topCategory).label;
      }

      days.add(DaySpending(
        dayIndex: i,
        dayName: _frenchDayNames[i - 1],
        dayShortName: _frenchDayShortNames[i - 1],
        totalAmount: total,
        averageAmount: average,
        transactionCount: count,
        topCategory: topCategory,
        topCategoryLabel: topCategoryLabel,
      ));
    }

    // Calculate insights
    final nonZeroDays = days.where((d) => d.totalAmount > 0).toList();

    if (nonZeroDays.isEmpty) {
      return DayOfWeekDistribution(
        days: days,
        highestDayIndex: 0,
        insightMessage: 'Pas encore de donnees',
        isEvenlyDistributed: true,
        highestToAverageRatio: 0,
      );
    }

    // Find highest spending day
    final sortedByAmount = List<DaySpending>.from(nonZeroDays)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    final highestDay = sortedByAmount.first;

    // Calculate average spending across all days with data
    final totalSpending = nonZeroDays.fold<int>(0, (sum, d) => sum + d.totalAmount);
    final averagePerDay = totalSpending / nonZeroDays.length;

    // Calculate ratio of highest to average
    final ratio = averagePerDay > 0 ? highestDay.totalAmount / averagePerDay : 0.0;

    // Determine if evenly distributed (ratio < 1.5x means fairly even)
    final isEvenlyDistributed = ratio < 1.5;

    // Generate insight message
    String insightMessage;
    if (isEvenlyDistributed) {
      insightMessage = 'Tes depenses sont bien reparties dans la semaine';
    } else {
      final ratioText = ratio >= 2.0
          ? '${ratio.toStringAsFixed(0)}x plus'
          : '${(ratio * 100 - 100).toStringAsFixed(0)}% de plus';
      insightMessage = 'Tu depenses $ratioText le ${highestDay.dayName.toLowerCase()}';
    }

    return DayOfWeekDistribution(
      days: days,
      highestDayIndex: highestDay.dayIndex,
      insightMessage: insightMessage,
      isEvenlyDistributed: isEvenlyDistributed,
      highestToAverageRatio: ratio,
    );
  }

  /// Get total income for a specific month.
  Future<int> _getIncomeForMonth(int year, int month) async {
    final startOfMonth = DateTime(year, month);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    final transactions = await _transactionsDao.getTransactionsByDateRange(
      startOfMonth,
      endOfMonth,
    );

    final income = transactions.where((t) => t.type == 'income');
    return income.fold<int>(0, (sum, t) => sum + t.amountFcfa);
  }

  /// Calculate trend based on monthly data.
  String _calculateTrend(Map<String, int> monthlyTotals) {
    if (monthlyTotals.length < 2) return 'stable';

    final now = _clock.now();
    final currentMonthKey = '${now.year}-${now.month}';
    final lastMonth = DateTime(now.year, now.month - 1);
    final lastMonthKey = '${lastMonth.year}-${lastMonth.month}';

    final currentAmount = monthlyTotals[currentMonthKey] ?? 0;
    final lastAmount = monthlyTotals[lastMonthKey] ?? 0;

    if (lastAmount == 0) return 'stable';

    final changePercent = (currentAmount - lastAmount) / lastAmount;

    if (changePercent > 0.1) return 'up';
    if (changePercent < -0.1) return 'down';
    return 'stable';
  }

  /// Get category info from predefined categories.
  ExpenseCategory _getCategoryInfo(String categoryId) {
    // Check expense categories first
    for (final category in expenseCategories) {
      if (category.id == categoryId) return category;
    }

    // Check income categories (for edge cases)
    for (final category in incomeCategories) {
      if (category.id == categoryId) return category;
    }

    // Fallback for unknown categories
    return ExpenseCategory(
      id: categoryId,
      label: categoryId,
      icon: Icons.help_outline,
    );
  }
}

/// Provider for the PatternAnalysisService.
final patternAnalysisServiceProvider = Provider<PatternAnalysisService>((ref) {
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final clock = ref.watch(clockProvider);

  return PatternAnalysisService(
    transactionsDao: transactionsDao,
    clock: clock,
  );
});

/// Provider for category breakdown data.
final categoryBreakdownProvider = FutureProvider<List<CategorySpending>>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getCategoryBreakdown();
});

/// Provider for category breakdown for current month.
final currentMonthCategoryBreakdownProvider =
    FutureProvider<List<CategorySpending>>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  final clock = ref.watch(clockProvider);
  final now = clock.now();
  return service.getCategoryBreakdownForMonth(now.year, now.month);
});

/// Provider for category detail.
final categoryDetailProvider =
    FutureProvider.family<CategoryDetail, String>((ref, categoryId) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getCategoryDetail(categoryId);
});

/// Provider for total spending.
final totalSpendingProvider = FutureProvider<int>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getTotalSpending();
});

/// Provider for month-over-month comparison.
final monthComparisonProvider = FutureProvider<MonthComparison>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getMonthComparison();
});

/// Provider for income vs expenses overview.
final incomeExpenseOverviewProvider = FutureProvider<IncomeExpenseOverview>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getIncomeExpenseOverview();
});

/// Provider for day-of-week spending distribution.
final dayOfWeekDistributionProvider = FutureProvider<DayOfWeekDistribution>((ref) {
  final service = ref.watch(patternAnalysisServiceProvider);
  return service.getDayOfWeekDistribution();
});
