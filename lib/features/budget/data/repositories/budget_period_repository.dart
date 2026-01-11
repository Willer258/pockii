import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/budget_periods_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/clock_service.dart';

/// Repository for managing budget periods.
///
/// Handles CRUD operations and period transitions for budget periods.
/// Uses injectable Clock for testable time handling.
class BudgetPeriodRepository {
  BudgetPeriodRepository({
    required BudgetPeriodsDao budgetPeriodsDao,
    required Clock clock,
  })  : _budgetPeriodsDao = budgetPeriodsDao,
        _clock = clock;

  final BudgetPeriodsDao _budgetPeriodsDao;
  final Clock _clock;

  /// Gets the current budget period based on current time.
  ///
  /// Returns null if no period exists for the current date.
  Future<BudgetPeriod?> getCurrentPeriod() async {
    final now = _clock.now();
    return _budgetPeriodsDao.getCurrentBudgetPeriod(now);
  }

  /// Gets a budget period for a specific date.
  Future<BudgetPeriod?> getPeriodForDate(DateTime date) async {
    return _budgetPeriodsDao.getCurrentBudgetPeriod(date);
  }

  /// Gets all budget periods ordered by start date (most recent first).
  Future<List<BudgetPeriod>> getAllPeriods() async {
    return _budgetPeriodsDao.getAllBudgetPeriods();
  }

  /// Creates a new budget period for the current month.
  ///
  /// [monthlyBudget] is the total budget for the period in FCFA.
  /// Returns the ID of the created period.
  Future<int> createPeriodForCurrentMonth(int monthlyBudget) async {
    final now = _clock.now();
    final periodStart = DateTime(now.year, now.month);
    final periodEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return _budgetPeriodsDao.createBudgetPeriod(
      BudgetPeriodsCompanion.insert(
        monthlyBudgetFcfa: monthlyBudget,
        startDate: periodStart,
        endDate: periodEnd,
      ),
    );
  }

  /// Creates a budget period for a specific month.
  ///
  /// [year] and [month] specify the period.
  /// [monthlyBudget] is the total budget in FCFA.
  Future<int> createPeriodForMonth(int year, int month, int monthlyBudget) async {
    final periodStart = DateTime(year, month);
    final periodEnd = DateTime(year, month + 1, 0, 23, 59, 59);

    return _budgetPeriodsDao.createBudgetPeriod(
      BudgetPeriodsCompanion.insert(
        monthlyBudgetFcfa: monthlyBudget,
        startDate: periodStart,
        endDate: periodEnd,
      ),
    );
  }

  /// Updates the monthly budget for an existing period.
  Future<bool> updatePeriodBudget(int periodId, int newBudget) async {
    final period = await _budgetPeriodsDao.getBudgetPeriodById(periodId);
    if (period == null) return false;

    final updatedPeriod = BudgetPeriod(
      id: period.id,
      monthlyBudgetFcfa: newBudget,
      startDate: period.startDate,
      endDate: period.endDate,
      createdAt: period.createdAt,
    );

    return _budgetPeriodsDao.updateBudgetPeriod(updatedPeriod);
  }

  /// Gets the most recent period's budget amount.
  ///
  /// This is used when creating a new period to carry forward the user's
  /// configured budget. Returns null if no periods exist.
  Future<int?> getLastPeriodBudget() async {
    final periods = await _budgetPeriodsDao.getAllBudgetPeriods();
    if (periods.isEmpty) return null;
    return periods.first.monthlyBudgetFcfa;
  }

  /// Ensures a budget period exists for the current month.
  ///
  /// If no period exists:
  /// - Creates one using the previous period's budget
  /// - If no previous period, uses [defaultBudget]
  ///
  /// Returns the current period (existing or newly created).
  Future<BudgetPeriod> ensureCurrentPeriodExists({int defaultBudget = 0}) async {
    final existing = await getCurrentPeriod();
    if (existing != null) return existing;

    // Get budget from last period, or use default
    final lastBudget = await getLastPeriodBudget();
    final budgetToUse = lastBudget ?? defaultBudget;

    final periodId = await createPeriodForCurrentMonth(budgetToUse);
    final newPeriod = await _budgetPeriodsDao.getBudgetPeriodById(periodId);

    return newPeriod!;
  }

  /// Watches the current budget period for reactive updates.
  Stream<BudgetPeriod?> watchCurrentPeriod() {
    final now = _clock.now();
    return _budgetPeriodsDao.watchCurrentBudgetPeriod(now);
  }

  /// Checks if the current date has moved to a new month compared to [lastKnownDate].
  ///
  /// Returns true if we're in a different month/year than [lastKnownDate].
  bool hasMonthChanged(DateTime lastKnownDate) {
    final now = _clock.now();
    return now.year != lastKnownDate.year || now.month != lastKnownDate.month;
  }

  /// Detects potential time manipulation (clock moved backward).
  ///
  /// Returns true if the current time is before [lastRecordedTime].
  /// This indicates the device clock may have been manipulated.
  bool detectTimeInconsistency(DateTime lastRecordedTime) {
    final now = _clock.now();
    return now.isBefore(lastRecordedTime);
  }
}

/// Provider for BudgetPeriodRepository.
final budgetPeriodRepositoryProvider = Provider<BudgetPeriodRepository>((ref) {
  final budgetPeriodsDao = ref.watch(budgetPeriodsDaoProvider);
  final clock = ref.watch(clockProvider);

  return BudgetPeriodRepository(
    budgetPeriodsDao: budgetPeriodsDao,
    clock: clock,
  );
});
