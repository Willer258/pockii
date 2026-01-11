import 'package:flutter_test/flutter_test.dart';
import 'package:accountapp/core/services/clock_service.dart';

void main() {
  group('SystemClock', () {
    test('now() returns current time', () {
      final clock = SystemClock();
      final before = DateTime.now();
      final result = clock.now();
      final after = DateTime.now();

      // Result should be between before and after (or equal)
      expect(
        result.isAfter(before) || result.isAtSameMomentAs(before),
        true,
      );
      expect(
        result.isBefore(after) || result.isAtSameMomentAs(after),
        true,
      );
    });

    test('today() returns midnight of current day', () {
      final clock = SystemClock();
      final now = DateTime.now();
      final today = clock.today();

      expect(today.year, now.year);
      expect(today.month, now.month);
      expect(today.day, now.day);
      expect(today.hour, 0);
      expect(today.minute, 0);
      expect(today.second, 0);
      expect(today.millisecond, 0);
    });
  });

  group('TestClock', () {
    test('now() returns the set time', () {
      final fixedTime = DateTime(2024, 6, 15, 10, 30, 45);
      final clock = TestClock(fixedTime);

      expect(clock.now(), fixedTime);
    });

    test('advance() moves time forward', () {
      final initialTime = DateTime(2024, 6, 15, 10, 0, 0);
      final clock = TestClock(initialTime);

      clock.advance(const Duration(hours: 2));

      expect(clock.now(), DateTime(2024, 6, 15, 12, 0, 0));
    });

    test('advance() can move across days', () {
      final initialTime = DateTime(2024, 6, 15, 23, 0, 0);
      final clock = TestClock(initialTime);

      clock.advance(const Duration(hours: 2));

      expect(clock.now(), DateTime(2024, 6, 16, 1, 0, 0));
    });

    test('advance() can move across months', () {
      final initialTime = DateTime(2024, 6, 30, 12, 0, 0);
      final clock = TestClock(initialTime);

      clock.advance(const Duration(days: 2));

      expect(clock.now(), DateTime(2024, 7, 2, 12, 0, 0));
    });

    test('advance() with negative duration moves backward', () {
      final initialTime = DateTime(2024, 6, 15, 10, 0, 0);
      final clock = TestClock(initialTime);

      clock.advance(const Duration(days: -1));

      expect(clock.now(), DateTime(2024, 6, 14, 10, 0, 0));
    });

    test('setNow() changes the current time', () {
      final initialTime = DateTime(2024, 6, 15, 10, 0, 0);
      final clock = TestClock(initialTime);

      final newTime = DateTime(2025, 1, 1, 0, 0, 0);
      clock.setNow(newTime);

      expect(clock.now(), newTime);
    });

    test('setDate() sets time to midnight of specified date', () {
      final initialTime = DateTime(2024, 6, 15, 10, 30, 45);
      final clock = TestClock(initialTime);

      clock.setDate(2024, 12, 25);

      expect(clock.now(), DateTime(2024, 12, 25, 0, 0, 0));
    });

    test('today() returns midnight of test clock date', () {
      final fixedTime = DateTime(2024, 6, 15, 14, 30, 0);
      final clock = TestClock(fixedTime);

      final today = clock.today();

      expect(today, DateTime(2024, 6, 15, 0, 0, 0));
    });

    test('multiple advances accumulate correctly', () {
      final initialTime = DateTime(2024, 1, 1, 0, 0, 0);
      final clock = TestClock(initialTime);

      clock.advance(const Duration(days: 10));
      clock.advance(const Duration(hours: 5));
      clock.advance(const Duration(minutes: 30));

      expect(clock.now(), DateTime(2024, 1, 11, 5, 30, 0));
    });
  });

  group('Clock interface', () {
    test('SystemClock implements Clock', () {
      final Clock clock = SystemClock();
      expect(clock, isA<Clock>());
      expect(clock.now(), isA<DateTime>());
    });

    test('TestClock implements Clock', () {
      final Clock clock = TestClock(DateTime(2024, 1, 1));
      expect(clock, isA<Clock>());
      expect(clock.now(), isA<DateTime>());
    });
  });
}
