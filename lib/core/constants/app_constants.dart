/// Application-wide constants.
///
/// Centralizes magic numbers and configuration values.
abstract class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ==========================================================================
  // App Info
  // ==========================================================================
  static const String appName = 'Pockii';
  static const String appTagline = 'Ton budget, simplifié';
  static const String appVersion = '0.1.0';

  // ==========================================================================
  // Database
  // ==========================================================================
  static const String databaseName = 'pockii.db';
  static const int databaseVersion = 1;

  // ==========================================================================
  // Budget
  // ==========================================================================
  /// Minimum allowed budget in FCFA
  static const int minBudgetFcfa = 1000;

  /// Maximum allowed budget in FCFA (safety limit)
  static const int maxBudgetFcfa = 999999999;

  /// Default budget suggestion for onboarding
  static const int defaultBudgetFcfa = 100000;

  // ==========================================================================
  // Transactions
  // ==========================================================================
  /// Minimum transaction amount in FCFA
  static const int minTransactionFcfa = 1;

  /// Maximum transaction amount in FCFA
  static const int maxTransactionFcfa = 99999999;

  // ==========================================================================
  // UI
  // ==========================================================================
  /// Animation duration for standard transitions
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Debounce duration for search inputs
  static const Duration debounceDelay = Duration(milliseconds: 300);

  // ==========================================================================
  // Settings Keys
  // ==========================================================================
  static const String settingThemeMode = 'theme_mode';
  static const String settingNotificationsEnabled = 'notifications_enabled';
  static const String settingOnboardingCompleted = 'onboarding_completed';
  static const String settingCurrentBudgetPeriodId = 'current_budget_period_id';
}
