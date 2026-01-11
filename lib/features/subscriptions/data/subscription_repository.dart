import 'package:accountapp/core/database/app_database.dart';
import 'package:accountapp/core/database/daos/subscriptions_dao.dart';
import 'package:accountapp/core/database/database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/subscription_frequency.dart';
import '../domain/models/subscription_model.dart';

/// Repository that abstracts SubscriptionsDao for the presentation layer.
///
/// Handles mapping between domain models (SubscriptionModel) and data layer
/// entities (Subscription from drift).
/// Uses Riverpod provider pattern (ARCH-4).
class SubscriptionRepository {
  /// Creates a SubscriptionRepository with the given DAO.
  SubscriptionRepository(this._dao);

  final SubscriptionsDao _dao;

  // ============== CRUD OPERATIONS ==============

  /// Creates a new subscription and returns its ID.
  Future<int> createSubscription({
    required String name,
    required int amountFcfa,
    required String category,
    required SubscriptionFrequency frequency,
    required int dueDay,
    bool isActive = true,
  }) async {
    final companion = SubscriptionsCompanion.insert(
      name: name,
      amountFcfa: amountFcfa,
      category: category,
      frequency: frequency.toDbValue(),
      dueDay: dueDay,
      isActive: Value(isActive),
    );
    return _dao.createSubscription(companion);
  }

  /// Creates a new subscription from a domain model and returns its ID.
  Future<int> createSubscriptionFromModel(SubscriptionModel subscription) {
    return _dao.createSubscription(subscription.toCompanion());
  }

  /// Gets a specific subscription by ID.
  Future<SubscriptionModel?> getSubscriptionById(int id) async {
    final entity = await _dao.getSubscriptionById(id);
    return entity != null ? SubscriptionModel.fromEntity(entity) : null;
  }

  /// Gets all subscriptions ordered by name.
  Future<List<SubscriptionModel>> getAllSubscriptions() async {
    final entities = await _dao.getAllSubscriptions();
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Updates an existing subscription.
  Future<bool> updateSubscription(SubscriptionModel subscription) async {
    final entity = Subscription(
      id: subscription.id,
      name: subscription.name,
      amountFcfa: subscription.amountFcfa,
      category: subscription.category,
      frequency: subscription.frequency.toDbValue(),
      dueDay: subscription.dueDay,
      isActive: subscription.isActive,
      createdAt: subscription.createdAt,
      updatedAt: subscription.updatedAt,
    );
    return _dao.updateSubscription(entity);
  }

  /// Deletes a subscription by ID.
  Future<int> deleteSubscription(int id) {
    return _dao.deleteSubscription(id);
  }

  /// Deactivates a subscription (soft delete).
  Future<bool> deactivateSubscription(int id) async {
    final existing = await _dao.getSubscriptionById(id);
    if (existing == null) return false;

    final updated = Subscription(
      id: existing.id,
      name: existing.name,
      amountFcfa: existing.amountFcfa,
      category: existing.category,
      frequency: existing.frequency,
      dueDay: existing.dueDay,
      isActive: false,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return _dao.updateSubscription(updated);
  }

  /// Reactivates a subscription.
  Future<bool> reactivateSubscription(int id) async {
    final existing = await _dao.getSubscriptionById(id);
    if (existing == null) return false;

    final updated = Subscription(
      id: existing.id,
      name: existing.name,
      amountFcfa: existing.amountFcfa,
      category: existing.category,
      frequency: existing.frequency,
      dueDay: existing.dueDay,
      isActive: true,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    return _dao.updateSubscription(updated);
  }

  // ============== FILTERED QUERIES ==============

  /// Gets all active subscriptions.
  Future<List<SubscriptionModel>> getActiveSubscriptions() async {
    final entities = await _dao.getActiveSubscriptions();
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Gets all inactive subscriptions.
  Future<List<SubscriptionModel>> getInactiveSubscriptions() async {
    final entities = await _dao.getInactiveSubscriptions();
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Gets subscriptions filtered by category.
  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
    String category,
  ) async {
    final entities = await _dao.getSubscriptionsByCategory(category);
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Gets subscriptions filtered by frequency.
  Future<List<SubscriptionModel>> getSubscriptionsByFrequency(
    SubscriptionFrequency frequency,
  ) async {
    final entities =
        await _dao.getSubscriptionsByFrequency(frequency.toDbValue());
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Gets active subscriptions due on a specific day.
  Future<List<SubscriptionModel>> getSubscriptionsDueOnDay(int day) async {
    final entities = await _dao.getSubscriptionsDueOnDay(day);
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  /// Gets active monthly subscriptions due within a date range.
  Future<List<SubscriptionModel>> getMonthlySubscriptionsDueBetween(
    int startDay,
    int endDay,
  ) async {
    final entities =
        await _dao.getMonthlySubscriptionsDueBetween(startDay, endDay);
    return entities.map(SubscriptionModel.fromEntity).toList();
  }

  // ============== AGGREGATE QUERIES ==============

  /// Calculates the total monthly amount for all active subscriptions.
  Future<int> getTotalMonthlyAmount() {
    return _dao.getTotalMonthlyAmount();
  }

  /// Counts active subscriptions.
  Future<int> getActiveSubscriptionCount() {
    return _dao.getActiveSubscriptionCount();
  }

  // ============== REACTIVE STREAMS ==============

  /// Watches all subscriptions for reactive updates.
  Stream<List<SubscriptionModel>> watchAllSubscriptions() {
    return _dao.watchAllSubscriptions().map(
          (entities) => entities.map(SubscriptionModel.fromEntity).toList(),
        );
  }

  /// Watches active subscriptions for reactive updates.
  Stream<List<SubscriptionModel>> watchActiveSubscriptions() {
    return _dao.watchActiveSubscriptions().map(
          (entities) => entities.map(SubscriptionModel.fromEntity).toList(),
        );
  }
}

/// Provider for SubscriptionRepository.
///
/// Uses Riverpod provider pattern (ARCH-4).
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final dao = ref.watch(subscriptionsDaoProvider);
  return SubscriptionRepository(dao);
});
