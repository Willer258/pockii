import 'package:pockii/features/subscriptions/presentation/providers/subscriptions_list_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionsListState', () {
    test('initial state has showInactive false', () {
      const state = SubscriptionsListState();

      expect(state.showInactive, isFalse);
    });

    test('copyWith replaces showInactive correctly', () {
      const original = SubscriptionsListState(showInactive: false);

      final updated = original.copyWith(showInactive: true);

      expect(updated.showInactive, isTrue);
    });

    test('copyWith preserves showInactive when not specified', () {
      const original = SubscriptionsListState(showInactive: true);

      final updated = original.copyWith();

      expect(updated.showInactive, isTrue);
    });
  });

  group('SubscriptionsListNotifier', () {
    late SubscriptionsListNotifier notifier;

    setUp(() {
      notifier = SubscriptionsListNotifier();
    });

    test('initial state has showInactive false', () {
      expect(notifier.state.showInactive, isFalse);
    });

    group('toggleShowInactive', () {
      test('toggles from false to true', () {
        notifier.toggleShowInactive();

        expect(notifier.state.showInactive, isTrue);
      });

      test('toggles from true to false', () {
        notifier.toggleShowInactive(); // false -> true
        notifier.toggleShowInactive(); // true -> false

        expect(notifier.state.showInactive, isFalse);
      });
    });

    group('setShowInactive', () {
      test('sets showInactive to true', () {
        notifier.setShowInactive(value: true);

        expect(notifier.state.showInactive, isTrue);
      });

      test('sets showInactive to false', () {
        notifier.setShowInactive(value: true);
        notifier.setShowInactive(value: false);

        expect(notifier.state.showInactive, isFalse);
      });
    });
  });
}
