import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';
import '../database/daos/transactions_dao.dart';
import '../database/database_provider.dart';
import 'clock_service.dart';

/// Storage keys for pattern unlock tracking.
abstract class PatternUnlockKeys {
  /// Key for tracking if unlock celebration has been shown.
  static const celebrationShown = 'pattern_unlock_celebration_shown';
}

/// Days required to unlock the patterns feature.
const int patternUnlockDaysRequired = 30;

/// Service for managing pattern feature unlock logic.
///
/// The patterns feature unlocks after 30 days of transaction history,
/// giving users enough data for meaningful insights.
///
/// Covers: FR18, Story 5.1
class PatternUnlockService {
  PatternUnlockService({
    required TransactionsDao transactionsDao,
    required AppSettingsDao settingsDao,
    required Clock clock,
  })  : _transactionsDao = transactionsDao,
        _settingsDao = settingsDao,
        _clock = clock;

  final TransactionsDao _transactionsDao;
  final AppSettingsDao _settingsDao;
  final Clock _clock;

  /// Check if the patterns feature is unlocked.
  ///
  /// Returns true if user has ≥30 days of transaction history.
  Future<bool> isUnlocked() async {
    final daysWithData = await getDaysWithData();
    return daysWithData >= patternUnlockDaysRequired;
  }

  /// Get the number of days remaining until unlock.
  ///
  /// Returns 0 if already unlocked.
  Future<int> getDaysRemaining() async {
    final daysWithData = await getDaysWithData();
    final remaining = patternUnlockDaysRequired - daysWithData;
    return remaining > 0 ? remaining : 0;
  }

  /// Get the number of days with transaction data.
  ///
  /// Counts distinct calendar days that have at least one transaction.
  Future<int> getDaysWithData() async {
    final firstTransaction = await _transactionsDao.getFirstTransaction();
    if (firstTransaction == null) return 0;

    final firstDate = firstTransaction.date;
    final now = _clock.now();

    // Calculate days between first transaction and now
    final daysDifference = now.difference(firstDate).inDays;

    // Add 1 because the first day counts
    return daysDifference + 1;
  }

  /// Get the progress percentage toward unlock (0.0 to 1.0).
  Future<double> getProgress() async {
    final daysWithData = await getDaysWithData();
    final progress = daysWithData / patternUnlockDaysRequired;
    return progress > 1.0 ? 1.0 : progress;
  }

  /// Check if the unlock celebration should be shown.
  ///
  /// Returns true if:
  /// - Feature is unlocked (≥30 days)
  /// - Celebration hasn't been shown yet
  Future<bool> shouldShowCelebration() async {
    final unlocked = await isUnlocked();
    if (!unlocked) return false;

    final shown = await _settingsDao.getValue(PatternUnlockKeys.celebrationShown);
    return shown != 'true';
  }

  /// Mark the unlock celebration as shown.
  ///
  /// Call this after displaying the celebration to prevent repeat shows.
  Future<void> markCelebrationShown() async {
    await _settingsDao.setValue(PatternUnlockKeys.celebrationShown, 'true');
  }

  /// Reset celebration shown state (for testing).
  Future<void> resetCelebrationForTesting() async {
    await _settingsDao.setValue(PatternUnlockKeys.celebrationShown, 'false');
  }
}

/// Provider for the PatternUnlockService.
final patternUnlockServiceProvider = Provider<PatternUnlockService>((ref) {
  final transactionsDao = ref.watch(transactionsDaoProvider);
  final settingsDao = ref.watch(appSettingsDaoProvider);
  final clock = ref.watch(clockProvider);

  return PatternUnlockService(
    transactionsDao: transactionsDao,
    settingsDao: settingsDao,
    clock: clock,
  );
});

/// Provider for pattern unlock status.
final patternUnlockedProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(patternUnlockServiceProvider);
  return service.isUnlocked();
});

/// Provider for days remaining until unlock.
final patternDaysRemainingProvider = FutureProvider<int>((ref) {
  final service = ref.watch(patternUnlockServiceProvider);
  return service.getDaysRemaining();
});

/// Provider for unlock progress (0.0 to 1.0).
final patternProgressProvider = FutureProvider<double>((ref) {
  final service = ref.watch(patternUnlockServiceProvider);
  return service.getProgress();
});

/// Provider for whether to show unlock celebration.
final patternCelebrationProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(patternUnlockServiceProvider);
  return service.shouldShowCelebration();
});
