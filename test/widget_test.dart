// Basic smoke test for PockiiApp
//
// This test verifies that the app can be instantiated without errors.

import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/app_settings_dao.dart';
import 'package:pockii/core/database/daos/budget_periods_dao.dart';
import 'package:pockii/core/database/database_provider.dart';
import 'package:pockii/core/services/clock_service.dart';
import 'package:pockii/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PockiiApp smoke test', (WidgetTester tester) async {
    // Create in-memory database for testing
    final db = AppDatabase.inMemory();
    final testClock = TestClock(DateTime(2026, 1, 15));

    // Build our app with mocked providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => Future.value(db)),
          appSettingsDaoProvider
              .overrideWith((ref) => AppSettingsDao(db, clock: testClock)),
          budgetPeriodsDaoProvider.overrideWith((ref) => BudgetPeriodsDao(db)),
          clockProvider.overrideWithValue(testClock),
        ],
        child: const PockiiApp(),
      ),
    );

    // Wait for async initialization
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // App should have rendered something
    expect(find.byType(PockiiApp), findsOneWidget);

    // Clean up
    await db.close();
  });
}
