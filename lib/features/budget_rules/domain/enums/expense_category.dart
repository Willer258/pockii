import 'package:flutter/material.dart';

/// Categories for the 50/30/20 budget rule.
///
/// - Needs (50%): Essential expenses (rent, utilities, transport, food basics)
/// - Wants (30%): Non-essential spending (entertainment, dining out, hobbies)
/// - Savings (20%): Savings and investments
enum ExpenseCategory {
  /// Essential needs - target 50% of budget
  needs,

  /// Wants and lifestyle - target 30% of budget
  wants,

  /// Savings and investments - target 20% of budget
  savings;

  /// Display name in French.
  String get displayName {
    switch (this) {
      case ExpenseCategory.needs:
        return 'Besoins';
      case ExpenseCategory.wants:
        return 'Envies';
      case ExpenseCategory.savings:
        return 'Épargne';
    }
  }

  /// Description of the category.
  String get description {
    switch (this) {
      case ExpenseCategory.needs:
        return 'Loyer, transport, courses essentielles, abonnements obligatoires';
      case ExpenseCategory.wants:
        return 'Loisirs, restaurants, shopping, sorties';
      case ExpenseCategory.savings:
        return 'Épargne, investissements, fonds d\'urgence';
    }
  }

  /// Target percentage for this category.
  int get targetPercentage {
    switch (this) {
      case ExpenseCategory.needs:
        return 50;
      case ExpenseCategory.wants:
        return 30;
      case ExpenseCategory.savings:
        return 20;
    }
  }

  /// Color for the category.
  Color get color {
    switch (this) {
      case ExpenseCategory.needs:
        return const Color(0xFF2196F3); // Blue
      case ExpenseCategory.wants:
        return const Color(0xFFFF9800); // Orange
      case ExpenseCategory.savings:
        return const Color(0xFF4CAF50); // Green
    }
  }

  /// Icon for the category.
  IconData get icon {
    switch (this) {
      case ExpenseCategory.needs:
        return Icons.home_outlined;
      case ExpenseCategory.wants:
        return Icons.celebration_outlined;
      case ExpenseCategory.savings:
        return Icons.savings_outlined;
    }
  }

  /// Emoji for the category.
  String get emoji {
    switch (this) {
      case ExpenseCategory.needs:
        return '🏠';
      case ExpenseCategory.wants:
        return '🎉';
      case ExpenseCategory.savings:
        return '💰';
    }
  }

  /// Convert to string for storage.
  String toStorageString() => name;

  /// Parse from storage string.
  static ExpenseCategory fromStorageString(String? value) {
    if (value == null) return ExpenseCategory.needs;
    return ExpenseCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ExpenseCategory.needs,
    );
  }
}

/// Default category mappings for common expense types.
class DefaultCategoryMappings {
  DefaultCategoryMappings._();

  /// Map common transaction descriptions to categories.
  static ExpenseCategory guessCategory(String description) {
    final lower = description.toLowerCase();

    // Needs patterns
    if (_matchesAny(lower, _needsPatterns)) {
      return ExpenseCategory.needs;
    }

    // Savings patterns
    if (_matchesAny(lower, _savingsPatterns)) {
      return ExpenseCategory.savings;
    }

    // Default to wants
    return ExpenseCategory.wants;
  }

  static bool _matchesAny(String text, List<String> patterns) {
    return patterns.any((pattern) => text.contains(pattern));
  }

  static const _needsPatterns = [
    'loyer',
    'rent',
    'électricité',
    'electricite',
    'eau',
    'gaz',
    'transport',
    'bus',
    'taxi',
    'essence',
    'carburant',
    'courses',
    'marché',
    'supermarché',
    'pharmacie',
    'médecin',
    'hôpital',
    'santé',
    'assurance',
    'école',
    'scolarité',
    'internet',
    'téléphone',
    'mobile',
  ];

  static const _savingsPatterns = [
    'savings', // category id
    'épargne',
    'epargne',
    'investissement',
    'placement',
    'tontine',
    'économie',
    'economie',
  ];
}
