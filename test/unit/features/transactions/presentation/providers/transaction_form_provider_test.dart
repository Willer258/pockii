import 'package:pockii/features/transactions/presentation/providers/transaction_form_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionFormState', () {
    test('initial state has zero amount and no category', () {
      const state = TransactionFormState();

      expect(state.amountFcfa, 0);
      expect(state.category, isNull);
      expect(state.note, isNull);
      expect(state.isValid, isFalse);
    });

    test('isValid returns true when amount > 0', () {
      const state = TransactionFormState(amountFcfa: 1000);

      expect(state.isValid, isTrue);
    });

    test('isValid returns false when amount is 0', () {
      const state = TransactionFormState(amountFcfa: 0);

      expect(state.isValid, isFalse);
    });

    test('copyWith replaces values correctly', () {
      const original = TransactionFormState(
        amountFcfa: 1000,
        category: 'food',
        note: 'Lunch',
      );

      final updated = original.copyWith(
        amountFcfa: 2000,
        category: 'transport',
      );

      expect(updated.amountFcfa, 2000);
      expect(updated.category, 'transport');
      expect(updated.note, 'Lunch'); // Unchanged
    });

    test('copyWith with clearCategory sets category to null', () {
      const original = TransactionFormState(category: 'food');

      final updated = original.copyWith(clearCategory: true);

      expect(updated.category, isNull);
    });

    test('copyWith with clearNote sets note to null', () {
      const original = TransactionFormState(note: 'Test');

      final updated = original.copyWith(clearNote: true);

      expect(updated.note, isNull);
    });

    test('equality works correctly', () {
      const state1 = TransactionFormState(
        amountFcfa: 1000,
        category: 'food',
      );
      const state2 = TransactionFormState(
        amountFcfa: 1000,
        category: 'food',
      );
      const state3 = TransactionFormState(
        amountFcfa: 2000,
        category: 'food',
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('hasInteracted is false by default', () {
      const state = TransactionFormState();

      expect(state.hasInteracted, isFalse);
    });

    test('showAmountError is false when not interacted', () {
      const state = TransactionFormState(amountFcfa: 0);

      expect(state.showAmountError, isFalse);
    });

    test('showAmountError is true when interacted and amount is 0', () {
      const state = TransactionFormState(
        amountFcfa: 0,
        hasInteracted: true,
      );

      expect(state.showAmountError, isTrue);
    });

    test('showAmountError is false when interacted but amount > 0', () {
      const state = TransactionFormState(
        amountFcfa: 1000,
        hasInteracted: true,
      );

      expect(state.showAmountError, isFalse);
    });
  });

  group('TransactionFormNotifier', () {
    late TransactionFormNotifier notifier;

    setUp(() {
      notifier = TransactionFormNotifier();
    });

    test('initial state is empty', () {
      expect(notifier.state.amountFcfa, 0);
      expect(notifier.state.category, isNull);
      expect(notifier.state.note, isNull);
    });

    group('addDigit', () {
      test('adds single digit correctly', () {
        notifier.addDigit('5');

        expect(notifier.state.amountFcfa, 5);
      });

      test('adds multiple digits correctly', () {
        notifier.addDigit('1');
        notifier.addDigit('5');
        notifier.addDigit('0');
        notifier.addDigit('0');

        expect(notifier.state.amountFcfa, 1500);
      });

      test('ignores invalid input (non-digit)', () {
        notifier.addDigit('a');
        notifier.addDigit('');
        notifier.addDigit('12'); // Multi-character

        expect(notifier.state.amountFcfa, 0);
      });

      test('limits to 9 digits (999999999)', () {
        // Add 9 nines
        for (var i = 0; i < 9; i++) {
          notifier.addDigit('9');
        }

        expect(notifier.state.amountFcfa, 999999999);

        // Try to add one more
        notifier.addDigit('9');

        // Should still be 999999999
        expect(notifier.state.amountFcfa, 999999999);
      });

      test('builds realistic FCFA amounts', () {
        // Type 350000
        for (final digit in ['3', '5', '0', '0', '0', '0']) {
          notifier.addDigit(digit);
        }

        expect(notifier.state.amountFcfa, 350000);
      });
    });

    group('removeDigit', () {
      test('removes last digit', () {
        notifier.addDigit('1');
        notifier.addDigit('2');
        notifier.addDigit('3');

        notifier.removeDigit();

        expect(notifier.state.amountFcfa, 12);
      });

      test('does nothing when amount is 0', () {
        notifier.removeDigit();

        expect(notifier.state.amountFcfa, 0);
      });

      test('reduces to 0 after removing all digits', () {
        notifier.addDigit('5');

        notifier.removeDigit();

        expect(notifier.state.amountFcfa, 0);
      });
    });

    group('clearAmount', () {
      test('resets amount to 0', () {
        notifier.addDigit('1');
        notifier.addDigit('0');
        notifier.addDigit('0');

        notifier.clearAmount();

        expect(notifier.state.amountFcfa, 0);
      });
    });

    group('setCategory', () {
      test('sets category correctly', () {
        notifier.setCategory('food');

        expect(notifier.state.category, 'food');
      });

      test('replaces previous category', () {
        notifier.setCategory('food');
        notifier.setCategory('transport');

        expect(notifier.state.category, 'transport');
      });
    });

    group('clearCategory', () {
      test('clears category to null', () {
        notifier.setCategory('food');
        notifier.clearCategory();

        expect(notifier.state.category, isNull);
      });
    });

    group('setNote', () {
      test('sets note correctly', () {
        notifier.setNote('Lunch at office');

        expect(notifier.state.note, 'Lunch at office');
      });

      test('trims whitespace', () {
        notifier.setNote('  Test note  ');

        expect(notifier.state.note, 'Test note');
      });

      test('sets null for empty note', () {
        notifier.setNote('');

        expect(notifier.state.note, isNull);
      });

      test('sets null for whitespace-only note', () {
        notifier.setNote('   ');

        expect(notifier.state.note, isNull);
      });

      test('sets null for null input', () {
        notifier.setNote('Test');
        notifier.setNote(null);

        expect(notifier.state.note, isNull);
      });
    });

    group('clearNote', () {
      test('clears note to null', () {
        notifier.setNote('Test');
        notifier.clearNote();

        expect(notifier.state.note, isNull);
      });
    });

    group('reset', () {
      test('resets all state', () {
        notifier.addDigit('5');
        notifier.addDigit('0');
        notifier.addDigit('0');
        notifier.setCategory('food');
        notifier.setNote('Test');

        notifier.reset();

        expect(notifier.state.amountFcfa, 0);
        expect(notifier.state.category, isNull);
        expect(notifier.state.note, isNull);
        expect(notifier.state.isValid, isFalse);
      });
    });
  });
}
