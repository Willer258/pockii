import 'package:drift/drift.dart';
import 'package:pockii/core/database/app_database.dart';

import '../enums/contribution_type.dart';

/// Domain model representing a contribution to a savings project.
///
/// This is the presentation-layer representation of a contribution,
/// using typed enums instead of raw strings.
/// Uses int for FCFA amounts (ARCH-7).
class ProjectContributionModel {
  /// Creates a new ProjectContributionModel.
  const ProjectContributionModel({
    required this.id,
    required this.projectId,
    required this.amountFcfa,
    required this.type,
    required this.date,
    required this.createdAt,
    this.note,
  });

  /// Creates a ProjectContributionModel from a drift ProjectContribution entity.
  factory ProjectContributionModel.fromEntity(ProjectContribution entity) {
    return ProjectContributionModel(
      id: entity.id,
      projectId: entity.projectId,
      amountFcfa: entity.amountFcfa,
      type: ContributionType.fromValue(entity.type),
      note: entity.note,
      date: entity.date,
      createdAt: entity.createdAt,
    );
  }

  /// Unique identifier for this contribution.
  final int id;

  /// Reference to the savings project.
  final int projectId;

  /// Amount in FCFA. Positive = deposit, Negative = withdrawal.
  final int amountFcfa;

  /// Type of contribution.
  final ContributionType type;

  /// Optional note for this contribution.
  final String? note;

  /// Date of the contribution.
  final DateTime date;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  // === Computed Properties ===

  /// Absolute amount (always positive).
  int get absoluteAmount => amountFcfa.abs();

  /// Whether this is a deposit.
  bool get isDeposit => amountFcfa > 0;

  /// Whether this is a withdrawal.
  bool get isWithdrawal => amountFcfa < 0;

  /// Whether this was an automatic contribution.
  bool get isAutomatic => type.isAutomatic;

  /// Whether this contribution failed (auto-contribution that couldn't complete).
  bool get isFailed => type == ContributionType.autoFailed;

  // === Conversion Methods ===

  /// Converts this model to a drift ProjectContributionsCompanion for insertion.
  ProjectContributionsCompanion toCompanion() {
    return ProjectContributionsCompanion.insert(
      projectId: projectId,
      amountFcfa: amountFcfa,
      type: type.value,
      note: Value(note),
      date: Value(date),
    );
  }

  /// Creates a copy of this ProjectContributionModel with the given fields replaced.
  ProjectContributionModel copyWith({
    int? id,
    int? projectId,
    int? amountFcfa,
    ContributionType? type,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ProjectContributionModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectContributionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProjectContributionModel(id: $id, projectId: $projectId, '
        'amountFcfa: $amountFcfa, type: ${type.displayName})';
  }
}
