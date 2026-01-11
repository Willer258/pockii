/// Status of a planned expense.
///
/// - pending: Not yet paid, still deducted from budget
/// - converted: Paid and converted to a transaction
/// - cancelled: Cancelled, no longer deducted from budget
enum PlannedExpenseStatus {
  /// Not yet paid, still deducted from budget.
  pending,

  /// Paid and converted to a transaction.
  converted,

  /// Cancelled, no longer deducted from budget.
  cancelled;

  /// Converts this enum to a database string value.
  String toDbValue() {
    switch (this) {
      case PlannedExpenseStatus.pending:
        return 'pending';
      case PlannedExpenseStatus.converted:
        return 'converted';
      case PlannedExpenseStatus.cancelled:
        return 'cancelled';
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
      default:
        return PlannedExpenseStatus.pending;
    }
  }
}
