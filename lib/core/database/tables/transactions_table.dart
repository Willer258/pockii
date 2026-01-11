import 'package:drift/drift.dart';

/// Table for storing user transactions (expenses and incomes).
///
/// All monetary values are stored in FCFA as integers only (ARCH-7).
/// This is the core data model for Epic 2: Transaction Tracking.
class Transactions extends Table {
  /// Primary key - auto-incrementing ID
  IntColumn get id => integer().autoIncrement()();

  /// Transaction amount in FCFA (integer only, never double)
  IntColumn get amountFcfa => integer()();

  /// Transaction category (e.g., 'transport', 'food', 'salary')
  TextColumn get category => text()();

  /// Transaction type: 'expense' or 'income'
  TextColumn get type => text()();

  /// Optional note/description for the transaction
  TextColumn get note => text().nullable()();

  /// Date when the transaction occurred
  DateTimeColumn get date => dateTime()();

  /// Timestamp when this record was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
