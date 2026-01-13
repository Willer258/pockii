/// Status of a planned expense.
///
/// - pending: Not yet paid, still deducted from budget
/// - converted: Paid and converted to a transaction
/// - cancelled: Cancelled, no longer deducted from budget
/// - postponed: Temporarily postponed, still tracked but not deducted
enum PlannedExpenseStatus {
  /// Not yet paid, still deducted from budget.
  pending,

  /// Paid and converted to a transaction.
  converted,

  /// Cancelled, no longer deducted from budget.
  cancelled,

  /// Temporarily postponed, still tracked but not deducted.
  postponed;

  /// Converts this enum to a database string value.
  String toDbValue() {
    switch (this) {
      case PlannedExpenseStatus.pending:
        return 'pending';
      case PlannedExpenseStatus.converted:
        return 'converted';
      case PlannedExpenseStatus.cancelled:
        return 'cancelled';
      case PlannedExpenseStatus.postponed:
        return 'postponed';
    }
  }

  /// Returns the French display name for this status.
  String get displayName {
    switch (this) {
      case PlannedExpenseStatus.pending:
        return 'En attente';
      case PlannedExpenseStatus.converted:
        return 'Payé';
      case PlannedExpenseStatus.cancelled:
        return 'Annulé';
      case PlannedExpenseStatus.postponed:
        return 'Reporté';
    }
  }
}

/// Extension to parse PlannedExpenseStatus from database strings.
extension PlannedExpenseStatusParser on String {
  /// Parses a database string value to PlannedExpenseStatus.
  ///
  /// Returns [PlannedExpenseStatus.pending] for unknown values.
  PlannedExpenseStatus toPlannedExpenseStatus() {
    switch (this) {
      case 'pending':
        return PlannedExpenseStatus.pending;
      case 'converted':
        return PlannedExpenseStatus.converted;
      case 'cancelled':
        return PlannedExpenseStatus.cancelled;
      case 'postponed':
        return PlannedExpenseStatus.postponed;
      default:
        return PlannedExpenseStatus.pending;
    }
  }
}
