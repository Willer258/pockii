import 'package:pockii/features/planned_expenses/domain/models/planned_expense_model.dart';
import 'package:pockii/features/planned_expenses/domain/models/planned_expense_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlannedExpenseModel', () {
    final now = DateTime(2026, 1, 15);
    final testExpense = PlannedExpenseModel(
      id: 1,
      description: 'New Phone',
      amountFcfa: 150000,
      expectedDate: DateTime(2026, 1, 20),
      status: PlannedExpenseStatus.pending,
      createdAt: DateTime(2026, 1, 10),
    );

    group('daysUntilDue', () {
      test('returns positive days when due date is in the future', () {
        expect(testExpense.daysUntilDue(now), 5);
      });

      test('returns 0 when due date is today', () {
        final expense = testExpense.copyWith(expectedDate: now);
        expect(expense.daysUntilDue(now), 0);
      });

      test('returns negative days when due date is in the past', () {
        final expense = testExpense.copyWith(expectedDate: DateTime(2026, 1, 10));
        expect(expense.daysUntilDue(now), -5);
      });
    });

    group('isDueToday', () {
      test('returns true when due date is today', () {
        final expense = testExpense.copyWith(expectedDate: now);
        expect(expense.isDueToday(now), isTrue);
      });

      test('returns false when due date is not today', () {
        expect(testExpense.isDueToday(now), isFalse);
      });
    });

    group('isOverdue', () {
      test('returns true when pending and due date is in the past', () {
        final expense = testExpense.copyWith(
          expectedDate: DateTime(2026, 1, 10),
          status: PlannedExpenseStatus.pending,
        );
        expect(expense.isOverdue(now), isTrue);
      });

      test('returns false when converted', () {
        final expense = testExpense.copyWith(
          expectedDate: DateTime(2026, 1, 10),
          status: PlannedExpenseStatus.converted,
        );
        expect(expense.isOverdue(now), isFalse);
      });

      test('returns false when due date is in the future', () {
        expect(testExpense.isOverdue(now), isFalse);
      });
    });

    group('status helpers', () {
      test('isPending returns true when status is pending', () {
        expect(testExpense.isPending, isTrue);
      });

      test('isConverted returns true when status is converted', () {
        final expense = testExpense.copyWith(
          status: PlannedExpenseStatus.converted,
        );
        expect(expense.isConverted, isTrue);
      });

      test('isCancelled returns true when status is cancelled', () {
        final expense = testExpense.copyWith(
          status: PlannedExpenseStatus.cancelled,
        );
        expect(expense.isCancelled, isTrue);
      });
    });

    group('copyWith', () {
      test('creates a copy with replaced values', () {
        final updated = testExpense.copyWith(
          description: 'Updated description',
          amountFcfa: 200000,
        );

        expect(updated.description, 'Updated description');
        expect(updated.amountFcfa, 200000);
        expect(updated.id, testExpense.id);
        expect(updated.expectedDate, testExpense.expectedDate);
      });

      test('preserves original values when not specified', () {
        final copy = testExpense.copyWith();

        expect(copy.id, testExpense.id);
        expect(copy.description, testExpense.description);
        expect(copy.amountFcfa, testExpense.amountFcfa);
        expect(copy.expectedDate, testExpense.expectedDate);
        expect(copy.status, testExpense.status);
      });
    });

    group('equality', () {
      test('equal expenses are equal', () {
        final expense1 = testExpense;
        final expense2 = testExpense.copyWith();

        expect(expense1, equals(expense2));
      });

      test('different expenses are not equal', () {
        final expense1 = testExpense;
        final expense2 = testExpense.copyWith(amountFcfa: 100000);

        expect(expense1, isNot(equals(expense2)));
      });
    });
  });
}
