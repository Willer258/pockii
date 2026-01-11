import 'dart:async';

import 'package:accountapp/core/services/pattern_analysis_service.dart';
import 'package:accountapp/features/patterns/presentation/widgets/income_expense_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createTestWidget({
    required IncomeExpenseOverview overview,
  }) {
    return ProviderScope(
      overrides: [
        incomeExpenseOverviewProvider.overrideWith(
          (ref) => Future.value(overview),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: IncomeExpenseOverviewCard(),
        ),
      ),
    );
  }

  group('IncomeExpenseOverviewCard', () {
    testWidgets('shows title and month name', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 150000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Revenus vs Depenses'), findsOneWidget);
      expect(find.text('Janvier'), findsOneWidget);
    });

    testWidgets('shows income and expense rows', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Revenus'), findsOneWidget);
      expect(find.text('Depenses'), findsOneWidget);
      expect(find.text('200K FCFA'), findsOneWidget);
      expect(find.text('80K FCFA'), findsOneWidget);
    });

    testWidgets('shows net balance label', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Solde net'), findsOneWidget);
    });

    testWidgets('shows positive balance with positive message', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('+120K'), findsOneWidget);
      expect(find.text('Tu es dans le positif ce mois!'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('shows negative balance with warning message', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 50000,
          totalExpenses: 100000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('-50K'), findsOneWidget);
      expect(find.text('Tu depenses plus que tu gagnes'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('shows no data state when no transactions', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 0,
          totalExpenses: 0,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pas de donnees ce mois'), findsOneWidget);
      expect(find.text('Ajoute des revenus ou depenses pour voir le bilan'),
          findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('shows wallet icon in header', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('shows income arrow down icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('shows expense arrow up icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 200000,
          totalExpenses: 80000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
    });

    testWidgets('formats large amounts with M suffix', (tester) async {
      await tester.pumpWidget(createTestWidget(
        overview: const IncomeExpenseOverview(
          totalIncome: 2500000,
          totalExpenses: 1500000,
          monthName: 'Janvier',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2.5M FCFA'), findsOneWidget);
      expect(find.text('1.5M FCFA'), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      final completer = Completer<IncomeExpenseOverview>();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          incomeExpenseOverviewProvider.overrideWith(
            (ref) => completer.future,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: IncomeExpenseOverviewCard(),
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete(const IncomeExpenseOverview(
        totalIncome: 100000,
        totalExpenses: 50000,
        monthName: 'Janvier',
      ));
      await tester.pumpAndSettle();
    });
  });
}
