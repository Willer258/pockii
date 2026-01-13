import 'package:pockii/core/database/app_database.dart';
import 'package:pockii/core/database/daos/subscriptions_dao.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SubscriptionsDao dao;

  setUp(() {
    db = AppDatabase.inMemory();
    dao = SubscriptionsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SubscriptionsDao', () {
    // ============== CRUD OPERATIONS ==============

    group('createSubscription', () {
      test('creates a subscription and returns ID', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        expect(id, greaterThan(0));
      });

      test('creates multiple subscriptions with unique IDs', () async {
        final id1 = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        final id2 = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Tontine famille',
            amountFcfa: 25000,
            category: 'family',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );

        expect(id1, isNot(equals(id2)));
      });

      test('creates subscription with isActive defaulting to true', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Orange Money',
            amountFcfa: 1000,
            category: 'utilities',
            frequency: 'weekly',
            dueDay: 1,
          ),
        );

        final subscription = await dao.getSubscriptionById(id);
        expect(subscription!.isActive, isTrue);
      });

      test('creates subscription with isActive set to false', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Old subscription',
            amountFcfa: 3000,
            category: 'other',
            frequency: 'monthly',
            dueDay: 10,
            isActive: const Value(false),
          ),
        );

        final subscription = await dao.getSubscriptionById(id);
        expect(subscription!.isActive, isFalse);
      });

      test('stores FCFA amount as int correctly', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Big subscription',
            amountFcfa: 999999999,
            category: 'other',
            frequency: 'yearly',
            dueDay: 1,
          ),
        );

        final subscription = await dao.getSubscriptionById(id);
        expect(subscription!.amountFcfa, 999999999);
      });
    });

    group('getSubscriptionById', () {
      test('returns subscription when exists', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Test Sub',
            amountFcfa: 10000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 5,
          ),
        );

        final subscription = await dao.getSubscriptionById(id);

        expect(subscription, isNotNull);
        expect(subscription!.name, 'Test Sub');
        expect(subscription.amountFcfa, 10000);
        expect(subscription.category, 'test');
        expect(subscription.frequency, 'monthly');
        expect(subscription.dueDay, 5);
      });

      test('returns null when subscription does not exist', () async {
        final subscription = await dao.getSubscriptionById(999);

        expect(subscription, isNull);
      });
    });

    group('getAllSubscriptions', () {
      test('returns empty list when no subscriptions', () async {
        final subscriptions = await dao.getAllSubscriptions();

        expect(subscriptions, isEmpty);
      });

      test('returns all subscriptions ordered by name', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Zebra',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Apple',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );

        final subscriptions = await dao.getAllSubscriptions();

        expect(subscriptions.length, 2);
        expect(subscriptions[0].name, 'Apple');
        expect(subscriptions[1].name, 'Zebra');
      });
    });

    group('updateSubscription', () {
      test('updates subscription fields', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Original',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        final original = await dao.getSubscriptionById(id);
        final updated = Subscription(
          id: original!.id,
          name: 'Updated',
          amountFcfa: 7500,
          category: 'utilities',
          frequency: 'weekly',
          dueDay: 1,
          isActive: original.isActive,
          createdAt: original.createdAt,
          updatedAt: DateTime.now(),
        );

        final success = await dao.updateSubscription(updated);
        final result = await dao.getSubscriptionById(id);

        expect(success, isTrue);
        expect(result!.name, 'Updated');
        expect(result.amountFcfa, 7500);
        expect(result.category, 'utilities');
        expect(result.frequency, 'weekly');
        expect(result.dueDay, 1);
      });
    });

    group('deleteSubscription', () {
      test('deletes existing subscription', () async {
        final id = await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'To delete',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );

        final deletedCount = await dao.deleteSubscription(id);
        final subscription = await dao.getSubscriptionById(id);

        expect(deletedCount, 1);
        expect(subscription, isNull);
      });

      test('returns 0 when subscription does not exist', () async {
        final deletedCount = await dao.deleteSubscription(999);

        expect(deletedCount, 0);
      });
    });

    // ============== FILTERED QUERIES ==============

    group('getActiveSubscriptions', () {
      test('returns only active subscriptions', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active 1',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(true),
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active 2',
            amountFcfa: 3000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(true),
          ),
        );

        final active = await dao.getActiveSubscriptions();

        expect(active.length, 2);
        expect(active.every((s) => s.isActive), isTrue);
      });
    });

    group('getInactiveSubscriptions', () {
      test('returns only inactive subscriptions', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(true),
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final inactive = await dao.getInactiveSubscriptions();

        expect(inactive.length, 1);
        expect(inactive[0].name, 'Inactive');
      });
    });

    group('getSubscriptionsByCategory', () {
      test('returns subscriptions filtered by category', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Netflix',
            amountFcfa: 5000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Electricity',
            amountFcfa: 20000,
            category: 'utilities',
            frequency: 'monthly',
            dueDay: 10,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Spotify',
            amountFcfa: 3000,
            category: 'entertainment',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );

        final entertainment =
            await dao.getSubscriptionsByCategory('entertainment');

        expect(entertainment.length, 2);
        expect(entertainment.every((s) => s.category == 'entertainment'), isTrue);
      });
    });

    group('getSubscriptionsByFrequency', () {
      test('returns subscriptions filtered by frequency', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Monthly sub',
            amountFcfa: 5000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Weekly sub',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'weekly',
            dueDay: 1,
          ),
        );

        final weekly = await dao.getSubscriptionsByFrequency('weekly');

        expect(weekly.length, 1);
        expect(weekly[0].frequency, 'weekly');
      });
    });

    group('getSubscriptionsDueOnDay', () {
      test('returns active subscriptions due on specific day', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Due on 15',
            amountFcfa: 5000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Due on 1',
            amountFcfa: 3000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Also due on 15 but inactive',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 15,
            isActive: const Value(false),
          ),
        );

        final dueOn15 = await dao.getSubscriptionsDueOnDay(15);

        expect(dueOn15.length, 1);
        expect(dueOn15[0].name, 'Due on 15');
      });
    });

    group('getMonthlySubscriptionsDueBetween', () {
      test('returns monthly subscriptions due within date range', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Due on 5',
            amountFcfa: 5000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 5,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Due on 15',
            amountFcfa: 3000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 15,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Due on 25',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 25,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Weekly (excluded)',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'weekly',
            dueDay: 10,
          ),
        );

        final dueBetween = await dao.getMonthlySubscriptionsDueBetween(5, 20);

        expect(dueBetween.length, 2);
        expect(dueBetween[0].dueDay, 5);
        expect(dueBetween[1].dueDay, 15);
      });
    });

    // ============== AGGREGATE QUERIES ==============

    group('getTotalMonthlyAmount', () {
      test('calculates total monthly amount correctly', () async {
        // Monthly: 10000 FCFA
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Monthly',
            amountFcfa: 10000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        // Weekly: 1000 * 4.33 = 4330 FCFA
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Weekly',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'weekly',
            dueDay: 1,
          ),
        );
        // Yearly: 12000 / 12 = 1000 FCFA
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Yearly',
            amountFcfa: 12000,
            category: 'test',
            frequency: 'yearly',
            dueDay: 1,
          ),
        );
        // Inactive (excluded)
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 50000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final total = await dao.getTotalMonthlyAmount();

        // 10000 + 4330 + 1000 = 15330
        expect(total, 15330);
      });

      test('returns 0 when no active subscriptions', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 10000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final total = await dao.getTotalMonthlyAmount();

        expect(total, 0);
      });
    });

    group('getActiveSubscriptionCount', () {
      test('counts active subscriptions correctly', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active 1',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active 2',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 3000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final count = await dao.getActiveSubscriptionCount();

        expect(count, 2);
      });

      test('returns 0 when no active subscriptions', () async {
        final count = await dao.getActiveSubscriptionCount();

        expect(count, 0);
      });
    });

    // ============== REACTIVE STREAMS ==============

    group('watchAllSubscriptions', () {
      test('emits updates when subscriptions change', () async {
        final stream = dao.watchAllSubscriptions();

        // Initial empty state
        await expectLater(stream, emits(isEmpty));

        // Add subscription
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Test',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
          ),
        );

        await expectLater(stream, emits(hasLength(1)));
      });
    });

    group('watchActiveSubscriptions', () {
      test('emits only active subscriptions', () async {
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Active',
            amountFcfa: 1000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(true),
          ),
        );
        await dao.createSubscription(
          SubscriptionsCompanion.insert(
            name: 'Inactive',
            amountFcfa: 2000,
            category: 'test',
            frequency: 'monthly',
            dueDay: 1,
            isActive: const Value(false),
          ),
        );

        final stream = dao.watchActiveSubscriptions();

        await expectLater(stream, emits(hasLength(1)));
      });
    });
  });
}
