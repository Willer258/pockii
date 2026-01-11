import 'package:drift/drift.dart';

/// Table for planned future expenses (one-time, not recurring).
///
/// Planned expenses are deducted from the budget before they occur,
/// allowing users to reserve money for upcoming purchases.
/// All amounts are stored as integers (FCFA, ARCH-7).
class PlannedExpenses extends Table {
  /// Unique identifier for this planned expense.
  IntColumn get id => integer().autoIncrement()();

  /// Description of the planned expense (e.g., "New phone", "Car repair").
  TextColumn get description => text().withLength(min: 1, max: 200)();

  /// Amount in FCFA (integer only, never double).
  IntColumn get amountFcfa => integer()();

  /// Expected date when the expense will occur.
  /// Must be in the future when created.
  DateTimeColumn get expectedDate => dateTime()();

  /// Status of the planned expense.
  /// - pending: Not yet paid, still deducted from budget
  /// - converted: Paid and converted to a transaction
  /// - cancelled: Cancelled, no longer deducted from budget
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Optional category for the expense.
  TextColumn get category => text().nullable()();

  /// Timestamp when this record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when this record was last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
