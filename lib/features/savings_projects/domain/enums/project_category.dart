import 'package:flutter/material.dart';

/// Predefined categories for savings projects.
enum ProjectCategory {
  travel('travel', 'Voyage', '🏖️', Color(0xFF2196F3)),
  tech('tech', 'Tech / Électronique', '📱', Color(0xFF9C27B0)),
  gift('gift', 'Cadeau', '🎁', Color(0xFFE91E63)),
  transport('transport', 'Transport / Véhicule', '🚗', Color(0xFF4CAF50)),
  home('home', 'Maison / Déco', '🏠', Color(0xFFFF9800)),
  education('education', 'Éducation / Formation', '🎓', Color(0xFF3F51B5)),
  event('event', 'Événement spécial', '💍', Color(0xFFFFD700)),
  other('other', 'Autre', '✨', Color(0xFF607D8B));

  const ProjectCategory(
    this.value,
    this.displayName,
    this.defaultEmoji,
    this.defaultColor,
  );

  /// Database value.
  final String value;

  /// Localized display name.
  final String displayName;

  /// Default emoji for this category.
  final String defaultEmoji;

  /// Default color for this category.
  final Color defaultColor;

  /// Get category from database value.
  static ProjectCategory fromValue(String value) {
    return ProjectCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => ProjectCategory.other,
    );
  }

  /// All categories for UI selection.
  static List<ProjectCategory> get allCategories => ProjectCategory.values;
}
