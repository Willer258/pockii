/// Represents the frequency of a subscription payment.
///
/// Used to determine when recurring expenses are due and how they
/// affect budget calculations.
enum SubscriptionFrequency {
  /// Weekly payment (due on a specific day of each week)
  weekly,

  /// Monthly payment (due on a specific day of each month)
  monthly,

  /// Quarterly payment (every 3 months, prorated monthly as amount/3)
  quarterly,

  /// Bi-annual payment (every 6 months, prorated monthly as amount/6)
  biannual,

  /// Yearly payment (prorated monthly as amount/12)
  yearly,
}

/// Extension methods for SubscriptionFrequency.
extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  /// Converts the frequency to its database string representation.
  String toDbValue() {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return 'weekly';
      case SubscriptionFrequency.monthly:
        return 'monthly';
      case SubscriptionFrequency.quarterly:
        return 'quarterly';
      case SubscriptionFrequency.biannual:
        return 'biannual';
      case SubscriptionFrequency.yearly:
        return 'yearly';
    }
  }

  /// Returns the French display name for this frequency.
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return 'Hebdo';
      case SubscriptionFrequency.monthly:
        return 'Mensuel';
      case SubscriptionFrequency.quarterly:
        return 'Trimestre';
      case SubscriptionFrequency.biannual:
        return 'Semestre';
      case SubscriptionFrequency.yearly:
        return 'Annuel';
    }
  }

  /// Returns the number of months this frequency represents.
  /// Used for calculating monthly prorated amounts.
  int get monthsPerPeriod {
    switch (this) {
      case SubscriptionFrequency.weekly:
        return 1; // Special case: handled differently
      case SubscriptionFrequency.monthly:
        return 1;
      case SubscriptionFrequency.quarterly:
        return 3;
      case SubscriptionFrequency.biannual:
        return 6;
      case SubscriptionFrequency.yearly:
        return 12;
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
      case 'weekly':
        return SubscriptionFrequency.weekly;
      case 'monthly':
        return SubscriptionFrequency.monthly;
      case 'quarterly':
        return SubscriptionFrequency.quarterly;
      case 'biannual':
        return SubscriptionFrequency.biannual;
      case 'yearly':
        return SubscriptionFrequency.yearly;
      default:
        return SubscriptionFrequency.monthly;
    }
  }
}
