import 'dart:convert';

import 'package:accountapp/core/database/daos/app_settings_dao.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/core/services/subscription_reminder_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

class MockClock extends Mock implements Clock {}

void main() {
  late MockAppSettingsDao mockSettingsDao;
  late MockClock mockClock;
  late SubscriptionReminderTracker tracker;

  setUp(() {
    mockSettingsDao = MockAppSettingsDao();
    mockClock = MockClock();
    tracker = SubscriptionReminderTracker(
      settingsDao: mockSettingsDao,
      clock: mockClock,
    );

    // Default: January 2026
    when(() => mockClock.now()).thenReturn(DateTime(2026, 1, 15));
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any()))
        .thenAnswer((_) async => 1);
    when(() => mockSettingsDao.deleteSetting(any()))
        .thenAnswer((_) async => 1);
  });

  group('SubscriptionReminderTracker', () {
    group('shouldSendReminder', () {
      test('returns true when no reminder sent this month', () async {
        final result = await tracker.shouldSendReminder(1);

        expect(result, isTrue);
      });

      test('returns false when already reminded this month', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2026-01'}));

        final result = await tracker.shouldSendReminder(1);

        expect(result, isFalse);
      });

      test('returns true when reminded in different month', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2025-12'}));

        final result = await tracker.shouldSendReminder(1);

        expect(result, isTrue);
      });

      test('returns true for different subscription ID', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2026-01'}));

        final result = await tracker.shouldSendReminder(2);

        expect(result, isTrue);
      });
    });

    group('markAsReminded', () {
      test('stores subscription ID with current month', () async {
        await tracker.markAsReminded(1);

        verify(() => mockSettingsDao.setValue(
              SubscriptionReminderKeys.remindedSubscriptions,
              any(that: contains('"1":"2026-01"')),
            )).called(1);
      });

      test('preserves existing reminders from current month', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'2': '2026-01'}));

        await tracker.markAsReminded(1);

        verify(() => mockSettingsDao.setValue(
              SubscriptionReminderKeys.remindedSubscriptions,
              any(
                that: allOf(
                  contains('"1":"2026-01"'),
                  contains('"2":"2026-01"'),
                ),
              ),
            )).called(1);
      });

      test('cleans up reminders from previous months', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'2': '2025-12'}));

        await tracker.markAsReminded(1);

        // Should only contain the new reminder, old one cleaned up
        final captured = verify(() => mockSettingsDao.setValue(
              SubscriptionReminderKeys.remindedSubscriptions,
              captureAny(),
            )).captured.single as String;

        final decoded = jsonDecode(captured) as Map<String, dynamic>;
        expect(decoded.containsKey('2'), isFalse);
        expect(decoded['1'], equals('2026-01'));
      });
    });

    group('markMultipleAsReminded', () {
      test('stores all subscription IDs with current month', () async {
        await tracker.markMultipleAsReminded([1, 2, 3]);

        final captured = verify(() => mockSettingsDao.setValue(
              SubscriptionReminderKeys.remindedSubscriptions,
              captureAny(),
            )).captured.single as String;

        final decoded = jsonDecode(captured) as Map<String, dynamic>;
        expect(decoded['1'], equals('2026-01'));
        expect(decoded['2'], equals('2026-01'));
        expect(decoded['3'], equals('2026-01'));
      });
    });

    group('filterUnreminded', () {
      test('returns all IDs when none reminded', () async {
        final result = await tracker.filterUnreminded([1, 2, 3]);

        expect(result, equals([1, 2, 3]));
      });

      test('filters out reminded IDs', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2026-01', '3': '2026-01'}));

        final result = await tracker.filterUnreminded([1, 2, 3]);

        expect(result, equals([2]));
      });

      test('returns all IDs when reminded in different month', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2025-12', '2': '2025-12'}));

        final result = await tracker.filterUnreminded([1, 2, 3]);

        expect(result, equals([1, 2, 3]));
      });

      test('returns empty list when all reminded', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer(
                (_) async => jsonEncode({'1': '2026-01', '2': '2026-01'}));

        final result = await tracker.filterUnreminded([1, 2]);

        expect(result, isEmpty);
      });
    });

    group('resetAll', () {
      test('deletes reminder tracking setting', () async {
        await tracker.resetAll();

        verify(() => mockSettingsDao
            .deleteSetting(SubscriptionReminderKeys.remindedSubscriptions)).called(1);
      });
    });

    group('month transitions', () {
      test('new month allows reminders for previously reminded subscriptions',
          () async {
        // Simulate being reminded in January
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => jsonEncode({'1': '2026-01'}));

        // Now it's February
        when(() => mockClock.now()).thenReturn(DateTime(2026, 2, 15));

        final result = await tracker.shouldSendReminder(1);

        expect(result, isTrue);
      });

      test('formats month with leading zero', () async {
        when(() => mockClock.now()).thenReturn(DateTime(2026, 5, 10));

        await tracker.markAsReminded(1);

        verify(() => mockSettingsDao.setValue(
              SubscriptionReminderKeys.remindedSubscriptions,
              any(that: contains('2026-05')),
            )).called(1);
      });
    });

    group('corrupted data handling', () {
      test('handles corrupted JSON gracefully', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => 'not valid json');

        final result = await tracker.shouldSendReminder(1);

        // Should treat as no reminders sent
        expect(result, isTrue);
      });

      test('handles empty string gracefully', () async {
        when(() => mockSettingsDao.getValue(
                SubscriptionReminderKeys.remindedSubscriptions))
            .thenAnswer((_) async => '');

        final result = await tracker.shouldSendReminder(1);

        expect(result, isTrue);
      });
    });
  });
}
