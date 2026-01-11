import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract clock interface for injectable time.
///
/// CRITICAL: Never use DateTime.now() directly in the codebase.
/// Always inject time via Clock to enable deterministic testing.
abstract class Clock {
  /// Returns the current date and time.
  DateTime now();

  /// Returns today's date at midnight (00:00:00).
  DateTime today() {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }
}

/// Production implementation that uses the system clock.
class SystemClock extends Clock {
  SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Test implementation that allows time manipulation.
///
/// Usage in tests:
/// ```dart
/// final testClock = TestClock(DateTime(2024, 1, 15, 10, 30));
/// // ... perform tests ...
/// testClock.advance(Duration(days: 1));
/// // now() returns DateTime(2024, 1, 16, 10, 30)
/// ```
class TestClock extends Clock {
  DateTime _now;

  TestClock(this._now);

  @override
  DateTime now() => _now;

  /// Advances the clock by the given duration.
  void advance(Duration duration) {
    _now = _now.add(duration);
  }

  /// Sets the clock to a specific date and time.
  void setNow(DateTime dateTime) {
    _now = dateTime;
  }

  /// Sets the clock to a specific date at midnight.
  void setDate(int year, int month, int day) {
    _now = DateTime(year, month, day);
  }
}

/// Riverpod provider for the clock service.
///
/// In production, this returns SystemClock.
/// For testing, override this provider with a TestClock instance.
///
/// Example override in tests:
/// ```dart
/// final container = ProviderContainer(
///   overrides: [
///     clockProvider.overrideWithValue(TestClock(DateTime(2024, 1, 15))),
///   ],
/// );
/// ```
final clockProvider = Provider<Clock>((ref) => SystemClock());
