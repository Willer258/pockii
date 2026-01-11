import 'dart:async';

import 'package:accountapp/core/services/pattern_analysis_service.dart';
import 'package:accountapp/features/patterns/presentation/widgets/top_categories_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopCategoriesCard', () {
    testWidgets('shows nothing when no categories', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not show any content
      expect(find.text('Top 0 Categories'), findsNothing);
      expect(find.byIcon(Icons.emoji_events), findsNothing);
    });

    testWidgets('shows single category when only one exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 1.0,
                  transactionCount: 10,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top 1 Categories'), findsOneWidget);
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      expect(find.text('50K FCFA'), findsOneWidget);
      expect(find.text('🥈'), findsNothing);
      expect(find.text('🥉'), findsNothing);
    });

    testWidgets('shows two categories when only two exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 0.7,
                  transactionCount: 10,
                ),
                const CategorySpending(
                  categoryId: 'transport',
                  categoryLabel: 'Transport',
                  categoryIcon: Icons.directions_car,
                  totalAmount: 20000,
                  percentage: 0.3,
                  transactionCount: 5,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top 2 Categories'), findsOneWidget);
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('🥉'), findsNothing);
    });

    testWidgets('shows all three medals for 3+ categories', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 0.5,
                  transactionCount: 10,
                ),
                const CategorySpending(
                  categoryId: 'transport',
                  categoryLabel: 'Transport',
                  categoryIcon: Icons.directions_car,
                  totalAmount: 30000,
                  percentage: 0.3,
                  transactionCount: 5,
                ),
                const CategorySpending(
                  categoryId: 'leisure',
                  categoryLabel: 'Loisirs',
                  categoryIcon: Icons.celebration,
                  totalAmount: 20000,
                  percentage: 0.2,
                  transactionCount: 3,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top 3 Categories'), findsOneWidget);
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('🥉'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Loisirs'), findsOneWidget);
    });

    testWidgets('limits to top 3 even with more categories', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 0.4,
                  transactionCount: 10,
                ),
                const CategorySpending(
                  categoryId: 'transport',
                  categoryLabel: 'Transport',
                  categoryIcon: Icons.directions_car,
                  totalAmount: 30000,
                  percentage: 0.24,
                  transactionCount: 5,
                ),
                const CategorySpending(
                  categoryId: 'leisure',
                  categoryLabel: 'Loisirs',
                  categoryIcon: Icons.celebration,
                  totalAmount: 25000,
                  percentage: 0.2,
                  transactionCount: 3,
                ),
                const CategorySpending(
                  categoryId: 'family',
                  categoryLabel: 'Famille',
                  categoryIcon: Icons.family_restroom,
                  totalAmount: 20000,
                  percentage: 0.16,
                  transactionCount: 2,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top 3 Categories'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Loisirs'), findsOneWidget);
      expect(find.text('Famille'), findsNothing); // 4th category not shown
    });

    testWidgets('formats large amounts correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 1500000, // 1.5M
                  percentage: 1.0,
                  transactionCount: 10,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1.5M FCFA'), findsOneWidget);
    });

    testWidgets('displays chevron icons for navigation hint', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 1.0,
                  transactionCount: 10,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show chevron indicating tappable
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('shows loading indicator while loading', (tester) async {
      // Use a completer to control when the future completes
      final completer = Completer<List<CategorySpending>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => completer.future,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      // While loading - just pump once without settling
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows category icons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            categoryBreakdownProvider.overrideWith(
              (ref) => Future.value([
                const CategorySpending(
                  categoryId: 'food',
                  categoryLabel: 'Repas',
                  categoryIcon: Icons.restaurant,
                  totalAmount: 50000,
                  percentage: 1.0,
                  transactionCount: 10,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: TopCategoriesCard()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget); // Header icon
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
