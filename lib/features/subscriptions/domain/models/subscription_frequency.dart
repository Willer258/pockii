/// Represents the frequency of a subscription payment.
///
/// Used to determine when recurring expenses are due and how they
/// affect budget calculations.
enum SubscriptionFrequency {
  /// Monthly payment (due on a specific day of each month)
  monthly,

  /// Weekly payment (due on a specific day of each week)
  weekly,

  /// Yearly payment (prorated monthly as amount/12)
  yearly,
}

/// Extension methods for SubscriptionFrequency.
extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  /// Converts the frequency to its database string representation.
  String toDbValue() {
    switch (this) {
      case SubscriptionFrequency.monthly:
        return 'monthly';
      case SubscriptionFrequency.weekly:
        return 'weekly';
      case SubscriptionFrequency.yearly:
        return 'yearly';
    }
  }

  /// Returns the French display name for this frequency.
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.monthly:
        return 'Mensuel';
      case SubscriptionFrequency.weekly:
        return 'Hebdomadaire';
      case SubscriptionFrequency.yearly:
        return 'Annuel';
    }
  }
}

/// Parser for converting database values to SubscriptionFrequency.
class SubscriptionFrequencyParser {
  /// Converts a database string value to a SubscriptionFrequency.
  ///
  /// Defaults to monthly if the value is unrecognized.
  static SubscriptionFrequency fromDbValue(String value) {
    switch (value) {
      case 'monthly':
        return SubscriptionFrequency.monthly;
      case 'weekly':
        return SubscriptionFrequency.weekly;
      case 'yearly':
        return SubscriptionFrequency.yearly;
      default:
        return SubscriptionFrequency.monthly;
    }
  }
}
