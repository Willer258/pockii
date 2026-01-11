import 'package:accountapp/features/settings/presentation/dialogs/budget_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetEditDialog', () {
    group('initialization', () {
      testWidgets('displays current budget on load', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 350000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('350 000 FCFA'), findsOneWidget);
        expect(find.text('Modifier le budget'), findsOneWidget);
      });

      testWidgets('shows numeric keypad', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Check numeric keys are present
        for (var i = 0; i <= 9; i++) {
          expect(find.text(i.toString()), findsOneWidget);
        }

        // Check backspace button is present
        expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      });
    });

    group('digit input', () {
      testWidgets('first digit replaces current budget', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Tap digit 5 - should replace entire value
        await tester.tap(find.text('5'));
        await tester.pump();

        expect(find.text('5 FCFA'), findsOneWidget);
      });

      testWidgets('appends digits after first input', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Enter 350000
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('5'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();

        expect(find.text('350 000 FCFA'), findsOneWidget);
      });

      testWidgets('delete removes last digit', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 12345),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Delete last digit
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pump();

        expect(find.text('1 234 FCFA'), findsOneWidget);
      });
    });

    group('validation', () {
      testWidgets('confirm button is disabled when amount is 0', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Delete all digits to get to 0
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.backspace_outlined));
        await tester.pump();

        // Find the Enregistrer button
        final confirmButton = find.widgetWithText(FilledButton, 'Enregistrer');
        expect(confirmButton, findsOneWidget);

        // Check it's disabled
        final button = tester.widget<FilledButton>(confirmButton);
        expect(button.onPressed, isNull);
      });
    });

    group('dialog actions', () {
      testWidgets('cancel closes dialog without returning value', (tester) async {
        int? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await BudgetEditDialog.show(context, 100000);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Annuler'));
        await tester.pumpAndSettle();

        expect(result, isNull);
        expect(find.text('Modifier le budget'), findsNothing);
      });

      testWidgets('confirm returns new budget value', (tester) async {
        int? result;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await BudgetEditDialog.show(context, 100000);
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Enter new budget: 250000
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('5'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();
        await tester.tap(find.text('0'));
        await tester.pump();

        await tester.tap(find.text('Enregistrer'));
        await tester.pumpAndSettle();

        expect(result, 250000);
      });
    });

    group('info display', () {
      testWidgets('shows current budget when changed', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        // Change value
        await tester.tap(find.text('5'));
        await tester.pump();

        // Should show original budget reference
        expect(find.textContaining('Actuellement'), findsOneWidget);
        expect(find.text('Actuellement: 100 000 FCFA'), findsOneWidget);
      });

      testWidgets('shows info about mid-month changes', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BudgetEditDialog.show(context, 100000),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('sera appliqué au mois en cours'),
          findsOneWidget,
        );
      });
    });
  });
}
