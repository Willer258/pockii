import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';
import 'clock_service.dart';

/// Settings keys for subscription reminder tracking.
abstract class SubscriptionReminderKeys {
  /// JSON map of subscription IDs to last reminded month (YYYY-MM format).
  static const remindedSubscriptions = 'subscription_reminders_sent';
}

/// Tracks subscription reminder state to prevent duplicate notifications.
///
/// Ensures each subscription only receives one reminder per month,
/// preventing notification spam when background tasks run repeatedly.
///
/// Covers: FR29, FR37, Story 4.5
class SubscriptionReminderTracker {
  SubscriptionReminderTracker({
    required AppSettingsDao settingsDao,
    Clock? clock,
  })  : _settingsDao = settingsDao,
        _clock = clock ?? SystemClock();

  final AppSettingsDao _settingsDao;
  final Clock _clock;

  /// Check if reminder should be sent for a subscription.
  ///
  /// Returns true if no reminder has been sent for this subscription
  /// in the current month.
  Future<bool> shouldSendReminder(int subscriptionId) async {
    final remindedMap = await _getRemindedMap();
    final currentMonth = _getCurrentMonth();

    final lastRemindedMonth = remindedMap[subscriptionId.toString()];
    return lastRemindedMonth != currentMonth;
  }

  /// Mark a subscription as reminded for the current month.
  Future<void> markAsReminded(int subscriptionId) async {
    final remindedMap = await _getRemindedMap();
    final currentMonth = _getCurrentMonth();

    remindedMap[subscriptionId.toString()] = currentMonth;

    // Clean up old entries (from previous months)
    remindedMap.removeWhere((_, month) => month != currentMonth);

    await _saveRemindedMap(remindedMap);
  }

  /// Mark multiple subscriptions as reminded (for grouped notifications).
  Future<void> markMultipleAsReminded(List<int> subscriptionIds) async {
    final remindedMap = await _getRemindedMap();
    final currentMonth = _getCurrentMonth();

    for (final id in subscriptionIds) {
      remindedMap[id.toString()] = currentMonth;
    }

    // Clean up old entries
    remindedMap.removeWhere((_, month) => month != currentMonth);

    await _saveRemindedMap(remindedMap);
  }

  /// Filter a list of subscription IDs to only those that haven't been reminded.
  ///
  /// Returns the IDs that should receive reminders.
  Future<List<int>> filterUnreminded(List<int> subscriptionIds) async {
    final remindedMap = await _getRemindedMap();
    final currentMonth = _getCurrentMonth();

    return subscriptionIds.where((id) {
      final lastRemindedMonth = remindedMap[id.toString()];
      return lastRemindedMonth != currentMonth;
    }).toList();
  }

  /// Reset all reminder tracking (for testing or month transition).
  Future<void> resetAll() async {
    await _settingsDao.deleteSetting(SubscriptionReminderKeys.remindedSubscriptions);
  }

  String _getCurrentMonth() {
    final now = _clock.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<Map<String, String>> _getRemindedMap() async {
    final json = await _settingsDao.getValue(SubscriptionReminderKeys.remindedSubscriptions);
    if (json == null || json.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      // If JSON is corrupted, start fresh
      return {};
    }
  }

  Future<void> _saveRemindedMap(Map<String, String> map) async {
    final json = jsonEncode(map);
    await _settingsDao.setValue(SubscriptionReminderKeys.remindedSubscriptions, json);
  }
}

/// Provider for the SubscriptionReminderTracker.
final subscriptionReminderTrackerProvider =
    Provider.family<SubscriptionReminderTracker, AppSettingsDao>((ref, settingsDao) {
  return SubscriptionReminderTracker(settingsDao: settingsDao);
});
