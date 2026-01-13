import 'package:accountapp/core/database/app_database.dart';
import 'package:drift/drift.dart';

import 'subscription_frequency.dart';

/// Domain model representing a recurring expense (subscription).
///
/// This is the presentation-layer representation of a subscription,
/// using typed enums instead of raw strings for the frequency field.
/// Uses int for FCFA amounts (ARCH-7).
class SubscriptionModel {
  /// Creates a new SubscriptionModel.
  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.amountFcfa,
    required this.category,
    required this.frequency,
    required this.dueDay,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a SubscriptionModel from a drift Subscription entity.
  factory SubscriptionModel.fromEntity(Subscription entity) {
    return SubscriptionModel(
      id: entity.id,
      name: entity.name,
      amountFcfa: entity.amountFcfa,
      category: entity.category,
      frequency: SubscriptionFrequencyParser.fromDbValue(entity.frequency),
      dueDay: entity.dueDay,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Unique identifier for this subscription.
  final int id;

  /// Subscription name (e.g., 'Netflix', 'Tontine famille').
  final String name;

  /// Amount in FCFA (integer only, never double).
  final int amountFcfa;

  /// Category for grouping (e.g., 'entertainment', 'family').
  final String category;

  /// Frequency of payment (monthly, weekly, yearly).
  final SubscriptionFrequency frequency;

  /// Day of the period when payment is due (1-31 for monthly, 1-7 for weekly).
  final int dueDay;

  /// Whether this subscription is currently active.
  final bool isActive;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Timestamp when this record was last updated.
  final DateTime? updatedAt;

  /// Converts this model to a drift SubscriptionsCompanion for insertion.
  ///
  /// The [id] is not included as it's auto-generated.
  SubscriptionsCompanion toCompanion() {
    return SubscriptionsCompanion.insert(
      name: name,
      amountFcfa: amountFcfa,
      category: category,
      frequency: frequency.toDbValue(),
      dueDay: dueDay,
      isActive: Value(isActive),
    );
  }

  /// Converts this model to a drift Subscription entity for updates.
  Subscription toEntity() {
    return Subscription(
      id: id,
      name: name,
      amountFcfa: amountFcfa,
      category: category,
      frequency: frequency.toDbValue(),
      dueDay: dueDay,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Calculates the monthly equivalent amount for this subscription.
  ///
  /// Weekly subscriptions are multiplied by 4.33 (average weeks per month).
  /// Quarterly subscriptions are divided by 3.
  /// Bi-annual subscriptions are divided by 6.
  /// Yearly subscriptions are divided by 12.
  int get monthlyEquivalent {
    switch (frequency) {
      case SubscriptionFrequency.monthly:
        return amountFcfa;
      case SubscriptionFrequency.weekly:
        // Approximate 4.33 weeks per month
        return (amountFcfa * 433 / 100).round();
      case SubscriptionFrequency.quarterly:
        // Divide by 3 months
        return (amountFcfa / 3).round();
      case SubscriptionFrequency.biannual:
        // Divide by 6 months
        return (amountFcfa / 6).round();
      case SubscriptionFrequency.yearly:
        // Divide by 12 months
        return (amountFcfa / 12).round();
    }
  }

  /// Creates a copy of this SubscriptionModel with the given fields replaced.
  SubscriptionModel copyWith({
    int? id,
    String? name,
    int? amountFcfa,
    String? category,
    SubscriptionFrequency? frequency,
    int? dueDay,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionModel &&
        other.id == id &&
        other.name == name &&
        other.amountFcfa == amountFcfa &&
        other.category == category &&
        other.frequency == frequency &&
        other.dueDay == dueDay &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      amountFcfa,
      category,
      frequency,
      dueDay,
      isActive,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, name: $name, amountFcfa: $amountFcfa, '
        'category: $category, frequency: $frequency, dueDay: $dueDay, '
        'isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
