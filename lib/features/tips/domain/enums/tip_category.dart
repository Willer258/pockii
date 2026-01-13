/// Categories of financial tips based on budget state.
enum TipCategory {
  /// Tips for when budget is healthy (>50%)
  /// Focus: Investment, long-term savings
  investment,

  /// Tips for when budget is healthy (>50%)
  /// Focus: Building emergency fund, smart savings
  savings,

  /// Tips for when budget is moderate (20-50%)
  /// Focus: Practical optimization advice
  optimization,

  /// Tips for when budget is moderate (20-50%)
  /// Focus: Daily economy tips
  economy,

  /// Tips for when budget is low (<20%)
  /// Focus: Essential survival strategies
  survival,

  /// Tips for when budget is low (<20%)
  /// Focus: Emotional support and encouragement
  support;

  /// Get categories appropriate for a budget percentage.
  static List<TipCategory> forBudgetPercentage(double percentage) {
    if (percentage > 0.5) {
      return [investment, savings];
    } else if (percentage > 0.2) {
      return [optimization, economy];
    } else {
      return [survival, support];
    }
  }

  /// Display name in French.
  String get displayName {
    switch (this) {
      case TipCategory.investment:
        return 'Investissement';
      case TipCategory.savings:
        return 'Épargne';
      case TipCategory.optimization:
        return 'Optimisation';
      case TipCategory.economy:
        return 'Économie';
      case TipCategory.survival:
        return 'Essentiel';
      case TipCategory.support:
        return 'Soutien';
    }
  }

  /// Emoji for the category.
  String get emoji {
    switch (this) {
      case TipCategory.investment:
        return '📈';
      case TipCategory.savings:
        return '🏦';
      case TipCategory.optimization:
        return '⚡';
      case TipCategory.economy:
        return '💡';
      case TipCategory.survival:
        return '🎯';
      case TipCategory.support:
        return '💪';
    }
  }
}
