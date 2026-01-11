import 'package:accountapp/features/subscriptions/domain/models/subscription_frequency.dart';
import 'package:accountapp/features/subscriptions/domain/models/subscription_model.dart';
import 'package:accountapp/features/subscriptions/presentation/providers/subscription_form_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionFormState', () {
    test('initial state has default values', () {
      const state = SubscriptionFormState();

      expect(state.name, '');
      expect(state.amountFcfa, 0);
      expect(state.category, isNull);
      expect(state.frequency, SubscriptionFrequency.monthly);
      expect(state.dueDay, 1);
      expect(state.isActive, isTrue);
      expect(state.hasInteracted, isFalse);
      expect(state.editingId, isNull);
    });

    test('isEditing returns false when editingId is null', () {
      const state = SubscriptionFormState();

      expect(state.isEditing, isFalse);
    });

    test('isEditing returns true when editingId is set', () {
      const state = SubscriptionFormState(editingId: 1);

      expect(state.isEditing, isTrue);
    });

    test('isValid returns true when name and amount are valid', () {
      const state = SubscriptionFormState(
        name: 'Netflix',
        amountFcfa: 5000,
      );

      expect(state.isValid, isTrue);
    });

    test('isValid returns false when name is empty', () {
      const state = SubscriptionFormState(
        name: '',
        amountFcfa: 5000,
      );

      expect(state.isValid, isFalse);
    });

    test('isValid returns false when name is whitespace only', () {
      const state = SubscriptionFormState(
        name: '   ',
        amountFcfa: 5000,
      );

      expect(state.isValid, isFalse);
    });

    test('isValid returns false when amount is 0', () {
      const state = SubscriptionFormState(
        name: 'Netflix',
        amountFcfa: 0,
      );

      expect(state.isValid, isFalse);
    });

    test('showNameError is false when not interacted', () {
      const state = SubscriptionFormState(name: '');

      expect(state.showNameError, isFalse);
    });

    test('showNameError is true when interacted and name is empty', () {
      const state = SubscriptionFormState(
        name: '',
        hasInteracted: true,
      );

      expect(state.showNameError, isTrue);
    });

    test('showAmountError is false when not interacted', () {
      const state = SubscriptionFormState(amountFcfa: 0);

      expect(state.showAmountError, isFalse);
    });

    test('showAmountError is true when interacted and amount is 0', () {
      const state = SubscriptionFormState(
        amountFcfa: 0,
        hasInteracted: true,
      );

      expect(state.showAmountError, isTrue);
    });

    test('maxDueDay returns 7 for weekly frequency', () {
      const state = SubscriptionFormState(
        frequency: SubscriptionFrequency.weekly,
      );

      expect(state.maxDueDay, 7);
    });

    test('maxDueDay returns 31 for monthly frequency', () {
      const state = SubscriptionFormState(
        frequency: SubscriptionFrequency.monthly,
      );

      expect(state.maxDueDay, 31);
    });

    test('maxDueDay returns 31 for yearly frequency', () {
      const state = SubscriptionFormState(
        frequency: SubscriptionFrequency.yearly,
      );

      expect(state.maxDueDay, 31);
    });

    test('copyWith replaces values correctly', () {
      const original = SubscriptionFormState(
        name: 'Original',
        amountFcfa: 1000,
      );

      final updated = original.copyWith(
        name: 'Updated',
        amountFcfa: 2000,
      );

      expect(updated.name, 'Updated');
      expect(updated.amountFcfa, 2000);
    });

    test('copyWith with clearCategory sets category to null', () {
      const original = SubscriptionFormState(category: 'entertainment');

      final updated = original.copyWith(clearCategory: true);

      expect(updated.category, isNull);
    });

    test('equality works correctly', () {
      const state1 = SubscriptionFormState(
        name: 'Test',
        amountFcfa: 1000,
      );
      const state2 = SubscriptionFormState(
        name: 'Test',
        amountFcfa: 1000,
      );
      const state3 = SubscriptionFormState(
        name: 'Different',
        amountFcfa: 1000,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('SubscriptionFormNotifier', () {
    late SubscriptionFormNotifier notifier;

    setUp(() {
      notifier = SubscriptionFormNotifier();
    });

    test('initial state is empty', () {
      expect(notifier.state.name, '');
      expect(notifier.state.amountFcfa, 0);
      expect(notifier.state.category, isNull);
    });

    group('setName', () {
      test('sets name correctly', () {
        notifier.setName('Netflix');

        expect(notifier.state.name, 'Netflix');
      });

      test('marks form as interacted', () {
        notifier.setName('Test');

        expect(notifier.state.hasInteracted, isTrue);
      });
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

        expect(notifier.state.amountFcfa, 0);
      });

      test('limits to 9 digits', () {
        for (var i = 0; i < 9; i++) {
          notifier.addDigit('9');
        }
        expect(notifier.state.amountFcfa, 999999999);

        notifier.addDigit('9');
        expect(notifier.state.amountFcfa, 999999999);
      });

      test('marks form as interacted', () {
        notifier.addDigit('5');

        expect(notifier.state.hasInteracted, isTrue);
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
    });

    group('clearAmount', () {
      test('resets amount to 0', () {
        notifier.addDigit('5');
        notifier.addDigit('0');

        notifier.clearAmount();

        expect(notifier.state.amountFcfa, 0);
      });
    });

    group('setAmount', () {
      test('sets amount directly', () {
        notifier.setAmount(12345);

        expect(notifier.state.amountFcfa, 12345);
      });
    });

    group('setCategory', () {
      test('sets category correctly', () {
        notifier.setCategory('entertainment');

        expect(notifier.state.category, 'entertainment');
      });
    });

    group('clearCategory', () {
      test('clears category to null', () {
        notifier.setCategory('entertainment');
        notifier.clearCategory();

        expect(notifier.state.category, isNull);
      });
    });

    group('setFrequency', () {
      test('sets frequency correctly', () {
        notifier.setFrequency(SubscriptionFrequency.weekly);

        expect(notifier.state.frequency, SubscriptionFrequency.weekly);
      });

      test('adjusts dueDay when switching to weekly', () {
        notifier.setDueDay(15);
        notifier.setFrequency(SubscriptionFrequency.weekly);

        expect(notifier.state.dueDay, 7);
      });

      test('preserves dueDay when within valid range', () {
        notifier.setDueDay(5);
        notifier.setFrequency(SubscriptionFrequency.weekly);

        expect(notifier.state.dueDay, 5);
      });
    });

    group('setDueDay', () {
      test('sets due day correctly', () {
        notifier.setDueDay(15);

        expect(notifier.state.dueDay, 15);
      });

      test('clamps due day to valid range', () {
        notifier.setDueDay(35);

        expect(notifier.state.dueDay, 31);
      });

      test('clamps due day to minimum 1', () {
        notifier.setDueDay(0);

        expect(notifier.state.dueDay, 1);
      });
    });

    group('setIsActive', () {
      test('sets isActive correctly', () {
        notifier.setIsActive(false);

        expect(notifier.state.isActive, isFalse);
      });
    });

    group('markInteracted', () {
      test('marks form as interacted', () {
        notifier.markInteracted();

        expect(notifier.state.hasInteracted, isTrue);
      });
    });

    group('reset', () {
      test('resets all state', () {
        notifier.setName('Test');
        notifier.addDigit('5');
        notifier.setCategory('entertainment');

        notifier.reset();

        expect(notifier.state.name, '');
        expect(notifier.state.amountFcfa, 0);
        expect(notifier.state.category, isNull);
        expect(notifier.state.hasInteracted, isFalse);
      });
    });

    group('initializeForEdit', () {
      test('initializes form with subscription data', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Netflix',
          amountFcfa: 5000,
          category: 'entertainment',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: DateTime.now(),
        );

        notifier.initializeForEdit(subscription);

        expect(notifier.state.name, 'Netflix');
        expect(notifier.state.amountFcfa, 5000);
        expect(notifier.state.category, 'entertainment');
        expect(notifier.state.frequency, SubscriptionFrequency.monthly);
        expect(notifier.state.dueDay, 15);
        expect(notifier.state.isActive, isTrue);
        expect(notifier.state.editingId, 1);
      });
    });
  });
}
