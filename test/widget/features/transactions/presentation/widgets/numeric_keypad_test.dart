import 'package:pockii/features/transactions/presentation/widgets/numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumericKeypad', () {
    testWidgets('displays all 10 digits (0-9)', (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (digit) => pressedDigit = digit,
              onBackspacePressed: () {},
            ),
          ),
        ),
      );

      // Verify all digits 1-9 are displayed
      for (var i = 1; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
      // Verify 0 is displayed
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays backspace icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (_) {},
              onBackspacePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
    });

    testWidgets('calls onDigitPressed when digit is tapped', (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (digit) => pressedDigit = digit,
              onBackspacePressed: () {},
            ),
          ),
        ),
      );

      // Tap digit 5
      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedDigit, '5');
    });

    testWidgets('calls onDigitPressed for each digit', (tester) async {
      final pressedDigits = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (digit) => pressedDigits.add(digit),
              onBackspacePressed: () {},
            ),
          ),
        ),
      );

      // Tap each digit 1-9
      for (var i = 1; i <= 9; i++) {
        await tester.tap(find.text(i.toString()));
        await tester.pump();
      }

      // Tap 0
      await tester.tap(find.text('0'));
      await tester.pump();

      expect(pressedDigits, ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']);
    });

    testWidgets('calls onBackspacePressed when backspace is tapped',
        (tester) async {
      var backspaceCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (_) {},
              onBackspacePressed: () => backspaceCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(backspaceCalled, isTrue);
    });

    testWidgets('has accessible touch targets (48dp minimum)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumericKeypad(
              onDigitPressed: (_) {},
              onBackspacePressed: () {},
            ),
          ),
        ),
      );

      // Find all InkWell widgets (the touch targets)
      final inkWells = find.byType(InkWell);
      expect(inkWells, findsNWidgets(11)); // 10 digits + 1 backspace

      // Each should be at least 48dp in size
      for (final element in tester.widgetList<InkWell>(inkWells)) {
        // InkWell is inside a SizedBox that defines size
        final parentBox = tester
            .firstWidget<SizedBox>(find.ancestor(
              of: find.byWidget(element),
              matching: find.byType(SizedBox),
            ).first);
        expect(parentBox.width, greaterThanOrEqualTo(48.0));
        expect(parentBox.height, greaterThanOrEqualTo(48.0));
      }
    });
  });
}
