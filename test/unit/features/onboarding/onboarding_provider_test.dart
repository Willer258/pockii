import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/app_settings_dao.dart';
import 'package:pockii/core/database/daos/budget_periods_dao.dart';
import 'package:pockii/core/database/database_provider.dart';
import 'package:pockii/core/services/clock_service.dart';
import 'package:pockii/features/onboarding/domain/models/onboarding_state.dart';
import 'package:pockii/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnboardingNotifier', () {
    late ProviderContainer container;
    late AppDatabase db;
    late TestClock testClock;

    setUp(() {
      db = AppDatabase.inMemory();
      testClock = TestClock(DateTime(2026, 1, 15, 10, 0, 0));

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => Future.value(db)),
          appSettingsDaoProvider
              .overrideWith((ref) => AppSettingsDao(db, clock: testClock)),
          budgetPeriodsDaoProvider.overrideWith((ref) => BudgetPeriodsDao(db)),
          clockProvider.overrideWithValue(testClock),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('should have initial state', () {
      final state = container.read(onboardingStateProvider);

      expect(state.currentPage, equals(0));
      expect(state.budgetAmount, equals(0));
      expect(state.isCompleting, isFalse);
      expect(state.error, isNull);
    });

    group('nextPage', () {
      test('should increment currentPage', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.nextPage();

        final state = container.read(onboardingStateProvider);
        expect(state.currentPage, equals(1));
      });

      test('should not go beyond last page', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.nextPage(); // 0 -> 1
        notifier.nextPage(); // 1 -> 2
        notifier.nextPage(); // should stay at 2

        final state = container.read(onboardingStateProvider);
        expect(state.currentPage, equals(2));
      });
    });

    group('previousPage', () {
      test('should decrement currentPage', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.nextPage(); // 0 -> 1
        notifier.previousPage(); // 1 -> 0

        final state = container.read(onboardingStateProvider);
        expect(state.currentPage, equals(0));
      });

      test('should not go below 0', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.previousPage(); // should stay at 0

        final state = container.read(onboardingStateProvider);
        expect(state.currentPage, equals(0));
      });
    });

    group('skipToSetup', () {
      test('should go to last page', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.skipToSetup();

        final state = container.read(onboardingStateProvider);
        expect(state.currentPage, equals(OnboardingState.totalPages - 1));
        expect(state.isLastPage, isTrue);
      });
    });

    group('setBudgetAmount', () {
      test('should update budget amount', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.setBudgetAmount(350000);

        final state = container.read(onboardingStateProvider);
        expect(state.budgetAmount, equals(350000));
        expect(state.isBudgetValid, isTrue);
      });

      test('should handle zero amount', () {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.setBudgetAmount(350000);
        notifier.setBudgetAmount(0);

        final state = container.read(onboardingStateProvider);
        expect(state.budgetAmount, equals(0));
        expect(state.isBudgetValid, isFalse);
      });
    });

    group('completeOnboarding', () {
      test('should fail if budget is invalid', () async {
        final notifier = container.read(onboardingStateProvider.notifier);

        final result = await notifier.completeOnboarding();

        expect(result, isFalse);
        final state = container.read(onboardingStateProvider);
        expect(state.error, equals('Montant requis'));
      });

      test('should succeed with valid budget', () async {
        final notifier = container.read(onboardingStateProvider.notifier);

        notifier.setBudgetAmount(350000);
        final result = await notifier.completeOnboarding();

        expect(result, isTrue);
        final state = container.read(onboardingStateProvider);
        expect(state.error, isNull);
        expect(state.isCompleting, isFalse);
      });

      test('should create budget period in database', () async {
        final notifier = container.read(onboardingStateProvider.notifier);
        final budgetDao = container.read(budgetPeriodsDaoProvider);

        notifier.setBudgetAmount(350000);
        await notifier.completeOnboarding();

        final periods = await budgetDao.getAllBudgetPeriods();
        expect(periods, hasLength(1));
        expect(periods.first.monthlyBudgetFcfa, equals(350000));
      });

      test('should set correct period dates', () async {
        final notifier = container.read(onboardingStateProvider.notifier);
        final budgetDao = container.read(budgetPeriodsDaoProvider);

        notifier.setBudgetAmount(350000);
        await notifier.completeOnboarding();

        final periods = await budgetDao.getAllBudgetPeriods();
        final period = periods.first;

        // Period should be January 2026 (based on testClock)
        expect(period.startDate, equals(DateTime(2026, 1, 1)));
        expect(period.endDate.year, equals(2026));
        expect(period.endDate.month, equals(1));
        expect(period.endDate.day, equals(31)); // January has 31 days
      });

      test('should mark onboarding as completed in settings', () async {
        final notifier = container.read(onboardingStateProvider.notifier);
        final settingsDao = container.read(appSettingsDaoProvider);

        notifier.setBudgetAmount(350000);
        await notifier.completeOnboarding();

        final completed = await settingsDao.getValue(kOnboardingCompletedKey);
        expect(completed, equals('true'));
      });
    });
  });

  group('onboardingCompletedProvider', () {
    late ProviderContainer container;
    late AppDatabase db;
    late TestClock testClock;

    setUp(() {
      db = AppDatabase.inMemory();
      testClock = TestClock(DateTime(2026, 1, 15));

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => Future.value(db)),
          appSettingsDaoProvider
              .overrideWith((ref) => AppSettingsDao(db, clock: testClock)),
          budgetPeriodsDaoProvider.overrideWith((ref) => BudgetPeriodsDao(db)),
          clockProvider.overrideWithValue(testClock),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('should return false when onboarding not completed', () async {
      final completed = await container.read(onboardingCompletedProvider.future);
      expect(completed, isFalse);
    });

    test('should return true when onboarding completed', () async {
      final settingsDao = container.read(appSettingsDaoProvider);
      await settingsDao.setValue(kOnboardingCompletedKey, 'true');

      // Create new container to get fresh read
      final container2 = ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => Future.value(db)),
          appSettingsDaoProvider
              .overrideWith((ref) => AppSettingsDao(db, clock: testClock)),
        ],
      );

      final completed =
          await container2.read(onboardingCompletedProvider.future);
      expect(completed, isTrue);

      container2.dispose();
    });
  });
}
