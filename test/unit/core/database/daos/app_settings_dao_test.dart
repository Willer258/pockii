import 'package:flutter_test/flutter_test.dart';
import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/app_settings_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';

void main() {
  late AppDatabase db;
  late AppSettingsDao dao;
  late TestClock testClock;

  setUp(() {
    db = AppDatabase.inMemory();
    testClock = TestClock(DateTime(2024, 6, 15, 10, 30, 0));
    dao = AppSettingsDao(db, clock: testClock);
  });

  tearDown(() async {
    await db.close();
  });

  group('AppSettingsDao', () {
    group('setValue and getValue', () {
      test('creates new setting when key does not exist', () async {
        final id = await dao.setValue('test_key', 'test_value');

        expect(id, greaterThan(0));

        final value = await dao.getValue('test_key');
        expect(value, 'test_value');
      });

      test('updates existing setting when key exists', () async {
        await dao.setValue('theme', 'light');
        await dao.setValue('theme', 'dark');

        final value = await dao.getValue('theme');
        expect(value, 'dark');
      });

      test('uses injected clock for updatedAt on update', () async {
        // Create initial setting
        await dao.setValue('test_key', 'initial');

        // Advance clock
        testClock.advance(const Duration(hours: 2));

        // Update setting
        await dao.setValue('test_key', 'updated');

        // Verify timestamp was updated with clock time
        final setting = await dao.getSettingByKey('test_key');
        expect(setting, isNotNull);
        // The updatedAt should be the advanced clock time
        expect(setting!.updatedAt, DateTime(2024, 6, 15, 12, 30, 0));
      });

      test('preserves original ID when updating', () async {
        final originalId = await dao.setValue('test_key', 'value1');
        final updatedId = await dao.setValue('test_key', 'value2');

        expect(updatedId, originalId);
      });
    });

    group('getValue', () {
      test('returns null when key does not exist', () async {
        final value = await dao.getValue('nonexistent');

        expect(value, isNull);
      });

      test('returns correct value for existing key', () async {
        await dao.setValue('my_setting', 'my_value');

        final value = await dao.getValue('my_setting');

        expect(value, 'my_value');
      });
    });

    group('getSettingByKey', () {
      test('returns full setting object', () async {
        await dao.setValue('full_setting', 'full_value');

        final setting = await dao.getSettingByKey('full_setting');

        expect(setting, isNotNull);
        expect(setting!.key, 'full_setting');
        expect(setting.value, 'full_value');
        expect(setting.id, greaterThan(0));
      });

      test('returns null for non-existent key', () async {
        final setting = await dao.getSettingByKey('does_not_exist');

        expect(setting, isNull);
      });
    });

    group('getAllSettings', () {
      test('returns empty list when no settings exist', () async {
        final settings = await dao.getAllSettings();

        expect(settings, isEmpty);
      });

      test('returns all settings', () async {
        await dao.setValue('key1', 'value1');
        await dao.setValue('key2', 'value2');
        await dao.setValue('key3', 'value3');

        final settings = await dao.getAllSettings();

        expect(settings.length, 3);
      });
    });

    group('deleteSetting', () {
      test('deletes existing setting', () async {
        await dao.setValue('to_delete', 'value');

        final deletedCount = await dao.deleteSetting('to_delete');

        expect(deletedCount, 1);

        final value = await dao.getValue('to_delete');
        expect(value, isNull);
      });

      test('returns 0 when deleting non-existent setting', () async {
        final deletedCount = await dao.deleteSetting('does_not_exist');

        expect(deletedCount, 0);
      });
    });

    group('watchSettingByKey', () {
      test('emits null for non-existent key', () async {
        final stream = dao.watchSettingByKey('nonexistent');

        expect(stream, emits(isNull));
      });

      test('emits updates when setting changes', () async {
        final stream = dao.watchValue('watched_key');

        expectLater(
          stream,
          emitsInOrder([
            isNull,
            'first_value',
          ]),
        );

        await dao.setValue('watched_key', 'first_value');
      });
    });

    group('watchValue', () {
      test('emits value changes', () async {
        await dao.setValue('changing_key', 'initial');

        final stream = dao.watchValue('changing_key');

        expectLater(
          stream,
          emitsInOrder([
            'initial',
            'changed',
          ]),
        );

        await dao.setValue('changing_key', 'changed');
      });
    });
  });
}
