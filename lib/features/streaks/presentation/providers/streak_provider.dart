import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/services/streak_celebration_tracker.dart';
import '../../domain/services/streak_service.dart';

/// Provider for the current streak status.
///
/// Returns the streak status including current streak, longest streak,
/// and whether the user has logged activity today.
final streakStatusProvider = FutureProvider.autoDispose<StreakStatus>((ref) {
  final streakService = ref.watch(streakServiceProvider);
  return streakService.getStreakStatus();
});

/// Provider to check if the user will lose their streak today.
///
/// Returns true if the user logged yesterday but not today.
final willLoseStreakProvider = FutureProvider.autoDispose<bool>((ref) {
  final streakService = ref.watch(streakServiceProvider);
  return streakService.willLoseStreakToday();
});

/// Provider that exposes the streak service for recording activity.
///
/// Used when a transaction is created to update the streak.
final streakRecorderProvider = Provider<StreakService>((ref) {
  return ref.watch(streakServiceProvider);
});

/// Provider for the streak celebration tracker.
final streakCelebrationTrackerDaoProvider =
    Provider<StreakCelebrationTracker>((ref) {
  final appSettingsDao = ref.watch(appSettingsDaoProvider);
  return StreakCelebrationTracker(settingsDao: appSettingsDao);
});

/// Provider that checks for pending streak celebration.
///
/// Returns the milestone to celebrate, or null if none pending.
final pendingCelebrationProvider = FutureProvider.autoDispose<int?>((ref) async {
  final tracker = ref.watch(streakCelebrationTrackerDaoProvider);
  return tracker.getPendingCelebration();
});

/// Provider to clear the pending celebration after it's shown.
final clearPendingCelebrationProvider = Provider<Future<void> Function()>((ref) {
  final tracker = ref.watch(streakCelebrationTrackerDaoProvider);
  return () async {
    await tracker.clearPendingCelebration();
    ref.invalidate(pendingCelebrationProvider);
  };
});
