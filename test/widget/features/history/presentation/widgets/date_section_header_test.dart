import 'package:accountapp/core/theme/app_colors.dart';
import 'package:accountapp/features/history/presentation/widgets/date_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateSectionHeader', () {
    Widget buildTestWidget(String label) {
      return MaterialApp(
        home: Scaffold(
          body: DateSectionHeader(label: label),
        ),
      );
    }

    testWidgets('displays the label text', (tester) async {
      await tester.pumpWidget(buildTestWidget("Aujourd'hui"));

      expect(find.text("Aujourd'hui"), findsOneWidget);
    });

    testWidgets('displays Hier label correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget('Hier'));

      expect(find.text('Hier'), findsOneWidget);
    });

    testWidgets('displays date format label correctly', (tester) async {
      await tester.pumpWidget(buildTestWidget('10/01/2026'));

      expect(find.text('10/01/2026'), findsOneWidget);
    });

    testWidgets('has correct background color', (tester) async {
      await tester.pumpWidget(buildTestWidget("Aujourd'hui"));

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text("Aujourd'hui"),
          matching: find.byType(Container),
        ),
      );

      expect((container.decoration as BoxDecoration?)?.color, isNull);
      // The container uses color property directly, not decoration
      expect(container.color, AppColors.surfaceVariant);
    });

    testWidgets('takes full width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: DateSectionHeader(label: "Aujourd'hui"),
            ),
          ),
        ),
      );

      // Find the DateSectionHeader widget and check it renders correctly
      final headerFinder = find.byType(DateSectionHeader);
      expect(headerFinder, findsOneWidget);

      // Get the rendered size - it should fill the parent width
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(DateSectionHeader),
      );
      expect(renderBox.size.width, 400);
    });
  });
}
