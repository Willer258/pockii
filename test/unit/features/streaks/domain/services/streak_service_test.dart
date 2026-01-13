import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/streaks_dao.dart';
import 'package:pockii/core/services/clock_service.dart';
import 'package:pockii/features/streaks/data/repositories/streak_repository.dart';
import 'package:pockii/features/streaks/domain/services/streak_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StreaksDao streaksDao;
  late StreakRepository streakRepository;
  late TestClock testClock;
  late StreakService service;

  setUp(() {
    db = AppDatabase.inMemory();
    testClock = TestClock(DateTime(2026, 1, 15, 10, 0)); // Jan 15, 2026 at 10:00
    streaksDao = StreaksDao(db, clock: testClock);
    streakRepository = StreakRepository(
      streaksDao: streaksDao,
      clock: testClock,
    );
    service = StreakService(
      streakRepository: streakRepository,
      clock: testClock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('StreakService', () {
    group('recordTransactionActivity', () {
      test('starts new streak at 1 when no previous activity exists', () async {
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 1);
        expect(result.longestStreak, 1);
        expect(result.action, StreakAction.started);
        expect(result.isNewMilestone, false);
      });

      test('does not change streak when already logged today', () async {
        // First activity
        await service.recordTransactionActivity();

        // Second activity same day
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 1);
        expect(result.action, StreakAction.alreadyRecorded);
      });

      test('increments streak when activity is on consecutive day', () async {
        // Day 1: First activity
        await service.recordTransactionActivity();

        // Move to next day
        testClock.setNow(DateTime(2026, 1, 16, 10, 0));

        // Day 2: Activity
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 2);
        expect(result.longestStreak, 2);
        expect(result.action, StreakAction.incremented);
      });

      test('resets and starts new streak after 2+ day gap', () async {
        // Day 1: First activity
        await service.recordTransactionActivity();

        // Skip a day and move to 2 days later
        testClock.setNow(DateTime(2026, 1, 17, 10, 0));

        // Day 3: Activity after gap
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 1);
        expect(result.longestStreak, 1);
        expect(result.action, StreakAction.resetAndStarted);
      });

      test('preserves longest streak after reset', () async {
        // Build up a 3-day streak
        await service.recordTransactionActivity(); // Day 1

        testClock.setNow(DateTime(2026, 1, 16, 10, 0));
        await service.recordTransactionActivity(); // Day 2

        testClock.setNow(DateTime(2026, 1, 17, 10, 0));
        await service.recordTransactionActivity(); // Day 3

        expect((await streakRepository.getStreak())?.longestStreak, 3);

        // Skip days and lose streak
        testClock.setNow(DateTime(2026, 1, 20, 10, 0)); // 3 days later
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 1);
        expect(result.longestStreak, 3); // Longest preserved
        expect(result.action, StreakAction.resetAndStarted);
      });

      test('detects 7-day milestone', () async {
        // Build 6-day streak
        for (var i = 0; i < 6; i++) {
          await service.recordTransactionActivity();
          testClock.setNow(DateTime(2026, 1, 15 + i + 1, 10, 0));
        }

        // Day 7 - milestone!
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 7);
        expect(result.isNewMilestone, true);
        expect(result.milestoneReached, 7);
      });

      test('does not flag milestone when already past it', () async {
        // Build 7-day streak
        for (var i = 0; i < 7; i++) {
          await service.recordTransactionActivity();
          testClock.setNow(DateTime(2026, 1, 15 + i + 1, 10, 0));
        }

        // Day 8 - past the 7-day milestone
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 8);
        expect(result.isNewMilestone, false);
        expect(result.milestoneReached, 7); // Current milestone level
      });

      test('handles month boundary correctly', () async {
        // Set to Jan 31
        testClock.setNow(DateTime(2026, 1, 31, 10, 0));
        await service.recordTransactionActivity();

        // Move to Feb 1
        testClock.setNow(DateTime(2026, 2, 1, 10, 0));
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 2);
        expect(result.action, StreakAction.incremented);
      });

      test('handles year boundary correctly', () async {
        // Set to Dec 31
        testClock.setNow(DateTime(2025, 12, 31, 10, 0));
        await service.recordTransactionActivity();

        // Move to Jan 1 next year
        testClock.setNow(DateTime(2026, 1, 1, 10, 0));
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 2);
        expect(result.action, StreakAction.incremented);
      });
    });

    group('getStreakStatus', () {
      test('returns zero streak when no data exists', () async {
        final status = await service.getStreakStatus();

        expect(status.currentStreak, 0);
        expect(status.longestStreak, 0);
        expect(status.hasActivityToday, false);
        expect(status.streakIsActive, false);
        expect(status.lastActivityDate, isNull);
      });

      test('returns correct status after recording activity', () async {
        await service.recordTransactionActivity();

        final status = await service.getStreakStatus();

        expect(status.currentStreak, 1);
        expect(status.hasActivityToday, true);
        expect(status.streakIsActive, true);
      });

      test('marks streak as active when logged yesterday', () async {
        // Log activity
        await service.recordTransactionActivity();

        // Move to next day
        testClock.setNow(DateTime(2026, 1, 16, 10, 0));

        final status = await service.getStreakStatus();

        expect(status.hasActivityToday, false);
        expect(status.streakIsActive, true); // Still can continue
      });

      test('marks streak as inactive when more than 1 day gap', () async {
        // Log activity
        await service.recordTransactionActivity();

        // Skip a day
        testClock.setNow(DateTime(2026, 1, 17, 10, 0));

        final status = await service.getStreakStatus();

        expect(status.hasActivityToday, false);
        expect(status.streakIsActive, false); // Streak broken
      });
    });

    group('willLoseStreakToday', () {
      test('returns false when no streak exists', () async {
        final willLose = await service.willLoseStreakToday();
        expect(willLose, false);
      });

      test('returns false when already logged today', () async {
        await service.recordTransactionActivity();

        final willLose = await service.willLoseStreakToday();
        expect(willLose, false);
      });

      test('returns true when logged yesterday but not today', () async {
        await service.recordTransactionActivity();

        // Move to next day
        testClock.setNow(DateTime(2026, 1, 16, 10, 0));

        final willLose = await service.willLoseStreakToday();
        expect(willLose, true);
      });

      test('returns false when streak already broken', () async {
        await service.recordTransactionActivity();

        // Skip a day (streak already broken)
        testClock.setNow(DateTime(2026, 1, 17, 10, 0));

        final willLose = await service.willLoseStreakToday();
        expect(willLose, false); // Already broken, nothing to lose
      });
    });

    group('milestone detection', () {
      test('detects 14-day milestone', () async {
        // Build 13-day streak
        for (var i = 0; i < 13; i++) {
          await service.recordTransactionActivity();
          testClock.setNow(DateTime(2026, 1, 15 + i + 1, 10, 0));
        }

        // Day 14
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 14);
        expect(result.isNewMilestone, true);
        expect(result.milestoneReached, 14);
      });

      test('detects 30-day milestone', () async {
        // Build 29-day streak
        for (var i = 0; i < 29; i++) {
          await service.recordTransactionActivity();
          testClock.setNow(DateTime(2026, 1, 15 + i + 1, 10, 0));
        }

        // Day 30
        final result = await service.recordTransactionActivity();

        expect(result.currentStreak, 30);
        expect(result.isNewMilestone, true);
        expect(result.milestoneReached, 30);
      });
    });
  });
}
