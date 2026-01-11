import 'package:drift/drift.dart';

import '../../services/clock_service.dart';
import '../app_database.dart';
import '../tables/user_streaks_table.dart';

part 'streaks_dao.g.dart';

/// Data Access Object for user streaks.
///
/// Provides CRUD operations for the user_streaks table.
/// The app maintains only one streak record per user.
@DriftAccessor(tables: [UserStreaks])
class StreaksDao extends DatabaseAccessor<AppDatabase> with _$StreaksDaoMixin {
  StreaksDao(super.db, {Clock? clock}) : _clock = clock ?? SystemClock();

  final Clock _clock;

  /// Gets the user's streak record, or null if none exists.
  Future<UserStreak?> getStreak() {
    return (select(userStreaks)..limit(1)).getSingleOrNull();
  }

  /// Watches the user's streak record for reactive updates.
  Stream<UserStreak?> watchStreak() {
    return (select(userStreaks)..limit(1)).watchSingleOrNull();
  }

  /// Creates the initial streak record.
  ///
  /// Returns the ID of the created record.
  Future<int> createStreak({
    int currentStreak = 0,
    int longestStreak = 0,
    DateTime? lastActivityDate,
  }) {
    return into(userStreaks).insert(
      UserStreaksCompanion.insert(
        currentStreak: Value(currentStreak),
        longestStreak: Value(longestStreak),
        lastActivityDate: Value(lastActivityDate),
      ),
    );
  }

  /// Ensures a streak record exists, creating one if necessary.
  ///
  /// Returns the existing or newly created streak record.
  Future<UserStreak> ensureStreakExists() async {
    var streak = await getStreak();
    if (streak == null) {
      await createStreak();
      streak = await getStreak();
    }
    return streak!;
  }

  /// Updates the streak with new values.
  ///
  /// Returns the number of updated rows.
  Future<int> updateStreak({
    required int currentStreak,
    required int longestStreak,
    required DateTime? lastActivityDate,
  }) async {
    final streak = await getStreak();
    if (streak == null) return 0;

    return (update(userStreaks)..where((t) => t.id.equals(streak.id))).write(
      UserStreaksCompanion(
        currentStreak: Value(currentStreak),
        longestStreak: Value(longestStreak),
        lastActivityDate: Value(lastActivityDate),
        updatedAt: Value(_clock.now()),
      ),
    );
  }

  /// Increments the current streak by 1 and updates last activity date.
  ///
  /// Also updates longest streak if current exceeds it.
  Future<UserStreak> incrementStreak() async {
    final streak = await ensureStreakExists();
    final newCurrent = streak.currentStreak + 1;
    final newLongest =
        newCurrent > streak.longestStreak ? newCurrent : streak.longestStreak;

    await updateStreak(
      currentStreak: newCurrent,
      longestStreak: newLongest,
      lastActivityDate: _clock.now(),
    );

    return (await getStreak())!;
  }

  /// Resets the current streak to 0.
  ///
  /// Keeps the longest streak unchanged.
  Future<UserStreak> resetStreak() async {
    final streak = await ensureStreakExists();

    await updateStreak(
      currentStreak: 0,
      longestStreak: streak.longestStreak,
      lastActivityDate: null,
    );

    return (await getStreak())!;
  }

  /// Sets the current streak to 1 (for starting a new streak after a gap).
  Future<UserStreak> startNewStreak() async {
    final streak = await ensureStreakExists();

    await updateStreak(
      currentStreak: 1,
      longestStreak: streak.longestStreak > 1 ? streak.longestStreak : 1,
      lastActivityDate: _clock.now(),
    );

    return (await getStreak())!;
  }

  /// Deletes the streak record.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteStreak() {
    return delete(userStreaks).go();
  }
}
