import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_service.dart';
import '../data/tips_data.dart';
import '../domain/models/tip.dart';

/// Service for managing morning budget notifications with tips.
///
/// Sends a daily morning notification with:
/// - Current budget remaining
/// - Days remaining in the month
/// - A contextual financial tip
class MorningNotificationService {
  MorningNotificationService({
    required NotificationService notificationService,
    SharedPreferences? prefs,
  })  : _notificationService = notificationService,
        _prefs = prefs;

  final NotificationService _notificationService;
  final SharedPreferences? _prefs;

  static const String _lastMorningNotificationKey = 'last_morning_notification_date';
  static const int _morningHour = 8; // 8 AM

  /// Check if it's time to send the morning notification.
  ///
  /// Returns true if:
  /// - Current hour is the morning hour (8 AM)
  /// - We haven't sent a notification today yet
  bool shouldSendMorningNotification(DateTime now) {
    if (now.hour != _morningHour) return false;

    final today = _getTodayString(now);
    final lastSent = _prefs?.getString(_lastMorningNotificationKey);

    return lastSent != today;
  }

  /// Send the morning notification.
  ///
  /// Parameters:
  /// - [remainingBudget]: Current remaining budget in FCFA
  /// - [budgetPercentage]: Budget percentage (0.0 to 1.0)
  /// - [daysRemaining]: Days remaining in the current month
  Future<void> sendMorningNotification({
    required int remainingBudget,
    required double budgetPercentage,
    required int daysRemaining,
  }) async {
    final tip = _getRandomTip(budgetPercentage);
    final formattedBudget = _formatFcfa(remainingBudget);

    final String title;
    final String body;

    if (budgetPercentage > 0.5) {
      title = 'Bonjour! Tu geres bien';
      body = 'Budget: $formattedBudget FCFA ($daysRemaining jours)\n${tip.category.emoji} ${tip.content}';
    } else if (budgetPercentage > 0.2) {
      title = 'Bonjour! Attention au budget';
      body = 'Il te reste $formattedBudget FCFA pour $daysRemaining jours\n${tip.category.emoji} ${tip.content}';
    } else {
      title = 'Bonjour! Budget serre';
      body = 'Plus que $formattedBudget FCFA pour $daysRemaining jours\n${tip.category.emoji} ${tip.content}';
    }

    await _notificationService.showGenericNotification(
      title: title,
      body: body,
      payload: 'morning_notification',
    );

    // Record that we sent today's notification
    await _prefs?.setString(_lastMorningNotificationKey, _getTodayString(DateTime.now()));
  }

  /// Get a random tip appropriate for the budget percentage.
  Tip _getRandomTip(double percentage) {
    final tips = TipsData.forBudgetPercentage(percentage);
    if (tips.isEmpty) return TipsData.allTips.first;
    return tips[Random().nextInt(tips.length)];
  }

  String _getTodayString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatFcfa(int amount) {
    final absAmount = amount.abs();
    final formatted = absAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        );
    return amount < 0 ? '-$formatted' : formatted;
  }
}

/// Provider for the MorningNotificationService.
final morningNotificationServiceProvider = Provider<MorningNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return MorningNotificationService(notificationService: notificationService);
});
