import 'package:drift/drift.dart';

/// Table for storing recurring expenses (subscriptions, tontines, obligations).
///
/// All monetary values are stored in FCFA as integers only (ARCH-7).
/// This is the core data model for Epic 3: Recurring Expenses & Planning.
class Subscriptions extends Table {
  /// Primary key - auto-incrementing ID
  IntColumn get id => integer().autoIncrement()();

  /// Subscription name (e.g., 'Netflix', 'Tontine famille', 'Orange Money')
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Amount in FCFA (integer only, never double)
  IntColumn get amountFcfa => integer()();

  /// Category for grouping (e.g., 'entertainment', 'family', 'utilities')
  TextColumn get category => text()();

  /// Frequency: 'monthly', 'weekly', or 'yearly'
  TextColumn get frequency => text()();

  /// Day of the period when payment is due (1-31 for monthly, 1-7 for weekly)
  IntColumn get dueDay => integer()();

  /// Whether this subscription is currently active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Timestamp when this record was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when this record was last updated
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
