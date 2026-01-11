import 'package:drift/drift.dart';

/// Table for tracking user engagement streaks.
///
/// Stores the user's current streak count, longest streak achieved,
/// and last activity date to calculate streak continuation or reset.
class UserStreaks extends Table {
  /// Primary key - auto-incrementing ID.
  IntColumn get id => integer().autoIncrement()();

  /// Current consecutive days with at least one transaction.
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();

  /// Longest streak ever achieved.
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();

  /// Last date when user logged a transaction.
  /// Used to determine if streak should continue or reset.
  DateTimeColumn get lastActivityDate => dateTime().nullable()();

  /// Timestamp when this record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when this record was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
