import 'package:pockii/core/theme/app_colors.dart';
import 'package:pockii/features/history/presentation/widgets/transaction_tile.dart';
import 'package:pockii/features/transactions/domain/models/transaction_model.dart';
import 'package:pockii/features/transactions/domain/models/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionTile', () {
    Widget buildTestWidget(TransactionModel transaction) {
      return MaterialApp(
        home: Scaffold(
          body: TransactionTile(transaction: transaction),
        ),
      );
    }

    testWidgets('displays expense with negative amount prefix', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Verify amount shows with negative prefix (without FCFA suffix)
      expect(find.text('-5 000'), findsOneWidget);
    });

    testWidgets('displays income with positive amount prefix', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 50000,
        category: 'salary',
        type: TransactionType.income,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Verify amount shows with positive prefix
      expect(find.text('+50 000'), findsOneWidget);
    });

    testWidgets('displays income amount in success color', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 50000,
        category: 'salary',
        type: TransactionType.income,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Find the amount text widget
      final amountFinder = find.text('+50 000');
      expect(amountFinder, findsOneWidget);

      // Verify it has the success color
      final textWidget = tester.widget<Text>(amountFinder);
      expect(textWidget.style?.color, AppColors.success);
    });

    testWidgets('displays expense amount in default color', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Find the amount text widget
      final amountFinder = find.text('-5 000');
      expect(amountFinder, findsOneWidget);

      // Verify it has the default onSurface color
      final textWidget = tester.widget<Text>(amountFinder);
      expect(textWidget.style?.color, AppColors.onSurface);
    });

    testWidgets('displays category label when no note', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'transport',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should show category label
      expect(find.text('Transport'), findsOneWidget);
    });

    testWidgets('displays note instead of category when note exists',
        (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'transport',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
        note: 'Taxi aeroport',
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should show note instead of category
      expect(find.text('Taxi aeroport'), findsOneWidget);
      // Category label should not be shown as title
      expect(find.widgetWithText(ListTile, 'Transport'), findsNothing);
    });

    testWidgets('displays time in HH:mm format', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 9, 5), // 09:05
        createdAt: DateTime(2026, 1, 15, 9, 5),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should show time formatted with leading zeros
      expect(find.text('09:05'), findsOneWidget);
    });

    testWidgets('displays category icon in leading circle', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'transport',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should have the transport icon
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('displays income category icon correctly', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 50000,
        category: 'salary',
        type: TransactionType.income,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should have the salary/wallet icon
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('handles unknown category gracefully', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'unknown_category',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should fallback to "Autre" label
      expect(find.text('Autre'), findsOneWidget);
      // Should have the default "other" icon
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
    });

    testWidgets('shows Dismissible when onEdit is provided', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onEdit: () {},
            ),
          ),
        ),
      );

      // Should have Dismissible widget
      expect(find.byType(Dismissible), findsOneWidget);
    });

    testWidgets('does not show Dismissible when no callbacks', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(buildTestWidget(transaction));

      // Should not have Dismissible widget
      expect(find.byType(Dismissible), findsNothing);
    });

    testWidgets('triggers onEdit when swiped right', (tester) async {
      var editCalled = false;
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onEdit: () => editCalled = true,
            ),
          ),
        ),
      );

      // Swipe right to trigger edit (use fling for a complete swipe)
      await tester.fling(find.byType(Dismissible), const Offset(500, 0), 1000);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });

    testWidgets('shows blue edit background on right swipe', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onEdit: () {},
            ),
          ),
        ),
      );

      // Start swiping right
      await tester.drag(find.byType(ListTile), const Offset(100, 0));
      await tester.pump();

      // Should show edit icon
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('triggers onDelete when swiped left', (tester) async {
      var deleteCalled = false;
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onDelete: () => deleteCalled = true,
            ),
          ),
        ),
      );

      // Swipe left to trigger delete (use fling for a complete swipe)
      await tester.fling(find.byType(Dismissible), const Offset(-500, 0), 1000);
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('shows red delete background on left swipe', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Start swiping left
      await tester.drag(find.byType(ListTile), const Offset(-100, 0));
      await tester.pump();

      // Should show delete icon
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('shows Dismissible when onDelete is provided', (tester) async {
      final transaction = TransactionModel(
        id: 1,
        amountFcfa: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 14, 30),
        createdAt: DateTime(2026, 1, 15, 14, 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(
              transaction: transaction,
              onDelete: () {},
            ),
          ),
        ),
      );

      // Should have Dismissible widget
      expect(find.byType(Dismissible), findsOneWidget);
    });
  });
}
