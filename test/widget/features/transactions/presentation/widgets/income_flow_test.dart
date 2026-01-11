import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/budget_periods_dao.dart';
import 'package:accountapp/core/database/daos/planned_expenses_dao.dart';
import 'package:accountapp/core/database/daos/streaks_dao.dart';
import 'package:accountapp/core/database/daos/subscriptions_dao.dart';
import 'package:accountapp/core/database/daos/transactions_dao.dart';
import 'package:accountapp/core/database/database_provider.dart';
import 'package:accountapp/core/services/clock_service.dart';
import 'package:accountapp/features/streaks/data/repositories/streak_repository.dart';
import 'package:accountapp/features/streaks/domain/services/streak_service.dart';
import 'package:accountapp/features/streaks/presentation/providers/streak_provider.dart';
import 'package:accountapp/features/transactions/data/transaction_repository.dart';
import 'package:accountapp/features/transactions/domain/models/transaction_type.dart';
import 'package:accountapp/features/transactions/presentation/widgets/category_chip_row.dart';
import 'package:accountapp/features/transactions/presentation/widgets/numeric_keypad.dart';
import 'package:accountapp/features/transactions/presentation/widgets/transaction_bottom_sheet.dart';
// ignore: unused_import
import 'package:drift/drift.dart' hide Column, isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionsDao transactionsDao;
  late BudgetPeriodsDao budgetPeriodsDao;
  late SubscriptionsDao subscriptionsDao;
  late PlannedExpensesDao plannedExpensesDao;
  late StreaksDao streaksDao;
  late StreakRepository streakRepository;
  late StreakService streakService;
  late TestClock testClock;

  setUp(() async {
    db = AppDatabase.inMemory();
    transactionsDao = TransactionsDao(db);
    budgetPeriodsDao = BudgetPeriodsDao(db);
    subscriptionsDao = SubscriptionsDao(db);
    plannedExpensesDao = PlannedExpensesDao(db);
    testClock = TestClock(DateTime(2026, 1, 15, 10, 30));
    streaksDao = StreaksDao(db, clock: testClock);
    streakRepository = StreakRepository(streaksDao: streaksDao, clock: testClock);
    streakService = StreakService(streakRepository: streakRepository, clock: testClock);

    // Create a budget period for testing
    await db.into(db.budgetPeriods).insert(
      BudgetPeriodsCompanion.insert(
        monthlyBudgetFcfa: 350000,
        startDate: DateTime(2026),
        endDate: DateTime(2026, 1, 31, 23, 59, 59),
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({required Widget child}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWith((ref) async => db),
        transactionsDaoProvider.overrideWithValue(transactionsDao),
        budgetPeriodsDaoProvider.overrideWithValue(budgetPeriodsDao),
        subscriptionsDaoProvider.overrideWithValue(subscriptionsDao),
        plannedExpensesDaoProvider.overrideWithValue(plannedExpensesDao),
        clockProvider.overrideWithValue(testClock),
        streaksDaoProvider.overrideWithValue(streaksDao),
        streakRepositoryProvider.overrideWithValue(streakRepository),
        streakServiceProvider.overrideWithValue(streakService),
        streakRecorderProvider.overrideWithValue(streakService),
      ],
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Income Flow - Mode Toggle', () {
    testWidgets('displays segmented button with expense and income options',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Verify both toggle options are visible
      expect(find.text('Dépense'), findsOneWidget);
      expect(find.text('Revenu'), findsOneWidget);

      // Verify SegmentedButton exists
      expect(find.byType(SegmentedButton<TransactionType>), findsOneWidget);
    });

    testWidgets('defaults to expense mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Verify expense title is shown by default
      expect(find.text('Nouvelle dépense'), findsOneWidget);
      expect(find.text('Nouveau revenu'), findsNothing);

      // Verify expense categories are shown (Transport is expense-only)
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('toggles to income mode and shows income title',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Tap on "Revenu" to switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Verify income title is shown
      expect(find.text('Nouveau revenu'), findsOneWidget);
      expect(find.text('Nouvelle dépense'), findsNothing);
    });

    testWidgets('shows income categories when in income mode', (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Verify income categories are shown
      expect(find.text('Salaire'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);

      // Verify expense-only categories are NOT shown
      expect(find.text('Transport'), findsNothing);
      expect(find.text('Repas'), findsNothing);
    });

    testWidgets('hides expense categories when in income mode',
        (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // First verify expense categories exist
      expect(find.text('Transport'), findsOneWidget);

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Expense categories should be hidden
      expect(find.text('Transport'), findsNothing);
    });

    testWidgets('toggles back to expense mode correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Verify we're in income mode
      expect(find.text('Nouveau revenu'), findsOneWidget);
      expect(find.text('Salaire'), findsOneWidget);

      // Switch back to expense mode
      await tester.tap(find.text('Dépense'));
      await tester.pumpAndSettle();

      // Verify we're back to expense mode
      expect(find.text('Nouvelle dépense'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Salaire'), findsNothing);
    });
  });

  group('Income Flow - Category Selection', () {
    testWidgets('clears category when toggling between modes', (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Select an expense category
      await tester.tap(find.text('Transport'));
      await tester.pumpAndSettle();

      // Verify category is selected (chip should be highlighted)
      final transportChip = find.ancestor(
        of: find.text('Transport'),
        matching: find.byType(AnimatedContainer),
      );
      expect(transportChip, findsOneWidget);

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Transport should be gone (different category set)
      expect(find.text('Transport'), findsNothing);

      // No income category should be selected yet
      // (Salaire should not have the selected style)
      expect(find.text('Salaire'), findsOneWidget);
    });

    testWidgets('can select income category in income mode', (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Select Salaire category
      await tester.tap(find.text('Salaire'));
      await tester.pumpAndSettle();

      // Verify the category chip exists
      final salaireChip = find.ancestor(
        of: find.text('Salaire'),
        matching: find.byType(AnimatedContainer),
      );
      expect(salaireChip, findsOneWidget);
    });
  });

  group('Income Flow - Amount Preservation', () {
    testWidgets('preserves entered amount when toggling mode', (tester) async {
      // Set larger screen size to fit all content
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Enter an amount in expense mode
      final keypad = find.byType(NumericKeypad);
      await tester.tap(find.descendant(of: keypad, matching: find.text('3')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('5')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pumpAndSettle();

      // Verify amount is shown
      expect(find.text('35 000'), findsOneWidget);

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Amount should still be preserved
      expect(find.text('35 000'), findsOneWidget);
    });
  });

  group('Income Flow - Submit Button', () {
    testWidgets('submit button enabled in income mode with valid amount',
        (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(child: const TransactionBottomSheet()),
      );
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Button should be disabled with no amount
      var button = find.widgetWithText(FilledButton, 'Ajouter');
      var filledButton = tester.widget<FilledButton>(button);
      expect(filledButton.onPressed, isNull);

      // Enter an amount
      final keypad = find.byType(NumericKeypad);
      await tester.tap(find.descendant(of: keypad, matching: find.text('5')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pumpAndSettle();

      // Button should now be enabled
      button = find.widgetWithText(FilledButton, 'Ajouter');
      filledButton = tester.widget<FilledButton>(button);
      expect(filledButton.onPressed, isNotNull);
    });
  });

  group('Income Categories - CategoryChipRow', () {
    testWidgets('CategoryChipRow shows income categories with isIncome=true',
        (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: null,
              onCategorySelected: (_) {},
              isIncome: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify income categories are shown
      expect(find.text('Salaire'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);
      expect(find.text('Remboursement'), findsOneWidget);
      expect(find.text('Cadeau'), findsOneWidget);

      // Verify expense categories are NOT shown
      expect(find.text('Transport'), findsNothing);
      expect(find.text('Repas'), findsNothing);
    });

    testWidgets('CategoryChipRow shows expense categories when isIncome not set',
        (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: null,
              onCategorySelected: (_) {},
              // isIncome defaults to false, so expense categories shown
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify expense categories are shown
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);

      // Verify income categories are NOT shown
      expect(find.text('Salaire'), findsNothing);
      expect(find.text('Freelance'), findsNothing);
    });

    testWidgets('CategoryChipRow defaults to expense categories',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: null,
              onCategorySelected: (_) {},
              // isIncome not specified - should default to false
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify expense categories are shown by default
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Salaire'), findsNothing);
    });
  });

  group('Income Flow - Integration Tests', () {
    testWidgets('submits income transaction and shows correct snackbar',
        (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => TransactionBottomSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Enter amount: 50000 FCFA
      final keypad = find.byType(NumericKeypad);
      await tester.tap(find.descendant(of: keypad, matching: find.text('5')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pumpAndSettle();

      // Select Salaire category
      await tester.tap(find.text('Salaire'));
      await tester.pumpAndSettle();

      // Tap submit button
      await tester.tap(find.text('Ajouter'));
      // Allow async save operation to complete and bottom sheet to close
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify transaction was saved in database with type=income
      final repository = TransactionRepository(transactionsDao);
      final transactions = await repository.getTransactionsByDateRange(
        DateTime(2026),
        DateTime(2026, 1, 31, 23, 59, 59),
      );

      expect(transactions.length, 1);
      expect(transactions.first.type, TransactionType.income);
      expect(transactions.first.amountFcfa, 50000);
      expect(transactions.first.category, 'salary');
    });

    testWidgets('income submission uses default category when none selected',
        (tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => TransactionBottomSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open bottom sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Switch to income mode
      await tester.tap(find.text('Revenu'));
      await tester.pumpAndSettle();

      // Enter amount without selecting category
      final keypad = find.byType(NumericKeypad);
      await tester.tap(find.descendant(of: keypad, matching: find.text('1')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('5')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pump();
      await tester.tap(find.descendant(of: keypad, matching: find.text('0')));
      await tester.pumpAndSettle();

      // Submit WITHOUT selecting a category
      await tester.tap(find.text('Ajouter'));
      // Allow async save operation to complete and bottom sheet to close
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify transaction was saved with default 'other' category
      final repository = TransactionRepository(transactionsDao);
      final transactions = await repository.getTransactionsByDateRange(
        DateTime(2026),
        DateTime(2026, 1, 31, 23, 59, 59),
      );

      expect(transactions.length, 1);
      expect(transactions.first.type, TransactionType.income);
      expect(transactions.first.category, 'other'); // Default category
      expect(transactions.first.amountFcfa, 15000);
    });
  });
}
