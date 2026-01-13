import 'package:pockii/core/router/app_router.dart';
import 'package:pockii/features/shell/presentation/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppBottomNav', () {
    Widget buildTestWidget({String initialLocation = '/'}) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          ShellRoute(
            builder: (context, state, child) => Scaffold(
              body: child,
              bottomNavigationBar: const AppBottomNav(),
            ),
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const Center(child: Text('Home')),
              ),
              GoRoute(
                path: '/history',
                builder: (_, __) => const Center(child: Text('History')),
              ),
              GoRoute(
                path: '/patterns',
                builder: (_, __) => const Center(child: Text('Patterns')),
              ),
              GoRoute(
                path: '/settings',
                builder: (_, __) => const Center(child: Text('Settings')),
              ),
            ],
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('displays all 4 navigation items', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
      expect(find.text('Patterns'), findsOneWidget);
      expect(find.text('Parametres'), findsOneWidget);
    });

    testWidgets('displays correct icons for each item', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Home is selected by default, so it has filled icon
      expect(find.byIcon(Icons.home), findsOneWidget);

      // Others have outlined icons
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('home tab is selected by default', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Home content should be visible
      expect(find.text('Home'), findsOneWidget);

      // NavigationBar should have index 0 selected
      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('navigates to history when history tab tapped', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on history tab
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      // History content should be visible
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('navigates to patterns when patterns tab tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on patterns tab (in navigation bar)
      await tester.tap(find.widgetWithText(NavigationDestination, 'Patterns'));
      await tester.pumpAndSettle();

      // Patterns content should be visible (in the body Center widget)
      expect(find.widgetWithText(Center, 'Patterns'), findsOneWidget);
    });

    testWidgets('navigates to settings when settings tab tapped',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap on settings tab
      await tester.tap(find.text('Parametres'));
      await tester.pumpAndSettle();

      // Settings content should be visible
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows filled icon for selected tab', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Initially home is selected - filled home icon
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsNothing);

      // Navigate to history
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();

      // Now history has filled icon, home has outlined
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsNothing);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);
    });

    testWidgets('can navigate back to home from other tabs', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Navigate to history
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text('History'), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.text('Accueil'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
