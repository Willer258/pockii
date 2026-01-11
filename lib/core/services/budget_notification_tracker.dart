import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';

/// Settings keys for budget notification tracking.
abstract class BudgetNotificationKeys {
  static const warningNotified = 'budget_warning_notified';
  static const criticalNotified = 'budget_critical_notified';
  static const lastBudgetPercent = 'last_budget_percent';
}

/// Tracks budget notification state to prevent duplicate notifications.
///
/// Manages threshold crossing state so that:
/// - Warning notification (30%) is only sent once per crossing
/// - Critical notification (10%) is only sent once per crossing
/// - When budget recovers above threshold, tracking resets
///
/// Covers: FR35, FR36, Story 4.4
class BudgetNotificationTracker {
  BudgetNotificationTracker({
    required AppSettingsDao settingsDao,
  }) : _settingsDao = settingsDao;

  final AppSettingsDao _settingsDao;

  /// Warning threshold percentage (30%)
  static const warningThreshold = 30.0;

  /// Critical threshold percentage (10%)
  static const criticalThreshold = 10.0;

  /// Check if warning notification should be sent and update state.
  ///
  /// Returns true if notification should be sent (first time crossing threshold).
  Future<bool> shouldSendWarning(double currentPercent) async {
    // Check if we already notified for this crossing
    final alreadyNotified = await _getBool(BudgetNotificationKeys.warningNotified);
    if (alreadyNotified) {
      return false;
    }

    // Check if we're below the warning threshold
    if (currentPercent <= warningThreshold && currentPercent > criticalThreshold) {
      // Mark as notified
      await _setBool(BudgetNotificationKeys.warningNotified, true);
      return true;
    }

    return false;
  }

  /// Check if critical notification should be sent and update state.
  ///
  /// Returns true if notification should be sent (first time crossing threshold).
  Future<bool> shouldSendCritical(double currentPercent) async {
    // Check if we already notified for this crossing
    final alreadyNotified = await _getBool(BudgetNotificationKeys.criticalNotified);
    if (alreadyNotified) {
      return false;
    }

    // Check if we're below the critical threshold
    if (currentPercent <= criticalThreshold && currentPercent > 0) {
      // Mark as notified
      await _setBool(BudgetNotificationKeys.criticalNotified, true);
      return true;
    }

    return false;
  }

  /// Update the tracker with current budget percentage.
  ///
  /// If budget has recovered above a threshold, reset that notification state
  /// so it can trigger again if budget drops back below.
  Future<void> updateBudgetPercent(double currentPercent) async {
    final lastPercent = await _getDouble(BudgetNotificationKeys.lastBudgetPercent);

    // If budget recovered above warning threshold, reset warning notification
    if (currentPercent > warningThreshold && (lastPercent ?? 0) <= warningThreshold) {
      await _setBool(BudgetNotificationKeys.warningNotified, false);
    }

    // If budget recovered above critical threshold, reset critical notification
    if (currentPercent > criticalThreshold && (lastPercent ?? 0) <= criticalThreshold) {
      await _setBool(BudgetNotificationKeys.criticalNotified, false);
    }

    // Store current percent for next comparison
    await _setDouble(BudgetNotificationKeys.lastBudgetPercent, currentPercent);
  }

  /// Check and send appropriate notification based on current budget.
  ///
  /// Returns a [BudgetNotificationResult] indicating which notification to send.
  Future<BudgetNotificationResult> checkAndUpdateState(double currentPercent) async {
    // First, update state based on recovery
    await updateBudgetPercent(currentPercent);

    // Check critical first (higher priority)
    if (currentPercent <= criticalThreshold && currentPercent > 0) {
      final shouldSend = await shouldSendCritical(currentPercent);
      if (shouldSend) {
        return BudgetNotificationResult.critical;
      }
    }

    // Check warning
    if (currentPercent <= warningThreshold && currentPercent > criticalThreshold) {
      final shouldSend = await shouldSendWarning(currentPercent);
      if (shouldSend) {
        return BudgetNotificationResult.warning;
      }
    }

    return BudgetNotificationResult.none;
  }

  /// Reset all notification tracking state.
  Future<void> resetAll() async {
    await _setBool(BudgetNotificationKeys.warningNotified, false);
    await _setBool(BudgetNotificationKeys.criticalNotified, false);
    await _settingsDao.deleteSetting(BudgetNotificationKeys.lastBudgetPercent);
  }

  Future<bool> _getBool(String key) async {
    final value = await _settingsDao.getValue(key);
    return value == 'true';
  }

  Future<void> _setBool(String key, bool value) async {
    await _settingsDao.setValue(key, value.toString());
  }

  Future<double?> _getDouble(String key) async {
    final value = await _settingsDao.getValue(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  Future<void> _setDouble(String key, double value) async {
    await _settingsDao.setValue(key, value.toString());
  }
}

/// Result of checking budget notification state.
enum BudgetNotificationResult {
  /// No notification should be sent.
  none,

  /// Warning notification should be sent (30% threshold).
  warning,

  /// Critical notification should be sent (10% threshold).
  critical,
}

/// Provider for the BudgetNotificationTracker.
final budgetNotificationTrackerProvider =
    Provider.family<BudgetNotificationTracker, AppSettingsDao>((ref, settingsDao) {
  return BudgetNotificationTracker(settingsDao: settingsDao);
});
