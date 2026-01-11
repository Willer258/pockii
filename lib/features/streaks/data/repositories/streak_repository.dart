import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/streaks_dao.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/clock_service.dart';

/// Repository for managing user streaks.
///
/// Provides methods to access and manipulate streak data.
/// Uses injectable Clock for testable time handling.
class StreakRepository {
  StreakRepository({
    required StreaksDao streaksDao,
    required Clock clock,
  })  : _streaksDao = streaksDao,
        _clock = clock;

  final StreaksDao _streaksDao;
  final Clock _clock;

  /// Gets the current streak data.
  ///
  /// Returns null if no streak record exists.
  Future<UserStreak?> getStreak() {
    return _streaksDao.getStreak();
  }

  /// Watches the streak for reactive updates.
  Stream<UserStreak?> watchStreak() {
    return _streaksDao.watchStreak();
  }

  /// Ensures a streak record exists.
  ///
  /// Creates one with default values if none exists.
  Future<UserStreak> ensureStreakExists() {
    return _streaksDao.ensureStreakExists();
  }

  /// Gets the current streak count.
  ///
  /// Returns 0 if no streak record exists.
  Future<int> getCurrentStreak() async {
    final streak = await _streaksDao.getStreak();
    return streak?.currentStreak ?? 0;
  }

  /// Gets the longest streak ever achieved.
  ///
  /// Returns 0 if no streak record exists.
  Future<int> getLongestStreak() async {
    final streak = await _streaksDao.getStreak();
    return streak?.longestStreak ?? 0;
  }

  /// Gets the last activity date.
  ///
  /// Returns null if no activity recorded.
  Future<DateTime?> getLastActivityDate() async {
    final streak = await _streaksDao.getStreak();
    return streak?.lastActivityDate;
  }

  /// Checks if the user has activity for the current day.
  Future<bool> hasActivityToday() async {
    final lastActivity = await getLastActivityDate();
    if (lastActivity == null) return false;

    final today = _clock.now();
    return _isSameDay(lastActivity, today);
  }

  /// Checks if the user has activity for yesterday.
  Future<bool> hasActivityYesterday() async {
    final lastActivity = await getLastActivityDate();
    if (lastActivity == null) return false;

    final yesterday = _clock.now().subtract(const Duration(days: 1));
    return _isSameDay(lastActivity, yesterday);
  }

  /// Increments the streak by 1 and updates last activity date.
  ///
  /// Returns the updated streak data.
  Future<UserStreak> incrementStreak() {
    return _streaksDao.incrementStreak();
  }

  /// Resets the current streak to 0.
  ///
  /// Returns the updated streak data.
  Future<UserStreak> resetStreak() {
    return _streaksDao.resetStreak();
  }

  /// Starts a new streak (sets current streak to 1).
  ///
  /// Returns the updated streak data.
  Future<UserStreak> startNewStreak() {
    return _streaksDao.startNewStreak();
  }

  /// Updates the streak record with new values.
  Future<int> updateStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastActivityDate,
  }) {
    return _streaksDao.updateStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActivityDate: lastActivityDate,
    );
  }

  /// Checks if two dates are on the same day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Provider for StreakRepository.
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final streaksDao = ref.watch(streaksDaoProvider);
  final clock = ref.watch(clockProvider);

  return StreakRepository(
    streaksDao: streaksDao,
    clock: clock,
  );
});
