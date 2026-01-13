import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';
import 'clock_service.dart';

/// Settings keys for planned expense reminder tracking.
abstract class PlannedExpenseReminderKeys {
  /// JSON map of planned expense IDs to last reminded date (YYYY-MM-DD format).
  static const remindedExpenses = 'planned_expense_reminders_sent';
}

/// Tracks planned expense reminder state to prevent duplicate notifications.
///
/// Ensures each planned expense only receives one reminder per day,
/// preventing notification spam when background tasks run repeatedly.
class PlannedExpenseReminderTracker {
  PlannedExpenseReminderTracker({
    required AppSettingsDao settingsDao,
    Clock? clock,
  })  : _settingsDao = settingsDao,
        _clock = clock ?? SystemClock();

  final AppSettingsDao _settingsDao;
  final Clock _clock;

  /// Check if reminder should be sent for a planned expense.
  ///
  /// Returns true if no reminder has been sent for this expense today.
  Future<bool> shouldSendReminder(int expenseId) async {
    final remindedMap = await _getRemindedMap();
    final today = _getToday();

    final lastRemindedDate = remindedMap[expenseId.toString()];
    return lastRemindedDate != today;
  }

  /// Mark a planned expense as reminded for today.
  Future<void> markAsReminded(int expenseId) async {
    final remindedMap = await _getRemindedMap();
    final today = _getToday();

    remindedMap[expenseId.toString()] = today;

    // Clean up old entries (from previous days)
    remindedMap.removeWhere((_, date) => date != today);

    await _saveRemindedMap(remindedMap);
  }

  /// Mark multiple planned expenses as reminded (for grouped notifications).
  Future<void> markMultipleAsReminded(List<int> expenseIds) async {
    final remindedMap = await _getRemindedMap();
    final today = _getToday();

    for (final id in expenseIds) {
      remindedMap[id.toString()] = today;
    }

    // Clean up old entries
    remindedMap.removeWhere((_, date) => date != today);

    await _saveRemindedMap(remindedMap);
  }

  /// Filter a list of planned expense IDs to only those that haven't been reminded today.
  ///
  /// Returns the IDs that should receive reminders.
  Future<List<int>> filterUnreminded(List<int> expenseIds) async {
    final remindedMap = await _getRemindedMap();
    final today = _getToday();

    return expenseIds.where((id) {
      final lastRemindedDate = remindedMap[id.toString()];
      return lastRemindedDate != today;
    }).toList();
  }

  /// Reset all reminder tracking (for testing).
  Future<void> resetAll() async {
    await _settingsDao.deleteSetting(PlannedExpenseReminderKeys.remindedExpenses);
  }

  String _getToday() {
    final now = _clock.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, String>> _getRemindedMap() async {
    final json =
        await _settingsDao.getValue(PlannedExpenseReminderKeys.remindedExpenses);
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
    await _settingsDao.setValue(
        PlannedExpenseReminderKeys.remindedExpenses, json);
  }
}

/// Provider for the PlannedExpenseReminderTracker.
final plannedExpenseReminderTrackerProvider =
    Provider.family<PlannedExpenseReminderTracker, AppSettingsDao>(
        (ref, settingsDao) {
  return PlannedExpenseReminderTracker(settingsDao: settingsDao);
});
