import 'package:accountapp/core/database/app_database.dart';
import 'package:drift/drift.dart';

import 'planned_expense_status.dart';

/// Domain model representing a planned future expense.
///
/// This is the presentation-layer representation of a planned expense,
/// using typed enums instead of raw strings for the status field.
/// Uses int for FCFA amounts (ARCH-7).
class PlannedExpenseModel {
  /// Creates a new PlannedExpenseModel.
  const PlannedExpenseModel({
    required this.id,
    required this.description,
    required this.amountFcfa,
    required this.expectedDate,
    required this.status,
    required this.createdAt,
    this.category,
    this.updatedAt,
  });

  /// Creates a PlannedExpenseModel from a drift PlannedExpense entity.
  factory PlannedExpenseModel.fromEntity(PlannedExpense entity) {
    return PlannedExpenseModel(
      id: entity.id,
      description: entity.description,
      amountFcfa: entity.amountFcfa,
      expectedDate: entity.expectedDate,
      status: entity.status.toPlannedExpenseStatus(),
      category: entity.category,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Unique identifier for this planned expense.
  final int id;

  /// Description of the planned expense.
  final String description;

  /// Amount in FCFA (integer only, never double).
  final int amountFcfa;

  /// Expected date when the expense will occur.
  final DateTime expectedDate;

  /// Status of the planned expense.
  final PlannedExpenseStatus status;

  /// Optional category for the expense.
  final String? category;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Timestamp when this record was last updated.
  final DateTime? updatedAt;

  /// Calculates the number of days until the expected date.
  ///
  /// Returns a negative number if the date has passed.
  int daysUntilDue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      expectedDate.year,
      expectedDate.month,
      expectedDate.day,
    );
    return dueDate.difference(today).inDays;
  }

  /// Returns true if this planned expense is due today.
  bool isDueToday(DateTime now) {
    return daysUntilDue(now) == 0;
  }

  /// Returns true if this planned expense is overdue.
  bool isOverdue(DateTime now) {
    return daysUntilDue(now) < 0 && status == PlannedExpenseStatus.pending;
  }

  /// Returns true if this planned expense is pending.
  bool get isPending => status == PlannedExpenseStatus.pending;

  /// Returns true if this planned expense has been converted.
  bool get isConverted => status == PlannedExpenseStatus.converted;

  /// Returns true if this planned expense has been cancelled.
  bool get isCancelled => status == PlannedExpenseStatus.cancelled;

  /// Returns true if this planned expense has been postponed.
  bool get isPostponed => status == PlannedExpenseStatus.postponed;

  /// Converts this model to a drift PlannedExpensesCompanion for insertion.
  ///
  /// The [id] is not included as it's auto-generated.
  PlannedExpensesCompanion toCompanion() {
    return PlannedExpensesCompanion.insert(
      description: description,
      amountFcfa: amountFcfa,
      expectedDate: expectedDate,
      status: Value(status.toDbValue()),
      category: Value(category),
    );
  }

  /// Converts this model to a drift PlannedExpense entity for updates.
  PlannedExpense toEntity() {
    return PlannedExpense(
      id: id,
      description: description,
      amountFcfa: amountFcfa,
      expectedDate: expectedDate,
      status: status.toDbValue(),
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a copy of this PlannedExpenseModel with the given fields replaced.
  PlannedExpenseModel copyWith({
    int? id,
    String? description,
    int? amountFcfa,
    DateTime? expectedDate,
    PlannedExpenseStatus? status,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlannedExpenseModel(
      id: id ?? this.id,
      description: description ?? this.description,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      expectedDate: expectedDate ?? this.expectedDate,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlannedExpenseModel &&
        other.id == id &&
        other.description == description &&
        other.amountFcfa == amountFcfa &&
        other.expectedDate == expectedDate &&
        other.status == status &&
        other.category == category &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      description,
      amountFcfa,
      expectedDate,
      status,
      category,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'PlannedExpenseModel(id: $id, description: $description, '
        'amountFcfa: $amountFcfa, expectedDate: $expectedDate, '
        'status: $status, category: $category, createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }
}
