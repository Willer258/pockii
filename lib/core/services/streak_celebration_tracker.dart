import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';

/// Settings keys for streak celebration tracking.
abstract class StreakCelebrationKeys {
  /// The last milestone for which a notification was sent.
  static const lastNotifiedMilestone = 'streak_last_notified_milestone';

  /// Pending celebration milestone to show in-app (null if none pending).
  static const pendingCelebration = 'streak_pending_celebration';
}

/// Milestone definitions for streak celebrations.
abstract class StreakMilestones {
  /// All milestone days that trigger celebrations.
  static const all = [7, 14, 30, 60, 90, 180, 365];

  /// Check if a streak count is a milestone.
  static bool isMilestone(int streakDays) => all.contains(streakDays);
}

/// Tracks streak celebration state to prevent duplicate notifications
/// and manage in-app celebrations.
///
/// Ensures each milestone only triggers one notification, and tracks
/// pending celebrations for in-app display.
///
/// Covers: FR38, FR54, Story 4.6
class StreakCelebrationTracker {
  StreakCelebrationTracker({
    required AppSettingsDao settingsDao,
  }) : _settingsDao = settingsDao;

  final AppSettingsDao _settingsDao;

  /// Check if notification should be sent for a milestone.
  ///
  /// Returns true if this is a milestone and hasn't been notified yet.
  Future<bool> shouldSendNotification(int streakDays) async {
    if (!StreakMilestones.isMilestone(streakDays)) {
      return false;
    }

    final lastNotified = await _getLastNotifiedMilestone();

    // Only notify if this milestone is higher than the last notified
    // This handles the case where streak was reset and rebuilt
    return streakDays > lastNotified;
  }

  /// Mark a milestone as notified and set pending in-app celebration.
  Future<void> markMilestoneNotified(int streakDays) async {
    await _settingsDao.setValue(
      StreakCelebrationKeys.lastNotifiedMilestone,
      streakDays.toString(),
    );

    // Set pending celebration for in-app display
    await _settingsDao.setValue(
      StreakCelebrationKeys.pendingCelebration,
      streakDays.toString(),
    );
  }

  /// Get pending in-app celebration milestone, if any.
  ///
  /// Returns the milestone to celebrate, or null if no pending celebration.
  Future<int?> getPendingCelebration() async {
    final value = await _settingsDao.getValue(StreakCelebrationKeys.pendingCelebration);
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Clear pending in-app celebration after it's been shown.
  Future<void> clearPendingCelebration() async {
    await _settingsDao.deleteSetting(StreakCelebrationKeys.pendingCelebration);
  }

  /// Check and handle milestone celebration.
  ///
  /// Returns the milestone to celebrate if notification should be sent,
  /// or null if no celebration needed.
  Future<int?> checkAndMarkMilestone(int streakDays) async {
    if (await shouldSendNotification(streakDays)) {
      await markMilestoneNotified(streakDays);
      return streakDays;
    }
    return null;
  }

  /// Reset tracking when streak is broken.
  ///
  /// Call this when the streak resets to 0 so milestones can be
  /// celebrated again when rebuilt.
  Future<void> resetOnStreakBroken() async {
    await _settingsDao.setValue(
      StreakCelebrationKeys.lastNotifiedMilestone,
      '0',
    );
  }

  /// Get the last notified milestone.
  Future<int> _getLastNotifiedMilestone() async {
    final value = await _settingsDao.getValue(StreakCelebrationKeys.lastNotifiedMilestone);
    if (value == null || value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }

  /// Reset all celebration tracking (for testing).
  Future<void> resetAll() async {
    await _settingsDao.deleteSetting(StreakCelebrationKeys.lastNotifiedMilestone);
    await _settingsDao.deleteSetting(StreakCelebrationKeys.pendingCelebration);
  }
}

/// Provider for the StreakCelebrationTracker.
final streakCelebrationTrackerProvider =
    Provider.family<StreakCelebrationTracker, AppSettingsDao>((ref, settingsDao) {
  return StreakCelebrationTracker(settingsDao: settingsDao);
});

/// Celebration message for each milestone.
String getCelebrationMessage(int streakDays) {
  switch (streakDays) {
    case 7:
      return '7 jours de suite! Tu geres!';
    case 14:
      return '14 jours! Tu deviens un pro!';
    case 30:
      return '30 jours! Maitre du budget!';
    case 60:
      return '60 jours! Deux mois de discipline!';
    case 90:
      return '90 jours! Trois mois! Tu es une legende!';
    case 180:
      return '180 jours! Six mois! Extraordinaire!';
    case 365:
      return 'Une annee complete! Tu es absolument incroyable!';
    default:
      return '$streakDays jours! Continue ta serie!';
  }
}

/// Celebration emoji for each milestone.
String getCelebrationEmoji(int streakDays) {
  switch (streakDays) {
    case 7:
      return '🎉';
    case 14:
      return '🔥';
    case 30:
      return '👑';
    case 60:
      return '💪';
    case 90:
      return '🏆';
    case 180:
      return '⭐';
    case 365:
      return '🎊';
    default:
      return '🔥';
  }
}
