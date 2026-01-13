/// Frequency options for automatic contributions.
enum ContributionFrequency {
  daily('daily', 'Quotidien', 1),
  weekly('weekly', 'Hebdomadaire', 7),
  biweekly('biweekly', 'Bi-mensuel', 14),
  monthly('monthly', 'Mensuel', 30);

  const ContributionFrequency(
    this.value,
    this.displayName,
    this.daysInterval,
  );

  /// Database value.
  final String value;

  /// Localized display name.
  final String displayName;

  /// Approximate days between contributions.
  final int daysInterval;

  /// Get frequency from database value.
  static ContributionFrequency? fromValue(String? value) {
    if (value == null) return null;
    return ContributionFrequency.values.firstWhere(
      (f) => f.value == value,
      orElse: () => ContributionFrequency.monthly,
    );
  }

  /// Calculate next contribution date from a given date.
  DateTime nextDateFrom(DateTime from) {
    switch (this) {
      case ContributionFrequency.daily:
        return from.add(const Duration(days: 1));
      case ContributionFrequency.weekly:
        return from.add(const Duration(days: 7));
      case ContributionFrequency.biweekly:
        return from.add(const Duration(days: 14));
      case ContributionFrequency.monthly:
        // Add one month (handle month overflow)
        var nextMonth = from.month + 1;
        var nextYear = from.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        // Handle day overflow (e.g., Jan 31 -> Feb 28)
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final day = from.day > daysInNextMonth ? daysInNextMonth : from.day;
        return DateTime(nextYear, nextMonth, day);
    }
  }

  /// All frequencies for UI selection.
  static List<ContributionFrequency> get allFrequencies =>
      ContributionFrequency.values;
}
