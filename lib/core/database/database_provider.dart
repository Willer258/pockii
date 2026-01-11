import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/clock_service.dart';
import '../services/encryption_service.dart';
import 'app_database.dart';
import 'daos/app_settings_dao.dart';
import 'daos/budget_periods_dao.dart';
import 'daos/planned_expenses_dao.dart';
import 'daos/streaks_dao.dart';
import 'daos/subscriptions_dao.dart';
import 'daos/transactions_dao.dart';

/// Provider for the encrypted database instance.
///
/// This is a FutureProvider because database initialization is async
/// (needs to retrieve encryption key from secure storage).
///
/// The database is automatically closed when the provider is disposed.
///
/// Usage:
/// ```dart
/// final dbAsync = ref.watch(databaseProvider);
/// dbAsync.when(
///   data: (db) => // use database,
///   loading: () => // show loading,
///   error: (e, s) => // handle error,
/// );
/// ```
final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final encryptionService = ref.read(encryptionServiceProvider);
  final key = await encryptionService.getOrCreateKey();
  final db = AppDatabase(encryptionKey: key);

  // Ensure database is closed when provider is disposed
  ref.onDispose(() async {
    await db.close();
  });

  return db;
});

/// Provider for the BudgetPeriodsDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
final budgetPeriodsDaoProvider = Provider<BudgetPeriodsDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return BudgetPeriodsDao(db);
});

/// Provider for the AppSettingsDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
/// Uses clockProvider for testable timestamp handling.
final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  final clock = ref.watch(clockProvider);
  return AppSettingsDao(db, clock: clock);
});

/// Provider for the TransactionsDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return TransactionsDao(db);
});

/// Provider for the SubscriptionsDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
final subscriptionsDaoProvider = Provider<SubscriptionsDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return SubscriptionsDao(db);
});

/// Provider for the PlannedExpensesDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
final plannedExpensesDaoProvider = Provider<PlannedExpensesDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  return PlannedExpensesDao(db);
});

/// Provider for the StreaksDao.
///
/// Depends on databaseProvider - will throw if database is not initialized.
/// Uses clockProvider for testable timestamp handling.
final streaksDaoProvider = Provider<StreaksDao>((ref) {
  final db = ref.watch(databaseProvider).requireValue;
  final clock = ref.watch(clockProvider);
  return StreaksDao(db, clock: clock);
});
