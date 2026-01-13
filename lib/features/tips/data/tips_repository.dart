import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/tip.dart';
import 'tips_data.dart';

/// Repository for managing tip selection and rotation.
class TipsRepository {
  TipsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _lastTipIdKey = 'last_tip_id';
  static const String _lastTipDateKey = 'last_tip_date';
  static const String _recentTipIdsKey = 'recent_tip_ids';
  static const int _recentTipsToAvoid = 5;

  final _random = Random();

  /// Get the tip of the day based on budget percentage.
  /// Returns a contextually appropriate tip that rotates daily.
  Tip getDailyTip(double budgetPercentage) {
    final today = _getTodayString();
    final lastDate = _prefs.getString(_lastTipDateKey);
    final lastTipId = _prefs.getString(_lastTipIdKey);

    // If we already have a tip for today, return it
    if (lastDate == today && lastTipId != null) {
      final existingTip = TipsData.allTips.firstWhere(
        (t) => t.id == lastTipId,
        orElse: () => _selectNewTip(budgetPercentage),
      );
      return existingTip;
    }

    // Select a new tip for today
    return _selectNewTip(budgetPercentage);
  }

  /// Force select a new tip (e.g., when user taps "next").
  Tip getNextTip(double budgetPercentage) {
    return _selectNewTip(budgetPercentage);
  }

  /// Get a random tip for notifications.
  Tip getRandomTip(double budgetPercentage) {
    final availableTips = TipsData.forBudgetPercentage(budgetPercentage);
    if (availableTips.isEmpty) {
      return TipsData.allTips[_random.nextInt(TipsData.allTips.length)];
    }
    return availableTips[_random.nextInt(availableTips.length)];
  }

  Tip _selectNewTip(double budgetPercentage) {
    final availableTips = TipsData.forBudgetPercentage(budgetPercentage);
    final recentIds = _getRecentTipIds();

    // Filter out recently shown tips
    var candidates = availableTips
        .where((tip) => !recentIds.contains(tip.id))
        .toList();

    // If all tips have been shown recently, reset and use all available
    if (candidates.isEmpty) {
      candidates = availableTips;
    }

    // Select a random tip from candidates
    final selectedTip = candidates[_random.nextInt(candidates.length)];

    // Save the selection
    _saveTipSelection(selectedTip.id);

    return selectedTip;
  }

  List<String> _getRecentTipIds() {
    final stored = _prefs.getStringList(_recentTipIdsKey);
    return stored ?? [];
  }

  Future<void> _saveTipSelection(String tipId) async {
    final today = _getTodayString();
    final recentIds = _getRecentTipIds();

    // Add new tip to recent list
    final updatedRecent = [tipId, ...recentIds];

    // Keep only the last N tips
    final trimmedRecent = updatedRecent.take(_recentTipsToAvoid).toList();

    await _prefs.setString(_lastTipIdKey, tipId);
    await _prefs.setString(_lastTipDateKey, today);
    await _prefs.setStringList(_recentTipIdsKey, trimmedRecent);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

/// Provider for SharedPreferences (async initialization).
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for TipsRepository.
final tipsRepositoryProvider = FutureProvider<TipsRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return TipsRepository(prefs);
});
