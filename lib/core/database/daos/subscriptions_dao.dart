import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/subscriptions_table.dart';

part 'subscriptions_dao.g.dart';

/// Data Access Object for subscriptions (recurring expenses).
///
/// Provides CRUD operations and filtered queries for the subscriptions table.
/// All monetary values are handled as integers (FCFA, ARCH-7).
@DriftAccessor(tables: [Subscriptions])
class SubscriptionsDao extends DatabaseAccessor<AppDatabase>
    with _$SubscriptionsDaoMixin {
  SubscriptionsDao(super.db);

  // ============== CRUD OPERATIONS ==============

  /// Creates a new subscription and returns its ID.
  Future<int> createSubscription(SubscriptionsCompanion subscription) {
    return into(subscriptions).insert(subscription);
  }

  /// Gets a specific subscription by ID.
  Future<Subscription?> getSubscriptionById(int id) {
    return (select(subscriptions)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gets all subscriptions ordered by name.
  Future<List<Subscription>> getAllSubscriptions() {
    return (select(subscriptions)
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Updates an existing subscription.
  ///
  /// Returns true if the update was successful.
  Future<bool> updateSubscription(Subscription subscription) {
    return update(subscriptions).replace(subscription);
  }

  /// Deletes a subscription by ID.
  ///
  /// Returns the number of deleted rows.
  Future<int> deleteSubscription(int id) {
    return (delete(subscriptions)..where((s) => s.id.equals(id))).go();
  }

  // ============== FILTERED QUERIES ==============

  /// Gets all active subscriptions.
  Future<List<Subscription>> getActiveSubscriptions() {
    return (select(subscriptions)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets all inactive subscriptions.
  Future<List<Subscription>> getInactiveSubscriptions() {
    return (select(subscriptions)
          ..where((s) => s.isActive.equals(false))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets subscriptions filtered by category.
  Future<List<Subscription>> getSubscriptionsByCategory(String category) {
    return (select(subscriptions)
          ..where((s) => s.category.equals(category))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets subscriptions filtered by frequency.
  Future<List<Subscription>> getSubscriptionsByFrequency(String frequency) {
    return (select(subscriptions)
          ..where((s) => s.frequency.equals(frequency))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets active subscriptions due on a specific day.
  ///
  /// For monthly subscriptions, [day] is 1-31.
  /// For weekly subscriptions, [day] is 1-7.
  Future<List<Subscription>> getSubscriptionsDueOnDay(int day) {
    return (select(subscriptions)
          ..where((s) => s.isActive.equals(true) & s.dueDay.equals(day))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .get();
  }

  /// Gets active monthly subscriptions due within a date range.
  ///
  /// Useful for calculating subscriptions due in the current month.
  Future<List<Subscription>> getMonthlySubscriptionsDueBetween(
    int startDay,
    int endDay,
  ) {
    return (select(subscriptions)
          ..where(
            (s) =>
                s.isActive.equals(true) &
                s.frequency.equals('monthly') &
                s.dueDay.isBiggerOrEqualValue(startDay) &
                s.dueDay.isSmallerOrEqualValue(endDay),
          )
          ..orderBy([
            (s) => OrderingTerm(expression: s.dueDay, mode: OrderingMode.asc),
          ]))
        .get();
  }

  // ============== AGGREGATE QUERIES ==============

  /// Calculates the total monthly amount for all active subscriptions.
  ///
  /// Weekly subscriptions are multiplied by 4.33 (average weeks per month).
  /// Yearly subscriptions are divided by 12.
  Future<int> getTotalMonthlyAmount() async {
    final active = await getActiveSubscriptions();
    var total = 0;

    for (final sub in active) {
      switch (sub.frequency) {
        case 'monthly':
          total += sub.amountFcfa;
        case 'weekly':
          // Approximate 4.33 weeks per month
          total += (sub.amountFcfa * 433 / 100).round();
        case 'yearly':
          // Divide by 12 months
          total += (sub.amountFcfa / 12).round();
      }
    }

    return total;
  }

  /// Counts active subscriptions.
  Future<int> getActiveSubscriptionCount() async {
    final result = await (selectOnly(subscriptions)
          ..addColumns([subscriptions.id.count()])
          ..where(subscriptions.isActive.equals(true)))
        .getSingleOrNull();

    return result?.read(subscriptions.id.count()) ?? 0;
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all subscriptions for reactive updates.
  Stream<List<Subscription>> watchAllSubscriptions() {
    return (select(subscriptions)
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// Watches active subscriptions for reactive updates.
  Stream<List<Subscription>> watchActiveSubscriptions() {
    return (select(subscriptions)
          ..where((s) => s.isActive.equals(true))
          ..orderBy([
            (s) => OrderingTerm(expression: s.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }
}
