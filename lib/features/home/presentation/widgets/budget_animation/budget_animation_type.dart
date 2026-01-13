import 'package:flutter/material.dart';

/// Types of budget animations available for customization.
enum BudgetAnimationType {
  cat,
  waterTank,
  battery,
  planet,
  tree;

  /// Display name for the animation type.
  String get displayName {
    switch (this) {
      case BudgetAnimationType.cat:
        return 'Chat';
      case BudgetAnimationType.waterTank:
        return 'Réservoir';
      case BudgetAnimationType.battery:
        return 'Batterie';
      case BudgetAnimationType.planet:
        return 'Planète';
      case BudgetAnimationType.tree:
        return 'Arbre';
    }
  }

  /// Icon for the animation type.
  IconData get icon {
    switch (this) {
      case BudgetAnimationType.cat:
        return Icons.pets;
      case BudgetAnimationType.waterTank:
        return Icons.water_drop;
      case BudgetAnimationType.battery:
        return Icons.battery_full;
      case BudgetAnimationType.planet:
        return Icons.public;
      case BudgetAnimationType.tree:
        return Icons.park;
    }
  }

  /// Emoji for the animation type.
  String get emoji {
    switch (this) {
      case BudgetAnimationType.cat:
        return '🐱';
      case BudgetAnimationType.waterTank:
        return '💧';
      case BudgetAnimationType.battery:
        return '🔋';
      case BudgetAnimationType.planet:
        return '🌍';
      case BudgetAnimationType.tree:
        return '🌳';
    }
  }

  /// Convert to string for storage.
  String toStorageString() => name;

  /// Parse from storage string.
  static BudgetAnimationType fromStorageString(String? value) {
    if (value == null) return BudgetAnimationType.waterTank;
    return BudgetAnimationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BudgetAnimationType.waterTank,
    );
  }
}
