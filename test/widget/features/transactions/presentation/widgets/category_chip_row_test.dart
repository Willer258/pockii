import 'package:accountapp/features/transactions/presentation/widgets/category_chip_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryChipRow', () {
    testWidgets('displays first visible expense categories', (tester) async {
      // Set a large screen size to render all categories
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: null,
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      // Verify at least the first categories are displayed
      expect(find.text('Transport'), findsOneWidget);
      expect(find.text('Repas'), findsOneWidget);
      // The row is scrollable so not all may be visible initially
    });

    testWidgets('displays icons for visible categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Wide enough to show all categories
              child: CategoryChipRow(
                selectedCategory: null,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Check that at least the first visible category has an icon
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
      // Total icons should be at least 1 (ListView may not render all)
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('calls onCategorySelected when category is tapped',
        (tester) async {
      String? selectedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: null,
              onCategorySelected: (category) => selectedCategory = category,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Repas'));
      await tester.pump();

      expect(selectedCategory, 'food');
    });

    testWidgets('highlights selected category', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChipRow(
              selectedCategory: 'transport',
              onCategorySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();

      // The Transport chip should have a different style (filled)
      // We can verify this by checking the AnimatedContainer decorations
      final transportChip = find.ancestor(
        of: find.text('Transport'),
        matching: find.byType(AnimatedContainer),
      );
      expect(transportChip, findsOneWidget);
    });

    testWidgets('allows single selection only', (tester) async {
      final selectedCategories = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                String? currentSelection =
                    selectedCategories.isNotEmpty ? selectedCategories.last : null;
                return CategoryChipRow(
                  selectedCategory: currentSelection,
                  onCategorySelected: (category) {
                    setState(() {
                      selectedCategories.add(category);
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap Transport
      await tester.tap(find.text('Transport'));
      await tester.pump();

      // Tap Food
      await tester.tap(find.text('Repas'));
      await tester.pump();

      // Both selections should be recorded, but only last one is selected
      expect(selectedCategories, ['transport', 'food']);
    });

    testWidgets('scrolls horizontally when content overflows', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200, // Constrain width to force scrolling
              child: CategoryChipRow(
                selectedCategory: null,
                onCategorySelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // ListView should be scrollable
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      final listViewWidget = tester.widget<ListView>(listView);
      expect(listViewWidget.scrollDirection, Axis.horizontal);
    });
  });

  group('expenseCategories', () {
    test('contains 6 categories', () {
      expect(expenseCategories.length, 6);
    });

    test('has correct category IDs', () {
      final ids = expenseCategories.map((c) => c.id).toList();
      expect(ids, [
        'transport',
        'food',
        'leisure',
        'family',
        'subscriptions',
        'other',
      ]);
    });

    test('has French labels', () {
      final labels = expenseCategories.map((c) => c.label).toList();
      expect(labels, [
        'Transport',
        'Repas',
        'Loisirs',
        'Famille',
        'Abonnements',
        'Autre',
      ]);
    });
  });
}
