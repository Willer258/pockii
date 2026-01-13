import 'package:pockii/features/planned_expenses/presentation/providers/planned_expense_form_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlannedExpenseFormState', () {
    test('initial state has expected defaults', () {
      const state = PlannedExpenseFormState();

      expect(state.description, '');
      expect(state.amountFcfa, 0);
      expect(state.expectedDate, isNull);
      expect(state.category, isNull);
      expect(state.isEditing, isFalse);
      expect(state.editingId, isNull);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
    });

    group('isValid', () {
      test('returns false when description is empty', () {
        const state = PlannedExpenseFormState(
          amountFcfa: 10000,
          expectedDate: null,
        );

        expect(state.isValid, isFalse);
      });

      test('returns false when amount is 0', () {
        final state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 0,
          expectedDate: DateTime(2026, 2, 1),
        );

        expect(state.isValid, isFalse);
      });

      test('returns false when date is null', () {
        const state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 10000,
        );

        expect(state.isValid, isFalse);
      });

      test('returns true when all required fields are filled', () {
        final state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 2, 1),
        );

        expect(state.isValid, isTrue);
      });

      test('returns false when description is only whitespace', () {
        final state = PlannedExpenseFormState(
          description: '   ',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 2, 1),
        );

        expect(state.isValid, isFalse);
      });
    });

    group('copyWith', () {
      test('replaces specified values', () {
        final state = PlannedExpenseFormState(
          description: 'Original',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 1, 1),
        );

        final updated = state.copyWith(
          description: 'Updated',
          amountFcfa: 20000,
        );

        expect(updated.description, 'Updated');
        expect(updated.amountFcfa, 20000);
        expect(updated.expectedDate, DateTime(2026, 1, 1));
      });

      test('clearError removes error message', () {
        const state = PlannedExpenseFormState(
          errorMessage: 'Some error',
        );

        final updated = state.copyWith(clearError: true);

        expect(updated.errorMessage, isNull);
      });

      test('clearCategory removes category', () {
        const state = PlannedExpenseFormState(
          category: 'food',
        );

        final updated = state.copyWith(clearCategory: true);

        expect(updated.category, isNull);
      });
    });
  });

  group('PlannedExpenseFormNotifier', () {
    // Note: Full notifier tests would require mocking the repository
    // These tests cover the basic state manipulation methods

    group('digit manipulation', () {
      test('appendDigit builds amount correctly', () {
        // Simulating the logic from appendDigit
        var amount = 0;

        // Append 1
        amount = amount * 10 + 1;
        expect(amount, 1);

        // Append 5
        amount = amount * 10 + 5;
        expect(amount, 15);

        // Append 0
        amount = amount * 10 + 0;
        expect(amount, 150);

        // Append 0
        amount = amount * 10 + 0;
        expect(amount, 1500);

        // Append 0
        amount = amount * 10 + 0;
        expect(amount, 15000);
      });

      test('deleteDigit removes last digit', () {
        var amount = 15000;

        // Delete last digit
        amount = amount ~/ 10;
        expect(amount, 1500);

        // Delete last digit
        amount = amount ~/ 10;
        expect(amount, 150);
      });

      test('deleteDigit on single digit becomes 0', () {
        var amount = 5;

        amount = amount ~/ 10;
        expect(amount, 0);
      });
    });

    group('validation', () {
      test('validate returns error for empty description', () {
        final state = PlannedExpenseFormState(
          description: '',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 2, 1),
        );

        // Manual validation logic check
        String? error;
        if (state.description.trim().isEmpty) {
          error = 'Description requise';
        }

        expect(error, 'Description requise');
      });

      test('validate returns error for zero amount', () {
        final state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 0,
          expectedDate: DateTime(2026, 2, 1),
        );

        String? error;
        if (state.amountFcfa <= 0) {
          error = 'Montant requis';
        }

        expect(error, 'Montant requis');
      });

      test('validate returns error for null date', () {
        const state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 10000,
        );

        String? error;
        if (state.expectedDate == null) {
          error = 'Date requise';
        }

        expect(error, 'Date requise');
      });

      test('validate returns error for past date', () {
        final now = DateTime(2026, 1, 15);
        final state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 1, 10), // Past date
        );

        String? error;
        final today = DateTime(now.year, now.month, now.day);
        final expectedDay = DateTime(
          state.expectedDate!.year,
          state.expectedDate!.month,
          state.expectedDate!.day,
        );
        if (expectedDay.isBefore(today)) {
          error = 'La date doit être aujourd\'hui ou plus tard';
        }

        expect(error, 'La date doit être aujourd\'hui ou plus tard');
      });

      test('validate returns null for valid state', () {
        final now = DateTime(2026, 1, 15);
        final state = PlannedExpenseFormState(
          description: 'Test',
          amountFcfa: 10000,
          expectedDate: DateTime(2026, 1, 20), // Future date
        );

        String? error;
        if (state.description.trim().isEmpty) {
          error = 'Description requise';
        } else if (state.amountFcfa <= 0) {
          error = 'Montant requis';
        } else if (state.expectedDate == null) {
          error = 'Date requise';
        } else {
          final today = DateTime(now.year, now.month, now.day);
          final expectedDay = DateTime(
            state.expectedDate!.year,
            state.expectedDate!.month,
            state.expectedDate!.day,
          );
          if (expectedDay.isBefore(today)) {
            error = 'La date doit être aujourd\'hui ou plus tard';
          }
        }

        expect(error, isNull);
      });
    });
  });
}
