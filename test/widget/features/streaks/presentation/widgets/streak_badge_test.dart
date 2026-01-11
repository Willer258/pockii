import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/streaks_dao.dart';
import 'package:accountapp/core/database/database_provider.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/features/streaks/data/repositories/streak_repository.dart';
import 'package:accountapp/features/streaks/domain/services/streak_service.dart';
import 'package:accountapp/features/streaks/presentation/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TestClock testClock;
  late StreaksDao streaksDao;
  late StreakRepository streakRepository;
  late StreakService streakService;

  setUp(() {
    db = AppDatabase.inMemory();
    testClock = TestClock(DateTime(2026, 1, 15, 10));
    streaksDao = StreaksDao(db, clock: testClock);
    streakRepository = StreakRepository(
      streaksDao: streaksDao,
      clock: testClock,
    );
    streakService = StreakService(
      streakRepository: streakRepository,
      clock: testClock,
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(testClock),
        streaksDaoProvider.overrideWithValue(streaksDao),
        streakRepositoryProvider.overrideWithValue(streakRepository),
        streakServiceProvider.overrideWithValue(streakService),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Center(child: StreakBadge()),
        ),
      ),
    );
  }

  group('StreakBadge', () {
    testWidgets('displays 0 jour when no streak', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Use pump with duration instead of pumpAndSettle for animated widgets
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('0 jour'), findsOneWidget);
    });

    testWidgets('displays muted style when streak is 0', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should have info icon for zero streak
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('has tooltip when streak is 0', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find the Tooltip widget
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('displays 1 jour for single day streak', (tester) async {
      // Record activity to start streak
      await streakService.recordTransactionActivity();

      await tester.pumpWidget(buildTestWidget());
      // With active streak, there's a repeating animation, so use pump
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('1 jour'), findsOneWidget);
    });

    testWidgets('displays X jours for multi-day streak', (tester) async {
      // Build a 3-day streak
      await streakService.recordTransactionActivity();
      testClock.setNow(DateTime(2026, 1, 16, 10));
      await streakService.recordTransactionActivity();
      testClock.setNow(DateTime(2026, 1, 17, 10));
      await streakService.recordTransactionActivity();

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('3 jours'), findsOneWidget);
    });

    testWidgets('no info icon when streak is active', (tester) async {
      await streakService.recordTransactionActivity();

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.info_outline), findsNothing);
    });

    testWidgets('opens details dialog on tap', (tester) async {
      // Use 0 streak to avoid animation issues
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the badge
      await tester.tap(find.textContaining('0 jour'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Ta série'), findsOneWidget);
      expect(find.text('Série actuelle'), findsOneWidget);
      expect(find.text('Meilleure série'), findsOneWidget);
    });

    testWidgets('details dialog shows current and longest streak', (tester) async {
      // Build a streak and then lose it to have different current/longest
      await streakService.recordTransactionActivity();
      testClock.setNow(DateTime(2026, 1, 16, 10));
      await streakService.recordTransactionActivity();
      testClock.setNow(DateTime(2026, 1, 17, 10));
      await streakService.recordTransactionActivity();
      // Longest is now 3

      // Skip 2 days to lose streak, then don't log today (so streak is 0)
      testClock.setNow(DateTime(2026, 1, 20, 10));
      // Don't record activity - streak should be 0 but longest should be 3

      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Tap to open dialog (0 streak = no animation)
      await tester.tap(find.textContaining('0 jour'));
      await tester.pumpAndSettle();

      // Should show different values
      expect(find.text('0 jour'), findsOneWidget); // Current
      expect(find.text('3 jours'), findsOneWidget); // Longest
    });

    testWidgets('details dialog shows prompt to start when streak is 0',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.textContaining('0 jour'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Ajoute une transaction'),
        findsOneWidget,
      );
    });

    testWidgets('details dialog closes with Fermer button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.textContaining('0 jour'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();

      expect(find.text('Ta série'), findsNothing);
    });
  });
}
