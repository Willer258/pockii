import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notification_service.dart';

/// Result of spending anomaly detection.
class SpendingAnomaly {
  const SpendingAnomaly({
    required this.category,
    required this.currentWeekAmount,
    required this.previousWeekAmount,
    required this.percentageIncrease,
    required this.suggestion,
  });

  final String category;
  final int currentWeekAmount;
  final int previousWeekAmount;
  final double percentageIncrease;
  final String suggestion;

  /// Returns true if this is a significant anomaly (>50% increase).
  bool get isSignificant => percentageIncrease >= 50;
}

/// Service for detecting unusual spending patterns.
///
/// Compares current week's spending to previous week by category
/// and alerts the user when significant increases are detected.
class SpendingAnomalyService {
  SpendingAnomalyService({
    required NotificationService notificationService,
    SharedPreferences? prefs,
  })  : _notificationService = notificationService,
        _prefs = prefs;

  final NotificationService _notificationService;
  final SharedPreferences? _prefs;

  static const String _lastAnomalyCheckKey = 'last_anomaly_check_date';
  static const double _anomalyThreshold = 0.5; // 50% increase

  /// Category-specific suggestions for spending anomalies.
  static const Map<String, String> _categorySuggestions = {
    'Restauration': 'Prépare tes repas maison pour économiser',
    'Transport': 'Privilégie le covoiturage ou les transports en commun',
    'Loisirs': 'Cherche des activités gratuites ce week-end',
    'Shopping': 'Applique la règle des 24h avant tout achat',
    'Courses': 'Fais une liste et compare les prix avant d\'acheter',
    'Santé': 'Vérifie tes remboursements mutuels',
    'Abonnements': 'Révise tes abonnements actifs',
    'default': 'Surveille cette catégorie de près cette semaine',
  };

  /// Check if we should run anomaly detection today.
  bool shouldCheckToday(DateTime now) {
    final today = _getTodayString(now);
    final lastCheck = _prefs?.getString(_lastAnomalyCheckKey);
    return lastCheck != today;
  }

  /// Analyze transactions and detect spending anomalies.
  ///
  /// Parameters:
  /// - [currentWeekByCategory]: Map of category -> total spent this week
  /// - [previousWeekByCategory]: Map of category -> total spent last week
  ///
  /// Returns a list of detected anomalies.
  List<SpendingAnomaly> detectAnomalies({
    required Map<String, int> currentWeekByCategory,
    required Map<String, int> previousWeekByCategory,
  }) {
    final anomalies = <SpendingAnomaly>[];

    for (final entry in currentWeekByCategory.entries) {
      final category = entry.key;
      final currentAmount = entry.value;
      final previousAmount = previousWeekByCategory[category] ?? 0;

      // Skip if no previous spending in this category
      if (previousAmount == 0) continue;

      // Skip if current spending is minimal (< 5000 FCFA)
      if (currentAmount < 5000) continue;

      final percentageIncrease =
          ((currentAmount - previousAmount) / previousAmount) * 100;

      // Check if this is a significant increase
      if (percentageIncrease >= _anomalyThreshold * 100) {
        final suggestion = _categorySuggestions[category] ??
            _categorySuggestions['default']!;

        anomalies.add(SpendingAnomaly(
          category: category,
          currentWeekAmount: currentAmount,
          previousWeekAmount: previousAmount,
          percentageIncrease: percentageIncrease,
          suggestion: suggestion,
        ));
      }
    }

    // Sort by percentage increase (highest first)
    anomalies.sort((a, b) => b.percentageIncrease.compareTo(a.percentageIncrease));

    return anomalies;
  }

  /// Send a notification for a detected spending anomaly.
  Future<void> notifyAnomaly(SpendingAnomaly anomaly) async {
    final formattedCurrent = _formatFcfa(anomaly.currentWeekAmount);
    final percentText = anomaly.percentageIncrease.toStringAsFixed(0);

    await _notificationService.showGenericNotification(
      title: 'Dépenses ${anomaly.category} en hausse',
      body: '$formattedCurrent FCFA cette semaine (+$percentText%)\n💡 ${anomaly.suggestion}',
      payload: 'spending_anomaly_${anomaly.category}',
    );

    // Record that we checked today
    await _prefs?.setString(_lastAnomalyCheckKey, _getTodayString(DateTime.now()));
  }

  /// Send a grouped notification for multiple anomalies.
  Future<void> notifyMultipleAnomalies(List<SpendingAnomaly> anomalies) async {
    if (anomalies.isEmpty) return;

    if (anomalies.length == 1) {
      await notifyAnomaly(anomalies.first);
      return;
    }

    final categories = anomalies.take(3).map((a) => a.category).join(', ');
    final topSuggestion = anomalies.first.suggestion;

    await _notificationService.showGenericNotification(
      title: 'Dépenses en hausse',
      body: 'Catégories: $categories\n💡 $topSuggestion',
      payload: 'spending_anomaly_multiple',
    );

    // Record that we checked today
    await _prefs?.setString(_lastAnomalyCheckKey, _getTodayString(DateTime.now()));
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

/// Provider for the SpendingAnomalyService.
final spendingAnomalyServiceProvider = Provider<SpendingAnomalyService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  return SpendingAnomalyService(notificationService: notificationService);
});
