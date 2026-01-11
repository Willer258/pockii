import 'dart:async';

import 'package:accountapp/core/services/pattern_analysis_service.dart';
import 'package:accountapp/features/patterns/presentation/widgets/day_of_week_spending_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<DaySpending> createTestDays({int highestIndex = 5, int highestAmount = 100000}) {
    return List.generate(7, (i) {
      final index = i + 1;
      return DaySpending(
        dayIndex: index,
        dayName: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][i],
        dayShortName: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][i],
        totalAmount: index == highestIndex ? highestAmount : 20000,
        averageAmount: index == highestIndex ? 50000 : 10000,
        transactionCount: index == highestIndex ? 10 : 2,
        topCategory: 'food',
        topCategoryLabel: 'Repas',
      );
    });
  }

  List<DaySpending> createEmptyDays() {
    return List.generate(7, (i) => DaySpending(
      dayIndex: i + 1,
      dayName: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'][i],
      dayShortName: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'][i],
      totalAmount: 0,
      averageAmount: 0,
      transactionCount: 0,
      topCategory: null,
      topCategoryLabel: null,
    ));
  }

  Widget createTestWidget({
    required DayOfWeekDistribution distribution,
  }) {
    return ProviderScope(
      overrides: [
        dayOfWeekDistributionProvider.overrideWith(
          (ref) => Future.value(distribution),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DayOfWeekSpendingCard(),
          ),
        ),
      ),
    );
  }

  group('DayOfWeekSpendingCard', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Tu depenses 2x plus le vendredi',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Depenses par jour'), findsOneWidget);
    });

    testWidgets('shows calendar icon', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Tu depenses 2x plus le vendredi',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_view_week), findsOneWidget);
    });

    testWidgets('shows insight message', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Tu depenses 2x plus le vendredi',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Tu depenses 2x plus le vendredi'), findsOneWidget);
    });

    testWidgets('shows all day short names', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Test',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Lun'), findsOneWidget);
      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('Mer'), findsOneWidget);
      expect(find.text('Jeu'), findsOneWidget);
      expect(find.text('Ven'), findsOneWidget);
      expect(find.text('Sam'), findsOneWidget);
      expect(find.text('Dim'), findsOneWidget);
    });

    testWidgets('shows insights icon for pattern', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Tu depenses 2x plus le vendredi',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.insights), findsOneWidget);
    });

    testWidgets('shows balance icon for even distribution', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 1,
          insightMessage: 'Tes depenses sont bien reparties dans la semaine',
          isEvenlyDistributed: true,
          highestToAverageRatio: 1.2,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.balance), findsOneWidget);
    });

    testWidgets('shows day detail when tapping a bar', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Test',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on Friday (Ven)
      await tester.tap(find.text('Ven'));
      await tester.pumpAndSettle();

      // Should show day detail panel
      expect(find.text('Vendredi'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Moyenne'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('shows top category in detail panel', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Test',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on Friday (Ven)
      await tester.tap(find.text('Ven'));
      await tester.pumpAndSettle();

      expect(find.text('Top categorie: '), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
    });

    testWidgets('hides detail panel when tapping same day again', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createTestDays(),
          highestDayIndex: 5,
          insightMessage: 'Test',
          isEvenlyDistributed: false,
          highestToAverageRatio: 2.0,
        ),
      ));
      await tester.pumpAndSettle();

      // Tap on Friday (Ven)
      await tester.tap(find.text('Ven'));
      await tester.pumpAndSettle();

      expect(find.text('Vendredi'), findsOneWidget);

      // Tap again to hide
      await tester.tap(find.text('Ven'));
      await tester.pumpAndSettle();

      expect(find.text('Vendredi'), findsNothing);
    });

    testWidgets('shows no data state when no spending', (tester) async {
      await tester.pumpWidget(createTestWidget(
        distribution: DayOfWeekDistribution(
          days: createEmptyDays(),
          highestDayIndex: 0,
          insightMessage: 'Pas encore de donnees',
          isEvenlyDistributed: true,
          highestToAverageRatio: 0,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Pas encore de donnees'), findsOneWidget);
      expect(find.text('Ajoute des depenses pour voir la repartition par jour'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      final completer = Completer<DayOfWeekDistribution>();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          dayOfWeekDistributionProvider.overrideWith(
            (ref) => completer.future,
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DayOfWeekSpendingCard(),
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete(DayOfWeekDistribution(
        days: createTestDays(),
        highestDayIndex: 5,
        insightMessage: 'Test',
        isEvenlyDistributed: false,
        highestToAverageRatio: 2.0,
      ));
      await tester.pumpAndSettle();
    });
  });
}
