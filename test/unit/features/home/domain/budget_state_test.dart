import 'package:pockii/features/home/domain/models/budget_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BudgetState', () {
    group('percentageRemaining', () {
      test('returns correct percentage for normal budget', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 175000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, 0.5);
      });

      test('returns 0 when total budget is 0', () {
        final state = BudgetState(
          totalBudget: 0,
          remainingBudget: 0,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, 0);
      });

      test('returns 0 when total budget is negative', () {
        final state = BudgetState(
          totalBudget: -100000,
          remainingBudget: 50000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, 0);
      });

      test('returns negative percentage when overspent', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: -50000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, closeTo(-0.143, 0.001));
      });

      test('returns > 1.0 when overfunded', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 400000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, closeTo(1.143, 0.001));
      });
    });

    group('status', () {
      test('returns ok when > 30% remaining', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 120000, // 34.3%
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.ok);
      });

      test('returns warning when between 10% and 30%', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 70000, // 20%
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.warning);
      });

      test('returns danger when <= 10%', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 30000, // 8.6%
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.danger);
      });

      test('returns danger when budget is negative', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: -50000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.danger);
      });

      test('returns danger when exactly 10%', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 35000, // exactly 10%
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.danger);
      });

      test('returns warning when exactly 30%', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 105000, // exactly 30%
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.status, BudgetStatus.warning);
      });
    });

    group('isOverspent', () {
      test('returns true when remaining is negative', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: -10000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.isOverspent, true);
      });

      test('returns false when remaining is positive', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 100000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.isOverspent, false);
      });

      test('returns false when remaining is zero', () {
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 0,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.isOverspent, false);
      });
    });

    group('hasError', () {
      test('returns true when error is set', () {
        final state = BudgetState.withError('Test error');
        expect(state.hasError, true);
      });

      test('returns false when no error', () {
        final state = BudgetState.empty();
        expect(state.hasError, false);
      });
    });

    group('copyWith', () {
      test('creates copy with updated remaining budget', () {
        final original = BudgetState(
          totalBudget: 350000,
          remainingBudget: 200000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        final updated = original.copyWith(remainingBudget: 150000);

        expect(updated.totalBudget, 350000);
        expect(updated.remainingBudget, 150000);
        expect(updated.periodStart, original.periodStart);
      });

      test('preserves values when not overridden', () {
        final original = BudgetState(
          totalBudget: 350000,
          remainingBudget: 200000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
          isLoading: true,
        );

        final updated = original.copyWith(remainingBudget: 150000);

        expect(updated.isLoading, true);
      });
    });

    group('factory constructors', () {
      test('initial creates loading state', () {
        final state = BudgetState.initial();

        expect(state.isLoading, true);
        expect(state.totalBudget, 0);
        expect(state.remainingBudget, 0);
      });

      test('empty creates non-loading state', () {
        final state = BudgetState.empty();

        expect(state.isLoading, false);
        expect(state.totalBudget, 0);
        expect(state.remainingBudget, 0);
      });

      test('withError creates error state', () {
        final state = BudgetState.withError('Database error');

        expect(state.hasError, true);
        expect(state.error, 'Database error');
        expect(state.isLoading, false);
      });
    });

    group('equality', () {
      test('two states with same values are equal', () {
        final state1 = BudgetState(
          totalBudget: 350000,
          remainingBudget: 200000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        final state2 = BudgetState(
          totalBudget: 350000,
          remainingBudget: 200000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different values are not equal', () {
        final state1 = BudgetState(
          totalBudget: 350000,
          remainingBudget: 200000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        final state2 = BudgetState(
          totalBudget: 350000,
          remainingBudget: 150000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state1, isNot(equals(state2)));
      });
    });

    group('realistic FCFA scenarios', () {
      test('typical Ivorian salary scenario', () {
        // 350,000 FCFA budget, spent 135,000, remaining 215,000
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 215000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, closeTo(0.614, 0.001));
        expect(state.status, BudgetStatus.ok);
        expect(state.isOverspent, false);
      });

      test('end of month tight budget', () {
        // Only 25,000 FCFA remaining (7.1%)
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: 25000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.percentageRemaining, closeTo(0.071, 0.001));
        expect(state.status, BudgetStatus.danger);
      });

      test('overspent scenario', () {
        // Overspent by 15,000 FCFA
        final state = BudgetState(
          totalBudget: 350000,
          remainingBudget: -15000,
          periodStart: DateTime(2026, 1, 1),
          periodEnd: DateTime(2026, 1, 31),
        );

        expect(state.isOverspent, true);
        expect(state.status, BudgetStatus.danger);
      });
    });
  });
}
