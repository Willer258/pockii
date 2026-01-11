import 'package:accountapp/core/database/daos/app_settings_dao.dart';
import 'package:accountapp/core/services/streak_celebration_tracker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAppSettingsDao extends Mock implements AppSettingsDao {}

void main() {
  late MockAppSettingsDao mockSettingsDao;
  late StreakCelebrationTracker tracker;

  setUp(() {
    mockSettingsDao = MockAppSettingsDao();
    tracker = StreakCelebrationTracker(settingsDao: mockSettingsDao);

    // Default: no existing settings
    when(() => mockSettingsDao.getValue(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDao.setValue(any(), any()))
        .thenAnswer((_) async => 1);
    when(() => mockSettingsDao.deleteSetting(any()))
        .thenAnswer((_) async => 1);
  });

  group('StreakCelebrationTracker', () {
    group('shouldSendNotification', () {
      test('returns true for milestone 7 when not yet notified', () async {
        final result = await tracker.shouldSendNotification(7);

        expect(result, isTrue);
      });

      test('returns true for milestone 14 when last notified was 7', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '7');

        final result = await tracker.shouldSendNotification(14);

        expect(result, isTrue);
      });

      test('returns false for non-milestone values', () async {
        final result = await tracker.shouldSendNotification(5);

        expect(result, isFalse);
      });

      test('returns false when milestone already notified', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '14');

        final result = await tracker.shouldSendNotification(7);

        expect(result, isFalse);
      });

      test('returns false when same milestone was notified', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '7');

        final result = await tracker.shouldSendNotification(7);

        expect(result, isFalse);
      });
    });

    group('markMilestoneNotified', () {
      test('stores milestone in settings', () async {
        await tracker.markMilestoneNotified(7);

        verify(() => mockSettingsDao.setValue(
              StreakCelebrationKeys.lastNotifiedMilestone,
              '7',
            )).called(1);
      });

      test('sets pending celebration', () async {
        await tracker.markMilestoneNotified(14);

        verify(() => mockSettingsDao.setValue(
              StreakCelebrationKeys.pendingCelebration,
              '14',
            )).called(1);
      });
    });

    group('getPendingCelebration', () {
      test('returns null when no pending celebration', () async {
        final result = await tracker.getPendingCelebration();

        expect(result, isNull);
      });

      test('returns milestone when celebration is pending', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.pendingCelebration))
            .thenAnswer((_) async => '30');

        final result = await tracker.getPendingCelebration();

        expect(result, equals(30));
      });

      test('returns null for empty string', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.pendingCelebration))
            .thenAnswer((_) async => '');

        final result = await tracker.getPendingCelebration();

        expect(result, isNull);
      });
    });

    group('clearPendingCelebration', () {
      test('deletes pending celebration setting', () async {
        await tracker.clearPendingCelebration();

        verify(() => mockSettingsDao
            .deleteSetting(StreakCelebrationKeys.pendingCelebration)).called(1);
      });
    });

    group('checkAndMarkMilestone', () {
      test('returns milestone when should notify', () async {
        final result = await tracker.checkAndMarkMilestone(7);

        expect(result, equals(7));
      });

      test('marks milestone as notified', () async {
        await tracker.checkAndMarkMilestone(7);

        verify(() => mockSettingsDao.setValue(
              StreakCelebrationKeys.lastNotifiedMilestone,
              '7',
            )).called(1);
      });

      test('returns null for non-milestone', () async {
        final result = await tracker.checkAndMarkMilestone(5);

        expect(result, isNull);
      });

      test('returns null when already notified', () async {
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '7');

        final result = await tracker.checkAndMarkMilestone(7);

        expect(result, isNull);
      });
    });

    group('resetOnStreakBroken', () {
      test('resets last notified milestone to 0', () async {
        await tracker.resetOnStreakBroken();

        verify(() => mockSettingsDao.setValue(
              StreakCelebrationKeys.lastNotifiedMilestone,
              '0',
            )).called(1);
      });
    });

    group('resetAll', () {
      test('deletes all celebration tracking settings', () async {
        await tracker.resetAll();

        verify(() => mockSettingsDao
            .deleteSetting(StreakCelebrationKeys.lastNotifiedMilestone)).called(1);
        verify(() => mockSettingsDao
            .deleteSetting(StreakCelebrationKeys.pendingCelebration)).called(1);
      });
    });

    group('StreakMilestones', () {
      test('contains expected milestones', () {
        expect(
          StreakMilestones.all,
          equals([7, 14, 30, 60, 90, 180, 365]),
        );
      });

      test('isMilestone returns true for valid milestones', () {
        expect(StreakMilestones.isMilestone(7), isTrue);
        expect(StreakMilestones.isMilestone(14), isTrue);
        expect(StreakMilestones.isMilestone(30), isTrue);
        expect(StreakMilestones.isMilestone(60), isTrue);
        expect(StreakMilestones.isMilestone(90), isTrue);
        expect(StreakMilestones.isMilestone(180), isTrue);
        expect(StreakMilestones.isMilestone(365), isTrue);
      });

      test('isMilestone returns false for non-milestones', () {
        expect(StreakMilestones.isMilestone(0), isFalse);
        expect(StreakMilestones.isMilestone(1), isFalse);
        expect(StreakMilestones.isMilestone(5), isFalse);
        expect(StreakMilestones.isMilestone(10), isFalse);
        expect(StreakMilestones.isMilestone(100), isFalse);
      });
    });

    group('getCelebrationMessage', () {
      test('returns correct message for 7 days', () {
        expect(getCelebrationMessage(7), contains('7 jours'));
      });

      test('returns correct message for 14 days', () {
        expect(getCelebrationMessage(14), contains('14 jours'));
      });

      test('returns correct message for 30 days', () {
        expect(getCelebrationMessage(30), contains('30 jours'));
      });

      test('returns default message for non-standard milestone', () {
        expect(getCelebrationMessage(25), contains('25 jours'));
      });
    });

    group('getCelebrationEmoji', () {
      test('returns party emoji for 7 days', () {
        expect(getCelebrationEmoji(7), equals('🎉'));
      });

      test('returns fire emoji for 14 days', () {
        expect(getCelebrationEmoji(14), equals('🔥'));
      });

      test('returns crown emoji for 30 days', () {
        expect(getCelebrationEmoji(30), equals('👑'));
      });

      test('returns fire emoji for non-standard milestone', () {
        expect(getCelebrationEmoji(25), equals('🔥'));
      });
    });

    group('streak rebuild after break', () {
      test('can celebrate same milestone after streak broken and rebuilt',
          () async {
        // First time: celebrate 7 days
        var result = await tracker.checkAndMarkMilestone(7);
        expect(result, equals(7));

        // Simulate milestone was saved
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '7');

        // Same milestone should not notify again
        result = await tracker.checkAndMarkMilestone(7);
        expect(result, isNull);

        // Streak broken - reset
        await tracker.resetOnStreakBroken();

        // Update mock to reflect reset
        when(() => mockSettingsDao.getValue(
                StreakCelebrationKeys.lastNotifiedMilestone))
            .thenAnswer((_) async => '0');

        // Now should celebrate 7 again
        result = await tracker.checkAndMarkMilestone(7);
        expect(result, equals(7));
      });
    });
  });
}
