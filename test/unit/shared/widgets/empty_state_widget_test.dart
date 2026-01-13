import 'package:pockii/shared/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmptyStateWidget', () {
    group('base constructor', () {
      testWidgets('renders icon, title and subtitle', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.shopping_cart,
                title: 'Test Title',
                subtitle: 'Test subtitle message',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
        expect(find.text('Test Title'), findsOneWidget);
        expect(find.text('Test subtitle message'), findsOneWidget);
      });

      testWidgets('renders action button when provided', (tester) async {
        var buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                actionLabel: 'Action Button',
                onAction: () => buttonPressed = true,
              ),
            ),
          ),
        );

        expect(find.text('Action Button'), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);

        await tester.tap(find.text('Action Button'));
        expect(buttonPressed, true);
      });

      testWidgets('does not render action button when only label provided',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                actionLabel: 'Action Button',
                // onAction not provided
              ),
            ),
          ),
        );

        expect(find.text('Action Button'), findsNothing);
        expect(find.byType(FilledButton), findsNothing);
      });

      testWidgets('shows FAB pointer when showFabPointer is true',
          (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                showFabPointer: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
        expect(find.text('Appuie sur +'), findsOneWidget);
      });

      testWidgets('does not show FAB pointer by default', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
        expect(find.text('Appuie sur +'), findsNothing);
      });

      testWidgets('has semantic label for accessibility', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(EmptyStateWidget));
        expect(semantics.label, contains('Title'));
        expect(semantics.label, contains('Subtitle'));
      });
    });

    group('home factory', () {
      testWidgets('renders correct content for home screen', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.home(),
            ),
          ),
        );

        expect(
          find.text('Commence à tracker tes dépenses'),
          findsOneWidget,
        );
        expect(
          find.text('Ajoute ta première dépense pour voir ton budget évoluer'),
          findsOneWidget,
        );
        expect(
          find.byIcon(Icons.account_balance_wallet_outlined),
          findsOneWidget,
        );
        // FAB pointer should be shown
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      });

      testWidgets('shows action button when callback provided', (tester) async {
        var buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.home(
                onAction: () => buttonPressed = true,
              ),
            ),
          ),
        );

        expect(find.text('Ajouter une dépense'), findsOneWidget);
        await tester.tap(find.text('Ajouter une dépense'));
        expect(buttonPressed, true);
      });
    });

    group('history factory', () {
      testWidgets('renders correct content for history screen', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.history(),
            ),
          ),
        );

        expect(
          find.text('Aucune transaction ce mois'),
          findsOneWidget,
        );
        expect(
          find.text('Tes transactions apparaîtront ici'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
        // No FAB pointer for history
        expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
      });

      testWidgets('shows action button with callback', (tester) async {
        var buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.history(
                onAction: () => buttonPressed = true,
              ),
            ),
          ),
        );

        expect(find.text('Ajouter une dépense'), findsOneWidget);
        await tester.tap(find.text('Ajouter une dépense'));
        expect(buttonPressed, true);
      });
    });

    group('patternsLocked factory', () {
      testWidgets('renders correct content with days remaining', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.patternsLocked(daysRemaining: 15),
            ),
          ),
        );

        expect(
          find.text('Tes patterns arrivent bientôt'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Encore 15 jours de données pour débloquer cette fonctionnalité',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      });

      testWidgets('shows singular day when 1 day remaining', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.patternsLocked(daysRemaining: 1),
            ),
          ),
        );

        // French grammar: "1 jour" (singular), not "1 jours"
        expect(
          find.text(
            'Encore 1 jour de données pour débloquer cette fonctionnalité',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows plural days when multiple days remaining', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.patternsLocked(daysRemaining: 2),
            ),
          ),
        );

        // French grammar: "2 jours" (plural)
        expect(
          find.text(
            'Encore 2 jours de données pour débloquer cette fonctionnalité',
          ),
          findsOneWidget,
        );
      });
    });

    group('patternsNoData factory', () {
      testWidgets('renders correct content', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget.patternsNoData(),
            ),
          ),
        );

        expect(
          find.text('Pas encore de données'),
          findsOneWidget,
        );
        expect(
          find.text('Continue à tracker tes dépenses pour voir tes tendances'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.insights_outlined), findsOneWidget);
      });
    });

    group('FAB pointer animation', () {
      testWidgets('animates continuously', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                showFabPointer: true,
              ),
            ),
          ),
        );

        // Find the arrow icon's initial position
        final initialFinder = find.byIcon(Icons.arrow_downward_rounded);
        expect(initialFinder, findsOneWidget);

        // Advance animation by partial duration
        await tester.pump(const Duration(milliseconds: 750));

        // Widget should still exist after partial animation
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);

        // Complete the animation cycle
        await tester.pump(const Duration(milliseconds: 750));
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      });

      testWidgets('disposes animation controller without error', (tester) async {
        // Build widget with FAB pointer
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                showFabPointer: true,
              ),
            ),
          ),
        );

        // Start animation
        await tester.pump(const Duration(milliseconds: 500));

        // Remove widget from tree - should dispose without error
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );

        // If we reach here without exception, disposal was successful
        expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
      });
    });

    group('touch target size', () {
      testWidgets('action button meets minimum 48x48 touch target', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: EmptyStateWidget(
                icon: Icons.add,
                title: 'Title',
                subtitle: 'Subtitle',
                actionLabel: 'Action',
                onAction: () {},
              ),
            ),
          ),
        );

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        final style = button.style;

        // Verify minimum size is set to at least 48x48
        expect(style?.minimumSize?.resolve({}), const Size(48, 48));
      });
    });
  });
}
