import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

/// Service for simulating 3 months of app usage data.
///
/// Creates realistic transactions, subscriptions, planned expenses,
/// and savings projects to demonstrate the app's features.
class SimulationService {
  SimulationService(this._db);

  final AppDatabase _db;
  final _random = Random(42); // Fixed seed for reproducibility

  /// Monthly budget for simulation (150,000 FCFA).
  static const int monthlyBudget = 150000;

  /// Run the complete simulation.
  Future<void> runSimulation() async {
    // Clear existing data first
    await _clearAllData();

    // Get dates for 3 months
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);

    // Create budget periods for 3 months
    await _createBudgetPeriods(threeMonthsAgo, now);

    // Create subscriptions (recurring expenses)
    await _createSubscriptions();

    // Create transactions for each month
    await _createTransactions(threeMonthsAgo, now);

    // Create planned expenses
    await _createPlannedExpenses(now);

    // Create savings projects with contributions
    await _createSavingsProjects(threeMonthsAgo, now);

    // Create user streak
    await _createUserStreak(now);

    // Enable budget rules
    await _enableBudgetRules();
  }

  /// Clear all existing data.
  Future<void> _clearAllData() async {
    await _db.delete(_db.transactions).go();
    await _db.delete(_db.subscriptions).go();
    await _db.delete(_db.plannedExpenses).go();
    await _db.delete(_db.projectContributions).go();
    await _db.delete(_db.savingsProjects).go();
    await _db.delete(_db.budgetPeriods).go();
    await _db.delete(_db.userStreaks).go();
  }

  /// Create budget periods for each month.
  Future<void> _createBudgetPeriods(DateTime start, DateTime end) async {
    var current = DateTime(start.year, start.month, 1);

    while (current.isBefore(end) || current.month == end.month) {
      final periodEnd = DateTime(current.year, current.month + 1, 0);

      await _db.into(_db.budgetPeriods).insert(
        BudgetPeriodsCompanion.insert(
          monthlyBudgetFcfa: monthlyBudget,
          startDate: current,
          endDate: periodEnd,
        ),
      );

      current = DateTime(current.year, current.month + 1, 1);
      if (current.isAfter(end)) break;
    }
  }

  /// Create realistic subscriptions.
  Future<void> _createSubscriptions() async {
    final subscriptions = [
      ('Netflix', 6500, 'entertainment', 'monthly', 5),
      ('Orange Internet', 15000, 'utilities', 'monthly', 1),
      ('Salle de sport', 25000, 'health', 'monthly', 1),
      ('Spotify', 3500, 'entertainment', 'monthly', 10),
      ('Tontine famille', 10000, 'family', 'monthly', 15),
      ('Assurance moto', 5000, 'transport', 'monthly', 20),
    ];

    for (final (name, amount, category, frequency, dueDay) in subscriptions) {
      await _db.into(_db.subscriptions).insert(
        SubscriptionsCompanion.insert(
          name: name,
          amountFcfa: amount,
          category: category,
          frequency: frequency,
          dueDay: dueDay,
        ),
      );
    }
  }

  /// Create transactions spread across 3 months.
  Future<void> _createTransactions(DateTime start, DateTime end) async {
    var current = DateTime(start.year, start.month, 1);

    while (current.isBefore(end) || current.month == end.month) {
      await _createMonthTransactions(current);
      current = DateTime(current.year, current.month + 1, 1);
      if (current.isAfter(end)) break;
    }
  }

  /// Create transactions for a single month.
  Future<void> _createMonthTransactions(DateTime month) async {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Regular expenses patterns
    final expensePatterns = [
      // Daily/frequent expenses
      ('Transport taxi', 'transport', 1500, 3500, 15, 25),
      ('Petit déjeuner', 'food', 500, 1500, 20, 28),
      ('Déjeuner', 'food', 1500, 4000, 18, 25),
      ('Courses marché', 'food', 5000, 15000, 4, 6),

      // Weekly expenses
      ('Carburant moto', 'transport', 3000, 7000, 3, 5),
      ('Loisirs/sorties', 'entertainment', 5000, 15000, 2, 4),

      // Monthly expenses
      ('Coiffeur', 'personal', 2000, 5000, 1, 2),
      ('Vêtements', 'shopping', 10000, 30000, 0, 2),
      ('Pharmacie', 'health', 2000, 8000, 0, 2),
      ('Cadeaux', 'gifts', 5000, 20000, 0, 1),
      ('Restaurant', 'food', 8000, 20000, 1, 3),
      ('Crédit téléphone', 'utilities', 2000, 5000, 2, 4),
    ];

    for (final (name, category, minAmount, maxAmount, minCount, maxCount) in expensePatterns) {
      final count = _randomInt(minCount, maxCount);
      for (var i = 0; i < count; i++) {
        final day = _randomInt(1, daysInMonth);
        final amount = _randomInt(minAmount ~/ 100, maxAmount ~/ 100) * 100;
        final date = DateTime(month.year, month.month, day, _randomInt(8, 20));

        await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            amountFcfa: amount,
            category: category,
            type: 'expense',
            note: Value(name),
            date: date,
          ),
        );
      }
    }

    // Add some income (salary at beginning of month)
    if (_randomInt(0, 10) > 2) {
      await _db.into(_db.transactions).insert(
        TransactionsCompanion.insert(
          amountFcfa: 180000 + _randomInt(-20000, 30000),
          category: 'salary',
          type: 'income',
          note: const Value('Salaire'),
          date: DateTime(month.year, month.month, _randomInt(1, 5)),
        ),
      );
    }

    // Occasional income
    if (_randomInt(0, 10) > 7) {
      await _db.into(_db.transactions).insert(
        TransactionsCompanion.insert(
          amountFcfa: _randomInt(10000, 50000),
          category: 'other',
          type: 'income',
          note: const Value('Bonus / Prime'),
          date: DateTime(month.year, month.month, _randomInt(10, 25)),
        ),
      );
    }
  }

  /// Create planned expenses.
  Future<void> _createPlannedExpenses(DateTime now) async {
    final plannedExpenses = [
      ('Anniversaire maman', 25000, 15, 'gifts'),
      ('Réparation moto', 45000, 20, 'transport'),
      ('Nouveau téléphone', 150000, 45, 'shopping'),
      ('Frais de scolarité', 75000, 30, 'education'),
    ];

    for (final (description, amount, daysFromNow, category) in plannedExpenses) {
      await _db.into(_db.plannedExpenses).insert(
        PlannedExpensesCompanion.insert(
          description: description,
          amountFcfa: amount,
          expectedDate: now.add(Duration(days: daysFromNow)),
          category: Value(category),
        ),
      );
    }
  }

  /// Create savings projects with contributions.
  Future<void> _createSavingsProjects(DateTime start, DateTime now) async {
    final projects = [
      (
        'Voyage Dakar',
        'travel',
        500000,
        185000,
        '🏖️',
        '2196F3',
        DateTime(now.year, now.month + 4, 15),
        [
          (50000, start),
          (50000, DateTime(start.year, start.month + 1, 5)),
          (50000, DateTime(start.year, start.month + 2, 3)),
          (35000, DateTime(now.year, now.month, 2)),
        ],
      ),
      (
        'iPhone 15',
        'tech',
        750000,
        320000,
        '📱',
        '9C27B0',
        DateTime(now.year, now.month + 6, 1),
        [
          (100000, start),
          (80000, DateTime(start.year, start.month + 1, 10)),
          (70000, DateTime(start.year, start.month + 2, 8)),
          (70000, DateTime(now.year, now.month, 5)),
        ],
      ),
      (
        'Cadeau mariage Kofi',
        'gift',
        100000,
        75000,
        '🎁',
        'E91E63',
        DateTime(now.year, now.month + 1, 20),
        [
          (25000, start),
          (25000, DateTime(start.year, start.month + 1, 15)),
          (25000, DateTime(start.year, start.month + 2, 12)),
        ],
      ),
      (
        'Fonds urgence',
        'other',
        300000,
        95000,
        '🛡️',
        '4CAF50',
        null,
        [
          (30000, start),
          (25000, DateTime(start.year, start.month + 1, 20)),
          (20000, DateTime(start.year, start.month + 2, 18)),
          (20000, DateTime(now.year, now.month, 8)),
        ],
      ),
    ];

    for (final (name, category, target, current, emoji, color, targetDate, contributions) in projects) {
      // Insert project
      final projectId = await _db.into(_db.savingsProjects).insert(
        SavingsProjectsCompanion.insert(
          name: name,
          category: category,
          targetAmountFcfa: target,
          currentAmountFcfa: Value(current),
          emoji: Value(emoji),
          color: Value(color),
          targetDate: Value(targetDate),
        ),
      );

      // Insert contributions
      for (final (amount, date) in contributions) {
        await _db.into(_db.projectContributions).insert(
          ProjectContributionsCompanion.insert(
            projectId: projectId,
            amountFcfa: amount,
            type: 'deposit',
            date: Value(date),
          ),
        );
      }
    }
  }

  /// Create user streak data.
  Future<void> _createUserStreak(DateTime now) async {
    await _db.into(_db.userStreaks).insert(
      UserStreaksCompanion.insert(
        currentStreak: const Value(12),
        longestStreak: const Value(18),
        lastActivityDate: Value(now),
      ),
    );
  }

  /// Enable budget rules in settings.
  Future<void> _enableBudgetRules() async {
    // Enable 50/30/20 rule
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'budget_rule_enabled',
        value: 'true',
      ),
    );

    // Set emergency fund settings
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'emergency_fund_enabled',
        value: 'true',
      ),
    );
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'emergency_fund_salary',
        value: '180000',
      ),
    );
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'emergency_fund_current',
        value: '95000',
      ),
    );
    await _db.into(_db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(
        key: 'emergency_fund_target_months',
        value: '6',
      ),
    );
  }

  int _randomInt(int min, int max) {
    if (min >= max) return min;
    return min + _random.nextInt(max - min + 1);
  }
}

/// Provider for SimulationService.
final simulationServiceProvider = Provider<SimulationService>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return SimulationService(db);
});
