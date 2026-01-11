import 'package:accountapp/core/services/budget_notification_tracker.dart';
import 'package:accountapp/core/database/daos/app_settings_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

void main() {
  late MockAppSettingsDao mockSettingsDao;
  late BudgetNotificationTracker tracker;

  setUp(() {
    mockSettingsDao = MockAppSettingsDao();
    tracker = BudgetNotificationTracker(settingsDao: mockSettingsDao);

    // Default: no existing settings
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any())).thenAnswer((_) async => 1);
    when(() => mockSettingsDao.deleteSetting(any())).thenAnswer((_) async => 1);
  });

  group('BudgetNotificationTracker', () {
    group('shouldSendWarning', () {
      test('returns true when below 30% and not yet notified', () async {
        final result = await tracker.shouldSendWarning(25.0);

        expect(result, isTrue);
        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.warningNotified,
              'true',
            )).called(1);
      });

      test('returns false when already notified', () async {
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.warningNotified))
            .thenAnswer((_) async => 'true');

        final result = await tracker.shouldSendWarning(25.0);

        expect(result, isFalse);
      });

      test('returns false when above 30%', () async {
        final result = await tracker.shouldSendWarning(35.0);

        expect(result, isFalse);
      });

      test('returns false when at or below 10% (critical zone)', () async {
        final result = await tracker.shouldSendWarning(10.0);

        expect(result, isFalse);
      });
    });

    group('shouldSendCritical', () {
      test('returns true when below 10% and not yet notified', () async {
        final result = await tracker.shouldSendCritical(8.0);

        expect(result, isTrue);
        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.criticalNotified,
              'true',
            )).called(1);
      });

      test('returns false when already notified', () async {
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.criticalNotified))
            .thenAnswer((_) async => 'true');

        final result = await tracker.shouldSendCritical(8.0);

        expect(result, isFalse);
      });

      test('returns false when above 10%', () async {
        final result = await tracker.shouldSendCritical(15.0);

        expect(result, isFalse);
      });

      test('returns false when budget is 0 or negative', () async {
        final result = await tracker.shouldSendCritical(0.0);

        expect(result, isFalse);
      });
    });

    group('updateBudgetPercent', () {
      test('resets warning notification when budget recovers above 30%', () async {
        // Set last percent below warning threshold
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.lastBudgetPercent))
            .thenAnswer((_) async => '25.0');

        await tracker.updateBudgetPercent(35.0);

        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.warningNotified,
              'false',
            )).called(1);
      });

      test('resets critical notification when budget recovers above 10%', () async {
        // Set last percent below critical threshold
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.lastBudgetPercent))
            .thenAnswer((_) async => '5.0');

        await tracker.updateBudgetPercent(15.0);

        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.criticalNotified,
              'false',
            )).called(1);
      });

      test('does not reset when still below threshold', () async {
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.lastBudgetPercent))
            .thenAnswer((_) async => '20.0');

        await tracker.updateBudgetPercent(22.0);

        verifyNever(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.warningNotified,
              'false',
            ));
      });

      test('stores current percent for next comparison', () async {
        await tracker.updateBudgetPercent(45.0);

        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.lastBudgetPercent,
              '45.0',
            )).called(1);
      });
    });

    group('checkAndUpdateState', () {
      test('returns critical when budget drops below 10%', () async {
        final result = await tracker.checkAndUpdateState(8.0);

        expect(result, equals(BudgetNotificationResult.critical));
      });

      test('returns warning when budget between 10% and 30%', () async {
        final result = await tracker.checkAndUpdateState(25.0);

        expect(result, equals(BudgetNotificationResult.warning));
      });

      test('returns none when budget above 30%', () async {
        final result = await tracker.checkAndUpdateState(50.0);

        expect(result, equals(BudgetNotificationResult.none));
      });

      test('returns none when already notified for warning', () async {
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.warningNotified))
            .thenAnswer((_) async => 'true');

        final result = await tracker.checkAndUpdateState(25.0);

        expect(result, equals(BudgetNotificationResult.none));
      });

      test('returns none when already notified for critical', () async {
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.criticalNotified))
            .thenAnswer((_) async => 'true');

        final result = await tracker.checkAndUpdateState(8.0);

        expect(result, equals(BudgetNotificationResult.none));
      });

      test('resets and sends new notification when budget recovers and drops again', () async {
        // Simulate budget dropping to 25% (warning sent)
        var result = await tracker.checkAndUpdateState(25.0);
        expect(result, equals(BudgetNotificationResult.warning));

        // Simulate warning already sent
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.warningNotified))
            .thenAnswer((_) async => 'true');
        when(() => mockSettingsDao.getValue(BudgetNotificationKeys.lastBudgetPercent))
            .thenAnswer((_) async => '25.0');

        // Budget recovers to 35%
        result = await tracker.checkAndUpdateState(35.0);
        expect(result, equals(BudgetNotificationResult.none));

        // Verify warning was reset
        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.warningNotified,
              'false',
            )).called(1);
      });
    });

    group('resetAll', () {
      test('resets all notification states', () async {
        await tracker.resetAll();

        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.warningNotified,
              'false',
            )).called(1);
        verify(() => mockSettingsDao.setValue(
              BudgetNotificationKeys.criticalNotified,
              'false',
            )).called(1);
        verify(() => mockSettingsDao.deleteSetting(
              BudgetNotificationKeys.lastBudgetPercent,
            )).called(1);
      });
    });

    group('thresholds', () {
      test('warning threshold is 30%', () {
        expect(BudgetNotificationTracker.warningThreshold, equals(30.0));
      });

      test('critical threshold is 10%', () {
        expect(BudgetNotificationTracker.criticalThreshold, equals(10.0));
      });
    });
  });
}
