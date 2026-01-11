import 'package:flutter_test/flutter_test.dart';
import 'package:accountapp/features/onboarding/domain/models/onboarding_state.dart';

void main() {
  group('OnboardingState', () {
    test('should have correct default values', () {
      const state = OnboardingState();

      expect(state.currentPage, equals(0));
      expect(state.budgetAmount, equals(0));
      expect(state.isCompleting, isFalse);
      expect(state.error, isNull);
    });

    test('totalPages should be 3', () {
      expect(OnboardingState.totalPages, equals(3));
    });

    group('isLastPage', () {
      test('should return false when on first page', () {
        const state = OnboardingState(currentPage: 0);
        expect(state.isLastPage, isFalse);
      });

      test('should return false when on second page', () {
        const state = OnboardingState(currentPage: 1);
        expect(state.isLastPage, isFalse);
      });

      test('should return true when on last page', () {
        const state = OnboardingState(currentPage: 2);
        expect(state.isLastPage, isTrue);
      });
    });

    group('isBudgetValid', () {
      test('should return false when budget is 0', () {
        const state = OnboardingState(budgetAmount: 0);
        expect(state.isBudgetValid, isFalse);
      });

      test('should return false when budget is negative', () {
        const state = OnboardingState(budgetAmount: -100);
        expect(state.isBudgetValid, isFalse);
      });

      test('should return true when budget is positive', () {
        const state = OnboardingState(budgetAmount: 350000);
        expect(state.isBudgetValid, isTrue);
      });

      test('should return true for small positive budget', () {
        const state = OnboardingState(budgetAmount: 1);
        expect(state.isBudgetValid, isTrue);
      });
    });

    group('canProceed', () {
      test('should return true on non-last page regardless of budget', () {
        const state = OnboardingState(currentPage: 0, budgetAmount: 0);
        expect(state.canProceed, isTrue);
      });

      test('should return false on last page with zero budget', () {
        const state = OnboardingState(currentPage: 2, budgetAmount: 0);
        expect(state.canProceed, isFalse);
      });

      test('should return true on last page with valid budget', () {
        const state = OnboardingState(currentPage: 2, budgetAmount: 350000);
        expect(state.canProceed, isTrue);
      });
    });

    group('hasError', () {
      test('should return false when error is null', () {
        const state = OnboardingState();
        expect(state.hasError, isFalse);
      });

      test('should return true when error is set', () {
        const state = OnboardingState(error: 'Montant requis');
        expect(state.hasError, isTrue);
      });
    });

    group('copyWith', () {
      test('should copy with new currentPage', () {
        const state = OnboardingState();
        final newState = state.copyWith(currentPage: 1);

        expect(newState.currentPage, equals(1));
        expect(newState.budgetAmount, equals(0));
        expect(newState.isCompleting, isFalse);
        expect(newState.error, isNull);
      });

      test('should copy with new budgetAmount', () {
        const state = OnboardingState();
        final newState = state.copyWith(budgetAmount: 350000);

        expect(newState.currentPage, equals(0));
        expect(newState.budgetAmount, equals(350000));
      });

      test('should copy with new isCompleting', () {
        const state = OnboardingState();
        final newState = state.copyWith(isCompleting: true);

        expect(newState.isCompleting, isTrue);
      });

      test('should copy with new error', () {
        const state = OnboardingState();
        final newState = state.copyWith(error: 'Test error');

        expect(newState.error, equals('Test error'));
      });

      test('should clear error when not provided', () {
        const state = OnboardingState(error: 'Old error');
        final newState = state.copyWith(budgetAmount: 100);

        // error parameter is nullable and defaults to null in copyWith
        expect(newState.error, isNull);
      });

      test('should preserve error when explicitly provided', () {
        const state = OnboardingState(error: 'Old error');
        final newState = state.copyWith(error: 'New error');

        expect(newState.error, equals('New error'));
      });
    });

    group('equality', () {
      test('two states with same values should be equal', () {
        const state1 = OnboardingState(
          currentPage: 1,
          budgetAmount: 350000,
          isCompleting: false,
          error: null,
        );
        const state2 = OnboardingState(
          currentPage: 1,
          budgetAmount: 350000,
          isCompleting: false,
          error: null,
        );

        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different values should not be equal', () {
        const state1 = OnboardingState(currentPage: 0);
        const state2 = OnboardingState(currentPage: 1);

        expect(state1, isNot(equals(state2)));
      });

      test('should handle identical check', () {
        const state = OnboardingState();
        expect(state == state, isTrue);
      });
    });
  });
}
