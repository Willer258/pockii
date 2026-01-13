import 'package:pockii/features/subscriptions/domain/models/subscription_frequency.dart';
import 'package:pockii/features/subscriptions/domain/models/subscription_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionModel', () {
    final now = DateTime(2026, 1, 15, 10, 30);

    test('creates a valid subscription model', () {
      final subscription = SubscriptionModel(
        id: 1,
        name: 'Netflix',
        amountFcfa: 5000,
        category: 'entertainment',
        frequency: SubscriptionFrequency.monthly,
        dueDay: 15,
        isActive: true,
        createdAt: now,
      );

      expect(subscription.id, 1);
      expect(subscription.name, 'Netflix');
      expect(subscription.amountFcfa, 5000);
      expect(subscription.category, 'entertainment');
      expect(subscription.frequency, SubscriptionFrequency.monthly);
      expect(subscription.dueDay, 15);
      expect(subscription.isActive, true);
      expect(subscription.createdAt, now);
      expect(subscription.updatedAt, isNull);
    });

    group('monthlyEquivalent', () {
      test('returns same amount for monthly subscription', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 10000,
          category: 'test',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 1,
          isActive: true,
          createdAt: now,
        );

        expect(subscription.monthlyEquivalent, 10000);
      });

      test('calculates weekly subscription as amount * 4.33', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 1000,
          category: 'test',
          frequency: SubscriptionFrequency.weekly,
          dueDay: 1,
          isActive: true,
          createdAt: now,
        );

        // 1000 * 433 / 100 = 4330
        expect(subscription.monthlyEquivalent, 4330);
      });

      test('calculates yearly subscription as amount / 12', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 12000,
          category: 'test',
          frequency: SubscriptionFrequency.yearly,
          dueDay: 1,
          isActive: true,
          createdAt: now,
        );

        // 12000 / 12 = 1000
        expect(subscription.monthlyEquivalent, 1000);
      });

      test('rounds yearly calculation correctly', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 10000, // 10000 / 12 = 833.33
          category: 'test',
          frequency: SubscriptionFrequency.yearly,
          dueDay: 1,
          isActive: true,
          createdAt: now,
        );

        expect(subscription.monthlyEquivalent, 833);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final original = SubscriptionModel(
          id: 1,
          name: 'Original',
          amountFcfa: 5000,
          category: 'entertainment',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: now,
        );

        final updated = original.copyWith(
          name: 'Updated',
          amountFcfa: 7500,
        );

        expect(updated.id, 1);
        expect(updated.name, 'Updated');
        expect(updated.amountFcfa, 7500);
        expect(updated.category, 'entertainment');
        expect(updated.frequency, SubscriptionFrequency.monthly);
        expect(updated.dueDay, 15);
        expect(updated.isActive, true);
      });

      test('preserves all fields when no changes specified', () {
        final original = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 5000,
          category: 'test',
          frequency: SubscriptionFrequency.weekly,
          dueDay: 3,
          isActive: false,
          createdAt: now,
          updatedAt: now,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('equality', () {
      test('equal subscriptions are equal', () {
        final sub1 = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 5000,
          category: 'test',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: now,
        );

        final sub2 = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 5000,
          category: 'test',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: now,
        );

        expect(sub1, equals(sub2));
        expect(sub1.hashCode, equals(sub2.hashCode));
      });

      test('different subscriptions are not equal', () {
        final sub1 = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 5000,
          category: 'test',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: now,
        );

        final sub2 = SubscriptionModel(
          id: 2,
          name: 'Other',
          amountFcfa: 3000,
          category: 'other',
          frequency: SubscriptionFrequency.weekly,
          dueDay: 1,
          isActive: false,
          createdAt: now,
        );

        expect(sub1, isNot(equals(sub2)));
      });
    });

    group('toString', () {
      test('produces readable string representation', () {
        final subscription = SubscriptionModel(
          id: 1,
          name: 'Test',
          amountFcfa: 5000,
          category: 'test',
          frequency: SubscriptionFrequency.monthly,
          dueDay: 15,
          isActive: true,
          createdAt: now,
        );

        final str = subscription.toString();

        expect(str, contains('id: 1'));
        expect(str, contains('name: Test'));
        expect(str, contains('amountFcfa: 5000'));
      });
    });
  });
}
