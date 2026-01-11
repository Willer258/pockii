import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock_service.dart';
import '../../data/repositories/streak_repository.dart';

/// Service for managing streak calculation and updates.
///
/// Handles the logic for determining when to increment, reset,
/// or continue a streak based on transaction activity.
///
/// Streak Rules:
/// - A day counts if at least 1 transaction was logged
/// - Streak resets to 0 after 1 day of inactivity
/// - current_streak increments by 1 when first transaction today
/// - Consecutive days are required to maintain the streak
class StreakService {
  StreakService({
    required StreakRepository streakRepository,
    required Clock clock,
  })  : _streakRepository = streakRepository,
        _clock = clock;

  final StreakRepository _streakRepository;
  final Clock _clock;

  /// Records a transaction activity and updates the streak accordingly.
  ///
  /// This method should be called after a transaction is successfully created.
  ///
  /// Returns the updated streak data after processing.
  ///
  /// Logic:
  /// 1. If already has activity today -> no change (already counted)
  /// 2. If last activity was yesterday -> increment streak (consecutive)
  /// 3. If last activity was more than 1 day ago -> reset and start new streak
  /// 4. If no previous activity -> start new streak at 1
  Future<StreakResult> recordTransactionActivity() async {
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);

    // Ensure streak record exists
    await _streakRepository.ensureStreakExists();

    final lastActivity = await _streakRepository.getLastActivityDate();

    // Case 1: No previous activity - start new streak
    if (lastActivity == null) {
      final streak = await _streakRepository.startNewStreak();
      return StreakResult(
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        isNewMilestone: _isNewMilestone(0, streak.currentStreak),
        milestoneReached: _getMilestone(streak.currentStreak),
        action: StreakAction.started,
      );
    }

    final lastActivityDay = DateTime(
      lastActivity.year,
      lastActivity.month,
      lastActivity.day,
    );
    final daysDifference = today.difference(lastActivityDay).inDays;

    // Case 2: Already logged today - no change
    if (daysDifference == 0) {
      final streak = await _streakRepository.getStreak();
      return StreakResult(
        currentStreak: streak?.currentStreak ?? 0,
        longestStreak: streak?.longestStreak ?? 0,
        isNewMilestone: false,
        milestoneReached: null,
        action: StreakAction.alreadyRecorded,
      );
    }

    // Case 3: Consecutive day (yesterday) - increment streak
    if (daysDifference == 1) {
      final previousStreak = await _streakRepository.getCurrentStreak();
      final streak = await _streakRepository.incrementStreak();
      return StreakResult(
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        isNewMilestone: _isNewMilestone(previousStreak, streak.currentStreak),
        milestoneReached: _getMilestone(streak.currentStreak),
        action: StreakAction.incremented,
      );
    }

    // Case 4: More than 1 day gap - reset and start new
    // First reset (which keeps longest), then start new streak
    await _streakRepository.resetStreak();
    final streak = await _streakRepository.startNewStreak();
    return StreakResult(
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      isNewMilestone: false,
      milestoneReached: null,
      action: StreakAction.resetAndStarted,
    );
  }

  /// Gets the current streak status without modifying it.
  Future<StreakStatus> getStreakStatus() async {
    final streak = await _streakRepository.getStreak();
    if (streak == null) {
      return const StreakStatus(
        currentStreak: 0,
        longestStreak: 0,
        hasActivityToday: false,
        lastActivityDate: null,
        streakIsActive: false,
      );
    }

    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final lastActivity = streak.lastActivityDate;
    final hasActivityToday = lastActivity != null && _isSameDay(lastActivity, today);

    // Streak is active if user logged today OR yesterday (still can continue today)
    final streakIsActive = lastActivity != null &&
        (_isSameDay(lastActivity, today) || _isSameDay(lastActivity, yesterday));

    // If streak is not active (more than 1 day gap), current streak is effectively 0
    // The stored value is kept for when user starts again, but display should show 0
    final effectiveCurrentStreak = streakIsActive ? streak.currentStreak : 0;

    return StreakStatus(
      currentStreak: effectiveCurrentStreak,
      longestStreak: streak.longestStreak,
      hasActivityToday: hasActivityToday,
      lastActivityDate: streak.lastActivityDate,
      streakIsActive: streakIsActive,
    );
  }

  /// Checks if the current streak will be lost if user doesn't log today.
  ///
  /// Returns true if the user had activity yesterday but not today.
  Future<bool> willLoseStreakToday() async {
    final status = await getStreakStatus();

    if (status.currentStreak == 0) return false;
    if (status.hasActivityToday) return false;

    final lastActivity = status.lastActivityDate;
    if (lastActivity == null) return false;

    final now = _clock.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    return _isSameDay(lastActivity, yesterday);
  }

  /// Checks if a new milestone was reached.
  bool _isNewMilestone(int previousStreak, int currentStreak) {
    const milestones = [7, 14, 30, 60, 90, 180, 365];

    for (final milestone in milestones) {
      if (previousStreak < milestone && currentStreak >= milestone) {
        return true;
      }
    }
    return false;
  }

  /// Gets the milestone reached, if any.
  int? _getMilestone(int currentStreak) {
    const milestones = [7, 14, 30, 60, 90, 180, 365];

    for (final milestone in milestones.reversed) {
      if (currentStreak >= milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Checks if two dates are on the same day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Result of recording a transaction activity.
class StreakResult {
  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isNewMilestone,
    required this.milestoneReached,
    required this.action,
  });

  /// Current streak count after the action.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// Whether a new milestone was reached (7, 14, 30, etc.).
  final bool isNewMilestone;

  /// The milestone value reached, if any.
  final int? milestoneReached;

  /// What action was taken.
  final StreakAction action;
}

/// Status information about the current streak.
class StreakStatus {
  const StreakStatus({
    required this.currentStreak,
    required this.longestStreak,
    required this.hasActivityToday,
    required this.lastActivityDate,
    required this.streakIsActive,
  });

  /// Current streak count.
  final int currentStreak;

  /// Longest streak ever achieved.
  final int longestStreak;

  /// Whether the user has already logged a transaction today.
  final bool hasActivityToday;

  /// When the last activity was recorded.
  final DateTime? lastActivityDate;

  /// Whether the streak is still active (logged today or yesterday).
  final bool streakIsActive;
}

/// Actions that can be taken on a streak.
enum StreakAction {
  /// First ever transaction, streak started at 1.
  started,

  /// Consecutive day, streak incremented.
  incremented,

  /// Already logged today, no change.
  alreadyRecorded,

  /// Gap > 1 day, reset and started new streak.
  resetAndStarted,
}

/// Provider for StreakService.
final streakServiceProvider = Provider<StreakService>((ref) {
  final streakRepository = ref.watch(streakRepositoryProvider);
  final clock = ref.watch(clockProvider);

  return StreakService(
    streakRepository: streakRepository,
    clock: clock,
  );
});
