import 'package:drift/drift.dart';

/// Table for storing budget period configurations.
///
/// Each budget period represents a monthly budget allocation with
/// start and end dates. Amounts are stored in FCFA as integers only.
class BudgetPeriods extends Table {
  /// Primary key - auto-incrementing ID
  IntColumn get id => integer().autoIncrement()();

  /// Monthly budget amount in FCFA (integer only, never double)
  IntColumn get monthlyBudgetFcfa => integer()();

  /// Start date of the budget period
  DateTimeColumn get startDate => dateTime()();

  /// End date of the budget period
  DateTimeColumn get endDate => dateTime()();

  /// Timestamp when this record was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
