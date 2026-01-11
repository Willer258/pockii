import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';
import '../database/daos/budget_periods_dao.dart';
import '../database/daos/subscriptions_dao.dart';
import '../database/daos/transactions_dao.dart';
import '../database/database_provider.dart';
import 'clock_service.dart';

/// Storage keys for month-end summary.
abstract class MonthSummaryKeys {
  static const lastDismissedMonth = 'month_summary_last_dismissed';
}

/// Data model for month-end summary.
class MonthSummary {
  const MonthSummary({
    required this.month,
    required this.year,
    required this.monthlyBudget,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalSubscriptions,
    required this.remainingBudget,
    required this.topCategory,
    required this.topCategoryAmount,
  });

  final int month;
  final int year;
  final int monthlyBudget;
  final int totalIncome;
  final int totalExpenses;
  final int totalSubscriptions;
  final int remainingBudget;
  final String? topCategory;
  final int topCategoryAmount;

  /// The month name in French.
  String get monthName {
    const months = [
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
    return months[month - 1];
  }

  /// Whether the budget ended in surplus.
  bool get isPositive => remainingBudget >= 0;

  /// Total spent (expenses + subscriptions).
  int get totalSpent => totalExpenses + totalSubscriptions;
}

/// Service for month-end summary calculations.
///
/// Provides summary data for the last day of the month and tracks
/// whether the user has dismissed the summary.
///
/// Covers: FR55, Story 4.9
class MonthSummaryService {
  MonthSummaryService({
    required AppSettingsDao settingsDao,
    required TransactionsDao transactionsDao,
    required BudgetPeriodsDao budgetPeriodsDao,
    required SubscriptionsDao subscriptionsDao,
    required Clock clock,
  })  : _settingsDao = settingsDao,
        _transactionsDao = transactionsDao,
        _budgetPeriodsDao = budgetPeriodsDao,
        _subscriptionsDao = subscriptionsDao,
        _clock = clock;

  final AppSettingsDao _settingsDao;
  final TransactionsDao _transactionsDao;
  final BudgetPeriodsDao _budgetPeriodsDao;
  final SubscriptionsDao _subscriptionsDao;
  final Clock _clock;

  /// Check if today is the last day of the month.
  bool isLastDayOfMonth() {
    final now = _clock.now();
    final tomorrow = now.add(const Duration(days: 1));
    return tomorrow.month != now.month;
  }

  /// Check if the summary should be shown.
  ///
  /// Returns true if:
  /// - It's the last day of the month (or last 2 days for flexibility)
  /// - The user hasn't dismissed the summary for this month
  Future<bool> shouldShowSummary() async {
    final now = _clock.now();

    // Check if we're in the last 2 days of the month
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final isEndOfMonth = now.day >= daysInMonth - 1;

    if (!isEndOfMonth) return false;

    // Check if already dismissed this month
    final dismissed = await _isDismissedThisMonth();
    return !dismissed;
  }

  /// Mark the summary as dismissed for this month.
  Future<void> dismissSummary() async {
    final now = _clock.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await _settingsDao.setValue(MonthSummaryKeys.lastDismissedMonth, monthKey);
  }

  /// Get the month-end summary data.
  Future<MonthSummary?> getSummary() async {
    final now = _clock.now();

    // Get budget period
    final budgetPeriod = await _budgetPeriodsDao.getCurrentBudgetPeriod(now);
    if (budgetPeriod == null) return null;

    // Get transactions for the month
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final transactions = await _transactionsDao.getTransactionsByDateRange(
      monthStart,
      monthEnd,
    );

    // Calculate totals
    var totalIncome = 0;
    var totalExpenses = 0;
    final categoryTotals = <String, int>{};

    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amountFcfa;
      } else {
        totalExpenses += tx.amountFcfa;
        // Track category totals for expenses
        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amountFcfa;
      }
    }

    // Get subscriptions total
    final subscriptions = await _subscriptionsDao.getActiveSubscriptions();
    var totalSubscriptions = 0;
    for (final sub in subscriptions) {
      if (sub.frequency == 'monthly') {
        totalSubscriptions += sub.amountFcfa;
      } else if (sub.frequency == 'weekly') {
        totalSubscriptions += sub.amountFcfa * 4;
      } else if (sub.frequency == 'yearly') {
        totalSubscriptions += (sub.amountFcfa / 12).round();
      }
    }

    // Find top category
    String? topCategory;
    var topCategoryAmount = 0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > topCategoryAmount) {
        topCategory = entry.key;
        topCategoryAmount = entry.value;
      }
    }

    // Calculate remaining
    final remaining = budgetPeriod.monthlyBudgetFcfa +
        totalIncome -
        totalExpenses -
        totalSubscriptions;

    return MonthSummary(
      month: now.month,
      year: now.year,
      monthlyBudget: budgetPeriod.monthlyBudgetFcfa,
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      totalSubscriptions: totalSubscriptions,
      remainingBudget: remaining,
      topCategory: topCategory,
      topCategoryAmount: topCategoryAmount,
    );
  }

  Future<bool> _isDismissedThisMonth() async {
    final now = _clock.now();
    final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final dismissed =
        await _settingsDao.getValue(MonthSummaryKeys.lastDismissedMonth);
    return dismissed == currentMonthKey;
  }
}

/// Provider for the MonthSummaryService.
final monthSummaryServiceProvider = Provider<MonthSummaryService>((ref) {
  final settingsDao = ref.watch(appSettingsDaoProvider);
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final budgetPeriodsDao = ref.watch(budgetPeriodsDaoProvider);
  final subscriptionsDao = ref.watch(subscriptionsDaoProvider);
  final clock = ref.watch(clockProvider);

  return MonthSummaryService(
    settingsDao: settingsDao,
    transactionsDao: transactionsDao,
    budgetPeriodsDao: budgetPeriodsDao,
    subscriptionsDao: subscriptionsDao,
    clock: clock,
  );
});

/// Provider for whether to show the month-end summary.
final shouldShowMonthSummaryProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(monthSummaryServiceProvider);
  return service.shouldShowSummary();
});

/// Provider for the month-end summary data.
final monthSummaryProvider = FutureProvider<MonthSummary?>((ref) {
  final service = ref.watch(monthSummaryServiceProvider);
  return service.getSummary();
});
