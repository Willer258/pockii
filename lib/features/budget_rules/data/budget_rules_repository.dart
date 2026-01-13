import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/budget_allocation.dart';
import '../domain/models/emergency_fund.dart';

/// Repository for persisting budget rules settings.
class BudgetRulesRepository {
  BudgetRulesRepository(this._prefs);

  final SharedPreferences _prefs;

  // Keys for 50/30/20 rule
  static const String _ruleEnabledKey = 'budget_rule_enabled';
  static const String _needsPercentageKey = 'budget_needs_percentage';
  static const String _wantsPercentageKey = 'budget_wants_percentage';
  static const String _savingsPercentageKey = 'budget_savings_percentage';

  // Keys for emergency fund
  static const String _fundEnabledKey = 'emergency_fund_enabled';
  static const String _monthlySalaryKey = 'emergency_fund_salary';
  static const String _targetMonthsKey = 'emergency_fund_months';
  static const String _currentSavingsKey = 'emergency_fund_current';

  // ==========================================
  // 50/30/20 Rule Settings
  // ==========================================

  /// Get the current budget rule settings.
  BudgetRuleSettings getBudgetRuleSettings() {
    return BudgetRuleSettings(
      isEnabled: _prefs.getBool(_ruleEnabledKey) ?? false,
      needsPercentage: _prefs.getInt(_needsPercentageKey) ?? 50,
      wantsPercentage: _prefs.getInt(_wantsPercentageKey) ?? 30,
      savingsPercentage: _prefs.getInt(_savingsPercentageKey) ?? 20,
    );
  }

  /// Save the budget rule settings.
  Future<void> saveBudgetRuleSettings(BudgetRuleSettings settings) async {
    await _prefs.setBool(_ruleEnabledKey, settings.isEnabled);
    await _prefs.setInt(_needsPercentageKey, settings.needsPercentage);
    await _prefs.setInt(_wantsPercentageKey, settings.wantsPercentage);
    await _prefs.setInt(_savingsPercentageKey, settings.savingsPercentage);
  }

  /// Enable or disable the budget rule.
  Future<void> setBudgetRuleEnabled(bool enabled) async {
    await _prefs.setBool(_ruleEnabledKey, enabled);
  }

  // ==========================================
  // Emergency Fund Settings
  // ==========================================

  /// Get the current emergency fund settings.
  EmergencyFundSettings getEmergencyFundSettings() {
    return EmergencyFundSettings(
      isEnabled: _prefs.getBool(_fundEnabledKey) ?? false,
      monthlySalary: _prefs.getInt(_monthlySalaryKey) ?? 0,
      targetMonths: _prefs.getInt(_targetMonthsKey) ?? 6,
      currentSavings: _prefs.getInt(_currentSavingsKey) ?? 0,
    );
  }

  /// Save the emergency fund settings.
  Future<void> saveEmergencyFundSettings(EmergencyFundSettings settings) async {
    await _prefs.setBool(_fundEnabledKey, settings.isEnabled);
    await _prefs.setInt(_monthlySalaryKey, settings.monthlySalary);
    await _prefs.setInt(_targetMonthsKey, settings.targetMonths);
    await _prefs.setInt(_currentSavingsKey, settings.currentSavings);
  }

  /// Update the current savings amount.
  Future<void> updateCurrentSavings(int amount) async {
    await _prefs.setInt(_currentSavingsKey, amount);
  }

  /// Add to the current savings.
  Future<void> addToSavings(int amount) async {
    final current = _prefs.getInt(_currentSavingsKey) ?? 0;
    await _prefs.setInt(_currentSavingsKey, current + amount);
  }
}

/// Provider for SharedPreferences (async).
final budgetRulesPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider for BudgetRulesRepository.
final budgetRulesRepositoryProvider = FutureProvider<BudgetRulesRepository>((ref) async {
  final prefs = await ref.watch(budgetRulesPrefsProvider.future);
  return BudgetRulesRepository(prefs);
});
