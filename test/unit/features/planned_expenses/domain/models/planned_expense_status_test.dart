import 'package:pockii/features/planned_expenses/domain/models/planned_expense_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlannedExpenseStatus', () {
    group('toDbValue', () {
      test('pending returns "pending"', () {
        expect(PlannedExpenseStatus.pending.toDbValue(), 'pending');
      });

      test('converted returns "converted"', () {
        expect(PlannedExpenseStatus.converted.toDbValue(), 'converted');
      });

      test('cancelled returns "cancelled"', () {
        expect(PlannedExpenseStatus.cancelled.toDbValue(), 'cancelled');
      });
    });

    group('displayName', () {
      test('pending returns French display name', () {
        expect(PlannedExpenseStatus.pending.displayName, 'En attente');
      });

      test('converted returns French display name', () {
        expect(PlannedExpenseStatus.converted.displayName, 'Payé');
      });

      test('cancelled returns French display name', () {
        expect(PlannedExpenseStatus.cancelled.displayName, 'Annulé');
      });
    });
  });

  group('PlannedExpenseStatusParser', () {
    group('toPlannedExpenseStatus', () {
      test('parses "pending" correctly', () {
        expect('pending'.toPlannedExpenseStatus(), PlannedExpenseStatus.pending);
      });

      test('parses "converted" correctly', () {
        expect('converted'.toPlannedExpenseStatus(), PlannedExpenseStatus.converted);
      });

      test('parses "cancelled" correctly', () {
        expect('cancelled'.toPlannedExpenseStatus(), PlannedExpenseStatus.cancelled);
      });

      test('returns pending for unknown values', () {
        expect('unknown'.toPlannedExpenseStatus(), PlannedExpenseStatus.pending);
      });

      test('returns pending for empty string', () {
        expect(''.toPlannedExpenseStatus(), PlannedExpenseStatus.pending);
      });
    });
  });
}
