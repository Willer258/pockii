/// Settings and progress for the 6-month emergency fund goal.
class EmergencyFundSettings {
  const EmergencyFundSettings({
    required this.isEnabled,
    required this.monthlySalary,
    required this.targetMonths,
    required this.currentSavings,
  });

  /// Default settings (disabled, 6 months target).
  factory EmergencyFundSettings.defaultSettings() {
    return const EmergencyFundSettings(
      isEnabled: false,
      monthlySalary: 0,
      targetMonths: 6,
      currentSavings: 0,
    );
  }

  /// Whether the emergency fund feature is enabled.
  final bool isEnabled;

  /// Monthly salary/income in FCFA.
  final int monthlySalary;

  /// Target number of months to save (default 6).
  final int targetMonths;

  /// Current savings towards the goal in FCFA.
  final int currentSavings;

  /// Target amount = salary * target months.
  int get targetAmount => monthlySalary * targetMonths;

  /// Remaining amount to reach the goal.
  int get remainingAmount => (targetAmount - currentSavings).clamp(0, targetAmount);

  /// Progress percentage (0.0 to 1.0).
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentSavings / targetAmount).clamp(0.0, 1.0);
  }

  /// Number of months currently saved.
  double get monthsSaved {
    if (monthlySalary == 0) return 0;
    return currentSavings / monthlySalary;
  }

  /// Whether the goal has been reached.
  bool get isGoalReached => currentSavings >= targetAmount;

  /// Status message based on progress.
  String get statusMessage {
    if (!isEnabled) return 'Non configuré';
    if (monthlySalary == 0) return 'Configurez votre salaire';
    if (isGoalReached) return 'Objectif atteint!';

    final monthsRemaining = targetMonths - monthsSaved;
    if (monthsRemaining <= 1) {
      return 'Presque terminé!';
    } else if (monthsRemaining <= 3) {
      return 'Bon progrès!';
    } else {
      return '${monthsSaved.toStringAsFixed(1)} mois épargnés';
    }
  }

  /// Motivational tip based on progress.
  String get motivationalTip {
    if (!isEnabled || monthlySalary == 0) {
      return 'Un fonds d\'urgence de 6 mois te protège contre les imprévus.';
    }

    final progress = progressPercentage;
    if (progress >= 1.0) {
      return 'Bravo! Tu es financièrement sécurisé. Continue à épargner!';
    } else if (progress >= 0.75) {
      return 'Excellent! Encore un petit effort pour atteindre ton objectif.';
    } else if (progress >= 0.5) {
      return 'Tu es à mi-chemin! Continue comme ça.';
    } else if (progress >= 0.25) {
      return 'Bon début! Chaque FCFA compte.';
    } else {
      return 'Commence petit. L\'important c\'est la régularité.';
    }
  }

  EmergencyFundSettings copyWith({
    bool? isEnabled,
    int? monthlySalary,
    int? targetMonths,
    int? currentSavings,
  }) {
    return EmergencyFundSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      targetMonths: targetMonths ?? this.targetMonths,
      currentSavings: currentSavings ?? this.currentSavings,
    );
  }
}
