import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:pockii/core/database/app_database.dart';

import '../enums/contribution_frequency.dart';
import '../enums/project_category.dart';

/// Domain model representing a savings project (cagnotte).
///
/// This is the presentation-layer representation of a savings project,
/// using typed enums and Flutter Color objects.
/// Uses int for FCFA amounts (ARCH-7).
class SavingsProjectModel {
  /// Creates a new SavingsProjectModel.
  const SavingsProjectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmountFcfa,
    required this.currentAmountFcfa,
    required this.emoji,
    required this.color,
    required this.createdAt,
    this.imageUrl,
    this.targetDate,
    this.autoContributionEnabled = false,
    this.autoContributionAmountFcfa = 0,
    this.autoContributionFrequency,
    this.nextContributionDate,
    this.isArchived = false,
    this.completedAt,
    this.updatedAt,
  });

  /// Creates a SavingsProjectModel from a drift SavingsProject entity.
  factory SavingsProjectModel.fromEntity(SavingsProject entity) {
    return SavingsProjectModel(
      id: entity.id,
      name: entity.name,
      category: ProjectCategory.fromValue(entity.category),
      targetAmountFcfa: entity.targetAmountFcfa,
      currentAmountFcfa: entity.currentAmountFcfa,
      emoji: entity.emoji,
      color: _colorFromHex(entity.color),
      imageUrl: entity.imageUrl,
      targetDate: entity.targetDate,
      autoContributionEnabled: entity.autoContributionEnabled,
      autoContributionAmountFcfa: entity.autoContributionAmountFcfa,
      autoContributionFrequency:
          ContributionFrequency.fromValue(entity.autoContributionFrequency),
      nextContributionDate: entity.nextContributionDate,
      isArchived: entity.isArchived,
      completedAt: entity.completedAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Unique identifier for this savings project.
  final int id;

  /// Name of the project.
  final String name;

  /// Category of the project.
  final ProjectCategory category;

  /// Target amount to save in FCFA.
  final int targetAmountFcfa;

  /// Current amount saved in FCFA.
  final int currentAmountFcfa;

  /// Emoji icon for the project.
  final String emoji;

  /// Color for the project UI.
  final Color color;

  /// Optional image URL for the project cover.
  final String? imageUrl;

  /// Optional target date to reach the goal.
  final DateTime? targetDate;

  /// Whether auto-contribution is enabled.
  final bool autoContributionEnabled;

  /// Auto-contribution amount in FCFA.
  final int autoContributionAmountFcfa;

  /// Auto-contribution frequency.
  final ContributionFrequency? autoContributionFrequency;

  /// Next scheduled auto-contribution date.
  final DateTime? nextContributionDate;

  /// Whether the project is archived.
  final bool isArchived;

  /// Timestamp when goal was reached.
  final DateTime? completedAt;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Timestamp when this record was last updated.
  final DateTime? updatedAt;

  // === Computed Properties ===

  /// Progress as a fraction (0.0 to 1.0+).
  double get progress => targetAmountFcfa > 0
      ? currentAmountFcfa / targetAmountFcfa
      : 0.0;

  /// Progress as percentage (0 to 100+).
  int get progressPercentage => (progress * 100).round();

  /// Amount remaining to reach the goal.
  int get remainingAmountFcfa => targetAmountFcfa - currentAmountFcfa;

  /// Whether the goal has been reached.
  bool get isGoalReached => currentAmountFcfa >= targetAmountFcfa;

  /// Whether the project is active (not archived and not completed).
  bool get isActive => !isArchived && completedAt == null;

  /// Days until target date (null if no target date).
  int? daysUntilTarget(DateTime now) {
    if (targetDate == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      targetDate!.year,
      targetDate!.month,
      targetDate!.day,
    );
    return target.difference(today).inDays;
  }

  /// Suggested monthly contribution to reach goal by target date.
  int? suggestedMonthlyContribution(DateTime now) {
    if (targetDate == null || isGoalReached) return null;
    final days = daysUntilTarget(now);
    if (days == null || days <= 0) return remainingAmountFcfa;
    final months = (days / 30).ceil();
    if (months <= 0) return remainingAmountFcfa;
    return (remainingAmountFcfa / months).ceil();
  }

  // === Color Helpers ===

  /// Background color (10% opacity).
  Color get backgroundColor => color.withValues(alpha: 0.1);

  /// Border color (30% opacity).
  Color get borderColor => color.withValues(alpha: 0.3);

  /// Text color based on luminance.
  Color get textOnColor =>
      color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

  // === Conversion Methods ===

  /// Converts this model to a drift SavingsProjectsCompanion for insertion.
  SavingsProjectsCompanion toCompanion() {
    return SavingsProjectsCompanion.insert(
      name: name,
      category: category.value,
      targetAmountFcfa: targetAmountFcfa,
      currentAmountFcfa: Value(currentAmountFcfa),
      emoji: Value(emoji),
      color: Value(_colorToHex(color)),
      imageUrl: Value(imageUrl),
      targetDate: Value(targetDate),
      autoContributionEnabled: Value(autoContributionEnabled),
      autoContributionAmountFcfa: Value(autoContributionAmountFcfa),
      autoContributionFrequency: Value(autoContributionFrequency?.value),
      nextContributionDate: Value(nextContributionDate),
      isArchived: Value(isArchived),
      completedAt: Value(completedAt),
    );
  }

  /// Creates a copy of this SavingsProjectModel with the given fields replaced.
  SavingsProjectModel copyWith({
    int? id,
    String? name,
    ProjectCategory? category,
    int? targetAmountFcfa,
    int? currentAmountFcfa,
    String? emoji,
    Color? color,
    String? imageUrl,
    DateTime? targetDate,
    bool? autoContributionEnabled,
    int? autoContributionAmountFcfa,
    ContributionFrequency? autoContributionFrequency,
    DateTime? nextContributionDate,
    bool? isArchived,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmountFcfa: targetAmountFcfa ?? this.targetAmountFcfa,
      currentAmountFcfa: currentAmountFcfa ?? this.currentAmountFcfa,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      targetDate: targetDate ?? this.targetDate,
      autoContributionEnabled:
          autoContributionEnabled ?? this.autoContributionEnabled,
      autoContributionAmountFcfa:
          autoContributionAmountFcfa ?? this.autoContributionAmountFcfa,
      autoContributionFrequency:
          autoContributionFrequency ?? this.autoContributionFrequency,
      nextContributionDate: nextContributionDate ?? this.nextContributionDate,
      isArchived: isArchived ?? this.isArchived,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SavingsProjectModel(id: $id, name: $name, '
        'progress: $progressPercentage%)';
  }
}

/// Convert hex string to Color.
Color _colorFromHex(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6) buffer.write('FF');
  buffer.write(hex);
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Convert Color to hex string (without alpha).
String _colorToHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '$r$g$b'.toUpperCase();
}
