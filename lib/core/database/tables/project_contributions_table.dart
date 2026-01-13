import 'package:drift/drift.dart';

import 'savings_projects_table.dart';

/// Table for tracking contributions to savings projects.
///
/// Each record represents a deposit or withdrawal from a project.
/// All amounts are stored as integers (FCFA).
class ProjectContributions extends Table {
  /// Unique identifier for this contribution.
  IntColumn get id => integer().autoIncrement()();

  /// Reference to the savings project.
  IntColumn get projectId =>
      integer().references(SavingsProjects, #id, onDelete: KeyAction.cascade)();

  /// Amount in FCFA. Positive = deposit, Negative = withdrawal.
  IntColumn get amountFcfa => integer()();

  /// Type of contribution: deposit, withdrawal, auto_deposit, auto_failed.
  TextColumn get type => text()();

  /// Optional note for this contribution.
  TextColumn get note => text().nullable()();

  /// Date of the contribution.
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();

  /// Timestamp when this record was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
