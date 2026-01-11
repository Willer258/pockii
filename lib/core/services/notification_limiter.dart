import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_settings_dao.dart';
import '../database/database_provider.dart';
import 'clock_service.dart';

/// Storage keys for notification limiter.
abstract class NotificationLimiterKeys {
  static const dailyCount = 'notification_daily_count';
  static const lastCountDate = 'notification_last_count_date';
  static const queuedNotifications = 'notification_queue';
}

/// Priority levels for notifications.
enum NotificationPriority {
  /// Standard notification (subject to daily limit).
  normal,

  /// Critical notification (can bypass limit, e.g., budget <10%).
  critical,
}

/// Result of attempting to send a notification.
enum NotificationLimitResult {
  /// Notification can be sent (under limit).
  allowed,

  /// Notification was queued for later (limit reached).
  queued,

  /// Critical notification allowed (bypassed limit).
  criticalAllowed,
}

/// A queued notification waiting to be sent.
class QueuedNotification {
  const QueuedNotification({
    required this.type,
    required this.title,
    required this.body,
    required this.queuedAt,
    this.payload,
  });

  factory QueuedNotification.fromJson(Map<String, dynamic> json) {
    return QueuedNotification(
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      payload: json['payload'] as String?,
    );
  }

  final String type;
  final String title;
  final String body;
  final DateTime queuedAt;
  final String? payload;

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'body': body,
        'queuedAt': queuedAt.toIso8601String(),
        'payload': payload,
      };
}

/// Service for limiting notification frequency.
///
/// Implements FR40: System limits notifications to maximum 2 per day.
/// Critical alerts (budget <10%) can bypass the limit (max 3 total).
///
/// Covers: FR40, Story 4.8
class NotificationLimiter {
  NotificationLimiter({
    required AppSettingsDao settingsDao,
    required Clock clock,
  })  : _settingsDao = settingsDao,
        _clock = clock;

  final AppSettingsDao _settingsDao;
  final Clock _clock;

  /// Maximum normal notifications per day.
  static const int dailyLimit = 2;

  /// Maximum total notifications per day (including critical).
  static const int absoluteLimit = 3;

  /// Check if a notification can be sent.
  ///
  /// Returns [NotificationLimitResult.allowed] if under limit,
  /// [NotificationLimitResult.criticalAllowed] if critical bypasses limit,
  /// or [NotificationLimitResult.queued] if limit reached.
  Future<NotificationLimitResult> canSendNotification({
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    await _resetIfNewDay();

    final count = await _getDailyCount();

    // Critical notifications can bypass normal limit but not absolute limit
    if (priority == NotificationPriority.critical) {
      if (count < absoluteLimit) {
        return NotificationLimitResult.criticalAllowed;
      }
      return NotificationLimitResult.queued;
    }

    // Normal notifications respect daily limit
    if (count < dailyLimit) {
      return NotificationLimitResult.allowed;
    }

    return NotificationLimitResult.queued;
  }

  /// Record that a notification was sent.
  ///
  /// Call this after successfully sending a notification.
  Future<void> recordNotificationSent() async {
    await _resetIfNewDay();
    final count = await _getDailyCount();
    await _setDailyCount(count + 1);
  }

  /// Queue a notification for later delivery.
  ///
  /// Call this when [canSendNotification] returns [NotificationLimitResult.queued].
  Future<void> queueNotification({
    required String type,
    required String title,
    required String body,
    String? payload,
  }) async {
    final queue = await _getQueue();
    queue.add(QueuedNotification(
      type: type,
      title: title,
      body: body,
      queuedAt: _clock.now(),
      payload: payload,
    ));
    await _saveQueue(queue);
  }

  /// Get queued notifications and clear the queue.
  ///
  /// Call this at the start of a new day to process queued notifications.
  /// Returns up to [dailyLimit] notifications, leaving the rest in queue.
  Future<List<QueuedNotification>> getAndClearQueuedNotifications() async {
    await _resetIfNewDay();

    final queue = await _getQueue();
    if (queue.isEmpty) return [];

    final count = await _getDailyCount();
    final availableSlots = dailyLimit - count;

    if (availableSlots <= 0) return [];

    // Take up to available slots
    final toSend = queue.take(availableSlots).toList();
    final remaining = queue.skip(availableSlots).toList();

    await _saveQueue(remaining);

    return toSend;
  }

  /// Get the current daily notification count.
  Future<int> getDailyCount() async {
    await _resetIfNewDay();
    return _getDailyCount();
  }

  /// Get the number of queued notifications.
  Future<int> getQueuedCount() async {
    final queue = await _getQueue();
    return queue.length;
  }

  /// Check if there are queued notifications.
  Future<bool> hasQueuedNotifications() async {
    final queue = await _getQueue();
    return queue.isNotEmpty;
  }

  /// Reset for testing purposes.
  Future<void> resetForTesting() async {
    await _setDailyCount(0);
    await _setLastCountDate(_clock.now());
    await _saveQueue([]);
  }

  Future<int> _getDailyCount() async {
    final value = await _settingsDao.getValue(NotificationLimiterKeys.dailyCount);
    if (value == null) return 0;
    return int.tryParse(value) ?? 0;
  }

  Future<void> _setDailyCount(int count) async {
    await _settingsDao.setValue(
      NotificationLimiterKeys.dailyCount,
      count.toString(),
    );
  }

  Future<DateTime?> _getLastCountDate() async {
    final value = await _settingsDao.getValue(NotificationLimiterKeys.lastCountDate);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<void> _setLastCountDate(DateTime date) async {
    await _settingsDao.setValue(
      NotificationLimiterKeys.lastCountDate,
      date.toIso8601String(),
    );
  }

  Future<void> _resetIfNewDay() async {
    final lastDate = await _getLastCountDate();
    final now = _clock.now();

    if (lastDate == null) {
      // First time - set today's date
      await _setLastCountDate(now);
      return;
    }

    // Check if it's a new day
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final todayOnly = DateTime(now.year, now.month, now.day);

    if (todayOnly.isAfter(lastDateOnly)) {
      // New day - reset counter
      await _setDailyCount(0);
      await _setLastCountDate(now);
    }
  }

  Future<List<QueuedNotification>> _getQueue() async {
    final value = await _settingsDao.getValue(NotificationLimiterKeys.queuedNotifications);
    if (value == null || value.isEmpty) return [];

    try {
      final List<dynamic> json = jsonDecode(value) as List<dynamic>;
      return json
          .map((item) => QueuedNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If parsing fails, return empty queue
      return [];
    }
  }

  Future<void> _saveQueue(List<QueuedNotification> queue) async {
    final json = jsonEncode(queue.map((n) => n.toJson()).toList());
    await _settingsDao.setValue(NotificationLimiterKeys.queuedNotifications, json);
  }
}

/// Provider for the NotificationLimiter.
final notificationLimiterProvider = Provider<NotificationLimiter>((ref) {
  final settingsDao = ref.watch(appSettingsDaoProvider);
  final clock = ref.watch(clockProvider);
  return NotificationLimiter(settingsDao: settingsDao, clock: clock);
});
