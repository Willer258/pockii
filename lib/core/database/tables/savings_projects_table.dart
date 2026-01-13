import 'package:drift/drift.dart';

/// Table for savings projects (cagnottes/piggy banks).
///
/// Allows users to save money toward specific goals like
/// trips, electronics, gifts, etc.
/// All amounts are stored as integers (FCFA).
class SavingsProjects extends Table {
  /// Unique identifier for this savings project.
  IntColumn get id => integer().autoIncrement()();

  /// Name of the project (e.g., "Voyage à Dubaï").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Predefined category for the project.
  /// Values: travel, tech, gift, transport, home, education, event, other
  TextColumn get category => text()();

  /// Target amount to save in FCFA.
  IntColumn get targetAmountFcfa => integer()();

  /// Current amount saved in FCFA.
  IntColumn get currentAmountFcfa => integer().withDefault(const Constant(0))();

  /// Emoji icon for the project.
  TextColumn get emoji => text().withDefault(const Constant('🎯'))();

  /// Color as hex string (e.g., "FF5722").
  TextColumn get color => text().withDefault(const Constant('6750A4'))();

  /// Optional image URL or path for the project cover.
  TextColumn get imageUrl => text().nullable()();

  /// Optional target date to reach the goal.
  DateTimeColumn get targetDate => dateTime().nullable()();

  /// Whether auto-contribution is enabled.
  BoolColumn get autoContributionEnabled =>
      boolean().withDefault(const Constant(false))();

  /// Auto-contribution amount in FCFA.
  IntColumn get autoContributionAmountFcfa =>
      integer().withDefault(const Constant(0))();

  /// Auto-contribution frequency: daily, weekly, biweekly, monthly.
  TextColumn get autoContributionFrequency => text().nullable()();

  /// Next scheduled auto-contribution date.
  DateTimeColumn get nextContributionDate => dateTime().nullable()();

  /// Whether the project is archived (completed or cancelled).
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  /// Timestamp when goal was reached (if completed).
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Timestamp when this record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when this record was last updated.
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
