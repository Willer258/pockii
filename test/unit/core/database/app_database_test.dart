import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:accountapp/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    // Use in-memory database for tests (no encryption)
    db = AppDatabase.inMemory();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('initializes in-memory database successfully', () {
      expect(db, isNotNull);
    });

    test('has correct schema version', () {
      expect(db.schemaVersion, 5);
    });
  });

  group('budget_periods table', () {
    test('inserts a budget period', () async {
      final id = await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 350000,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      expect(id, greaterThan(0));
    });

    test('retrieves inserted budget period', () async {
      await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 350000,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      final periods = await db.select(db.budgetPeriods).get();

      expect(periods.length, 1);
      expect(periods.first.monthlyBudgetFcfa, 350000);
      expect(periods.first.startDate, DateTime(2024, 1, 1));
      expect(periods.first.endDate, DateTime(2024, 1, 31));
    });

    test('updates budget period', () async {
      final id = await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 350000,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      await (db.update(db.budgetPeriods)..where((t) => t.id.equals(id))).write(
        const BudgetPeriodsCompanion(
          monthlyBudgetFcfa: Value(400000),
        ),
      );

      final period = await (db.select(db.budgetPeriods)
            ..where((t) => t.id.equals(id)))
          .getSingle();

      expect(period.monthlyBudgetFcfa, 400000);
    });

    test('deletes budget period', () async {
      final id = await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 350000,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      await (db.delete(db.budgetPeriods)..where((t) => t.id.equals(id))).go();

      final periods = await db.select(db.budgetPeriods).get();
      expect(periods, isEmpty);
    });

    test('stores createdAt automatically', () async {
      final beforeInsert = DateTime.now();

      await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 350000,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      final afterInsert = DateTime.now();

      final period = await db.select(db.budgetPeriods).getSingle();

      // createdAt should be between before and after (with some tolerance)
      expect(
        period.createdAt.isAfter(beforeInsert.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        period.createdAt.isBefore(afterInsert.add(const Duration(seconds: 1))),
        true,
      );
    });

    test('handles large FCFA amounts as integers', () async {
      // Test with a large but valid FCFA amount (999,999,999)
      await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 999999999,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      final period = await db.select(db.budgetPeriods).getSingle();
      expect(period.monthlyBudgetFcfa, 999999999);
    });

    test('stores minimum FCFA amount', () async {
      await db.into(db.budgetPeriods).insert(
            BudgetPeriodsCompanion.insert(
              monthlyBudgetFcfa: 1,
              startDate: DateTime(2024, 1, 1),
              endDate: DateTime(2024, 1, 31),
            ),
          );

      final period = await db.select(db.budgetPeriods).getSingle();
      expect(period.monthlyBudgetFcfa, 1);
    });
  });

  group('app_settings table', () {
    test('inserts a setting', () async {
      final id = await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'theme_mode',
              value: 'dark',
            ),
          );

      expect(id, greaterThan(0));
    });

    test('retrieves setting by key', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'theme_mode',
              value: 'dark',
            ),
          );

      final setting = await (db.select(db.appSettings)
            ..where((t) => t.key.equals('theme_mode')))
          .getSingleOrNull();

      expect(setting, isNotNull);
      expect(setting!.value, 'dark');
    });

    test('enforces unique key constraint', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'theme_mode',
              value: 'dark',
            ),
          );

      // Attempting to insert duplicate key should throw
      expect(
        () => db.into(db.appSettings).insert(
              AppSettingsCompanion.insert(
                key: 'theme_mode',
                value: 'light',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('updates setting value', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'theme_mode',
              value: 'dark',
            ),
          );

      await (db.update(db.appSettings)..where((t) => t.key.equals('theme_mode')))
          .write(
        const AppSettingsCompanion(
          value: Value('light'),
        ),
      );

      final setting = await (db.select(db.appSettings)
            ..where((t) => t.key.equals('theme_mode')))
          .getSingle();

      expect(setting.value, 'light');
    });

    test('deletes setting', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'test_setting',
              value: 'test_value',
            ),
          );

      await (db.delete(db.appSettings)..where((t) => t.key.equals('test_setting')))
          .go();

      final setting = await (db.select(db.appSettings)
            ..where((t) => t.key.equals('test_setting')))
          .getSingleOrNull();

      expect(setting, isNull);
    });

    test('stores multiple settings', () async {
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(key: 'setting1', value: 'value1'),
          );
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(key: 'setting2', value: 'value2'),
          );
      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(key: 'setting3', value: 'value3'),
          );

      final settings = await db.select(db.appSettings).get();
      expect(settings.length, 3);
    });

    test('stores updatedAt automatically', () async {
      final beforeInsert = DateTime.now();

      await db.into(db.appSettings).insert(
            AppSettingsCompanion.insert(
              key: 'test_key',
              value: 'test_value',
            ),
          );

      final afterInsert = DateTime.now();

      final setting = await db.select(db.appSettings).getSingle();

      expect(
        setting.updatedAt.isAfter(beforeInsert.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        setting.updatedAt.isBefore(afterInsert.add(const Duration(seconds: 1))),
        true,
      );
    });
  });
}
