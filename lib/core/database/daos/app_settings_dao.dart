import 'package:drift/drift.dart';

import '../../services/clock_service.dart';
import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

/// Data Access Object for application settings.
///
/// Provides CRUD operations for the app_settings table.
/// Requires a [Clock] instance for testable timestamp handling.
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  final Clock _clock;

  AppSettingsDao(super.db, {Clock? clock}) : _clock = clock ?? SystemClock();

  /// Gets all settings.
  Future<List<AppSetting>> getAllSettings() {
    return select(appSettings).get();
  }

  /// Gets a setting by its key.
  Future<AppSetting?> getSettingByKey(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
  }

  /// Gets the value of a setting by key, or null if not found.
  Future<String?> getValue(String key) async {
    final setting = await getSettingByKey(key);
    return setting?.value;
  }

  /// Sets a setting value, creating it if it doesn't exist or updating if it does.
  ///
  /// Returns the ID of the setting (inserted or existing).
  Future<int> setValue(String key, String value) async {
    final existing = await getSettingByKey(key);

    if (existing != null) {
      await (update(appSettings)..where((t) => t.key.equals(key))).write(
        AppSettingsCompanion(
          value: Value(value),
          updatedAt: Value(_clock.now()),
        ),
      );
      return existing.id;
    } else {
      return into(appSettings).insert(
        AppSettingsCompanion.insert(
          key: key,
          value: value,
        ),
      );
    }
  }

  /// Deletes a setting by key.
  ///
  /// Returns the number of deleted rows (0 or 1).
  Future<int> deleteSetting(String key) {
    return (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }

  /// Watches a setting by key for reactive updates.
  Stream<AppSetting?> watchSettingByKey(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull();
  }

  /// Watches the value of a setting by key.
  Stream<String?> watchValue(String key) {
    return watchSettingByKey(key).map((setting) => setting?.value);
  }
}
