import 'package:pockii/features/subscriptions/domain/models/subscription_frequency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionFrequency', () {
    group('toDbValue', () {
      test('monthly returns "monthly"', () {
        expect(SubscriptionFrequency.monthly.toDbValue(), 'monthly');
      });

      test('weekly returns "weekly"', () {
        expect(SubscriptionFrequency.weekly.toDbValue(), 'weekly');
      });

      test('yearly returns "yearly"', () {
        expect(SubscriptionFrequency.yearly.toDbValue(), 'yearly');
      });
    });

    group('displayName', () {
      test('monthly returns "Mensuel"', () {
        expect(SubscriptionFrequency.monthly.displayName, 'Mensuel');
      });

      test('weekly returns "Hebdomadaire"', () {
        expect(SubscriptionFrequency.weekly.displayName, 'Hebdomadaire');
      });

      test('yearly returns "Annuel"', () {
        expect(SubscriptionFrequency.yearly.displayName, 'Annuel');
      });
    });
  });

  group('SubscriptionFrequencyParser', () {
    group('fromDbValue', () {
      test('parses "monthly" correctly', () {
        expect(
          SubscriptionFrequencyParser.fromDbValue('monthly'),
          SubscriptionFrequency.monthly,
        );
      });

      test('parses "weekly" correctly', () {
        expect(
          SubscriptionFrequencyParser.fromDbValue('weekly'),
          SubscriptionFrequency.weekly,
        );
      });

      test('parses "yearly" correctly', () {
        expect(
          SubscriptionFrequencyParser.fromDbValue('yearly'),
          SubscriptionFrequency.yearly,
        );
      });

      test('defaults to monthly for unknown value', () {
        expect(
          SubscriptionFrequencyParser.fromDbValue('unknown'),
          SubscriptionFrequency.monthly,
        );
      });

      test('defaults to monthly for empty string', () {
        expect(
          SubscriptionFrequencyParser.fromDbValue(''),
          SubscriptionFrequency.monthly,
        );
      });
    });
  });
}
