import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/theme/budget_colors.dart';
import 'package:pockii/features/budget/domain/services/budget_calculation_service.dart';
import 'package:pockii/features/home/domain/models/budget_state.dart';
import 'package:pockii/features/home/presentation/providers/budget_provider.dart';
import 'package:pockii/features/home/presentation/widgets/budget_hero_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A fake calculation service for testing that returns a fixed result.
class _FakeBudgetCalculationService implements BudgetCalculationService {
  _FakeBudgetCalculationService({required this.result});

  final BudgetCalculationResult result;
  bool throwError = false;
  String? errorMessage;

  @override
  Future<BudgetCalculationResult> calculateRemainingBudget() async {
    if (throwError) {
      throw Exception(errorMessage ?? 'Test error');
    }
    return result;
  }

  @override
  Future<BudgetPeriod?> getCurrentPeriod() async => null;

  @override
  bool hasMonthChanged(DateTime lastKnownDate) => false;

  @override
  void resetTimeInconsistencyDetection() {
    // No-op for tests
  }
}

void main() {
  group('BudgetHeroCard Widget', () {
    Widget createTestWidget({
      required BudgetState budgetState,
      String monthLabel = 'Janvier 2026',
    }) {
      // Create a fake service that returns a result matching the budgetState
      final fakeService = _FakeBudgetCalculationService(
        result: BudgetCalculationResult(
          totalBudget: budgetState.totalBudget,
          totalExpenses: budgetState.totalBudget - budgetState.remainingBudget,
          totalSubscriptions: 0,
          totalPlannedExpenses: 0,
          remainingBudget: budgetState.remainingBudget,
          periodStart: budgetState.periodStart,
          periodEnd: budgetState.periodEnd,
          hasTimeInconsistency: budgetState.hasTimeInconsistency,
        ),
      );

      // For error states, configure the fake to throw
      if (budgetState.hasError) {
        fakeService
          ..throwError = true
          ..errorMessage = budgetState.error;
      }

      return ProviderScope(
        overrides: [
          budgetCalculationServiceProvider.overrideWithValue(fakeService),
          currentMonthLabelProvider.overrideWithValue(monthLabel),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: BudgetHeroCard(),
          ),
        ),
      );
    }

    group('displays formatted budget amount', () {
      testWidgets('shows positive amount correctly formatted', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 215000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        // Wait for async load
        await tester.pumpAndSettle();

        // Should show formatted amount with space separators
        expect(find.text('215 000'), findsOneWidget);
        expect(find.text('FCFA'), findsOneWidget);
      });

      testWidgets('shows zero amount', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 0,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('shows correct color for status', () {
      testWidgets('shows green for OK status (>30%)', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000, // 57% - OK
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the hero text - the one that displays the amount
        final heroText = find.text('200 000');
        expect(heroText, findsOneWidget);

        // Get the closest parent AnimatedDefaultTextStyle
        final animatedText = tester.widget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: heroText,
            matching: find.byType(AnimatedDefaultTextStyle),
          ).first,
        );

        expect(animatedText.style.color, BudgetColors.ok);
      });

      testWidgets('shows orange for warning status (10-30%)', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 70000, // 20% - Warning
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final heroText = find.text('70 000');
        expect(heroText, findsOneWidget);

        final animatedText = tester.widget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: heroText,
            matching: find.byType(AnimatedDefaultTextStyle),
          ).first,
        );

        expect(animatedText.style.color, BudgetColors.warning);
      });

      testWidgets('shows red for danger status (<10%)', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 25000, // 7% - Danger
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final heroText = find.text('25 000');
        expect(heroText, findsOneWidget);

        final animatedText = tester.widget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: heroText,
            matching: find.byType(AnimatedDefaultTextStyle),
          ).first,
        );

        expect(animatedText.style.color, BudgetColors.danger);
      });
    });

    group('negative budget display', () {
      testWidgets('shows negative prefix when overspent', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: -15000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Should show negative with dash prefix
        expect(find.text('-15 000'), findsOneWidget);
      });

      testWidgets('shows red color when overspent', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: -15000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final heroText = find.text('-15 000');
        expect(heroText, findsOneWidget);

        final animatedText = tester.widget<AnimatedDefaultTextStyle>(
          find.ancestor(
            of: heroText,
            matching: find.byType(AnimatedDefaultTextStyle),
          ).first,
        );

        expect(animatedText.style.color, BudgetColors.danger);
      });
    });

    group('month label display', () {
      testWidgets('displays current month label', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
            monthLabel: 'Janvier 2026',
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Janvier 2026'), findsOneWidget);
      });

      testWidgets('displays different month correctly', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000,
              periodStart: DateTime(2026, 12),
              periodEnd: DateTime(2026, 12, 31),
            ),
            monthLabel: 'Décembre 2026',
          ),
        );

        await tester.pumpAndSettle();
        expect(find.text('Décembre 2026'), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('has accessibility semantics', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Semantics widget that contains our accessibility label
        final semanticsFinder = find.byWidgetPredicate((widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Reste à vivre'));

        expect(semanticsFinder, findsOneWidget);

        final semantics = tester.widget<Semantics>(semanticsFinder);
        expect(semantics.properties.label, contains('francs CFA'));
      });

      testWidgets('accessibility label includes budget status', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 25000, // Danger status
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Find the Semantics widget with budget info
        final semanticsFinder = find.byWidgetPredicate((widget) =>
            widget is Semantics &&
            widget.properties.label != null &&
            widget.properties.label!.contains('Reste à vivre'));

        expect(semanticsFinder, findsOneWidget);
      });
    });

    group('progress bar', () {
      testWidgets('shows progress indicator', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 175000, // 50%
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('progress bar value matches percentage', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 175000, // 50%
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final progressBar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        expect(progressBar.value, closeTo(0.5, 0.01));
      });

      testWidgets('progress bar clamped at 0 for negative budget',
          (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: -50000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final progressBar = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        );

        expect(progressBar.value, 0.0);
      });
    });

    group('loading state', () {
      testWidgets('shows loading indicator initially', (tester) async {
        // Create widget and pump once without settle to catch loading state
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000,
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        // First frame shows loading state before async completes
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Chargement...'), findsOneWidget);
      });
    });

    group('error state', () {
      testWidgets('shows error message when error occurs', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState.withError('Database error'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Erreur de chargement'), findsOneWidget);
        // Exception.toString() formats as "Exception: message"
        expect(find.textContaining('Database error'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('budget summary row', () {
      testWidgets('shows spent and total budget', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            budgetState: BudgetState(
              totalBudget: 350000,
              remainingBudget: 200000, // Spent: 150000
              periodStart: DateTime(2026),
              periodEnd: DateTime(2026, 1, 31),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('150 000 FCFA'), findsOneWidget);
        expect(find.textContaining('350 000 FCFA'), findsOneWidget);
      });
    });
  });
}
