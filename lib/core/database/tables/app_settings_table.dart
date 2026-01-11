import 'package:drift/drift.dart';

/// Table for storing application settings as key-value pairs.
///
/// Used for persisting user preferences and app configuration.
class AppSettings extends Table {
  /// Primary key - auto-incrementing ID
  IntColumn get id => integer().autoIncrement()();

  /// Unique setting key (e.g., 'theme_mode', 'notification_enabled')
  TextColumn get key => text().unique()();

  /// Setting value stored as text (parse as needed)
  TextColumn get value => text()();

  /// Timestamp when this setting was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
