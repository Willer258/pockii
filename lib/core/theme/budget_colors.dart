import 'package:flutter/material.dart';

/// Budget status colors for visual feedback on remaining budget.
///
/// These colors communicate budget health at a glance:
/// - OK (green): >30% remaining - healthy budget
/// - Warning (orange): 10-30% remaining - caution needed
/// - Danger (red): <10% remaining or negative - critical
///
/// Note: Warning color (#FF9800) has 3.0:1 contrast ratio.
/// Always use with icon or text label, never color alone for accessibility.
abstract class BudgetColors {
  // ============================================
  // Budget Status Colors
  // ============================================

  /// Budget OK: >30% remaining
  /// Indicates healthy budget status
  static const Color ok = Color(0xFF4CAF50);

  /// Budget Warning: 10-30% remaining
  /// Indicates caution needed, spending should slow down
  static const Color warning = Color(0xFFFF9800);

  /// Budget Danger: <10% remaining OR negative
  /// Indicates critical status, immediate attention needed
  static const Color danger = Color(0xFFF44336);

  // ============================================
  // Threshold Constants
  // ============================================

  /// Threshold for OK status (above this percentage)
  static const double okThreshold = 0.30;

  /// Threshold for warning status (above this, below okThreshold)
  static const double warningThreshold = 0.10;

  // ============================================
  // Color Selection Methods
  // ============================================

  /// Returns appropriate color based on remaining percentage.
  ///
  /// [percentage] should be a value between 0.0 and 1.0 (or higher if overfunded).
  /// - > 0.30: returns [ok] (green)
  /// - > 0.10 and <= 0.30: returns [warning] (orange)
  /// - <= 0.10 or negative: returns [danger] (red)
  ///
  /// Example:
  /// ```dart
  /// final color = BudgetColors.forPercentage(0.25); // returns warning
  /// ```
  static Color forPercentage(double percentage) {
    if (percentage > okThreshold) return ok;
    if (percentage > warningThreshold) return warning;
    return danger;
  }

  /// Returns color for a remaining budget amount relative to total.
  ///
  /// This is a convenience method that calculates the percentage and
  /// delegates to [forPercentage].
  ///
  /// [remaining] is the current remaining budget (can be negative if overspent).
  /// [total] is the total monthly budget.
  ///
  /// If [total] is <= 0, returns [danger] to avoid division errors
  /// and because a zero/negative budget is always critical.
  ///
  /// Example:
  /// ```dart
  /// final color = BudgetColors.forRemaining(75000, 300000); // 25% -> warning
  /// ```
  static Color forRemaining(int remaining, int total) {
    if (total <= 0) return danger;
    return forPercentage(remaining / total);
  }

  /// Returns the status name for a given percentage.
  ///
  /// Useful for accessibility labels and debugging.
  ///
  /// Returns: 'ok', 'warning', or 'danger'
  static String statusName(double percentage) {
    if (percentage > okThreshold) return 'ok';
    if (percentage > warningThreshold) return 'warning';
    return 'danger';
  }

  /// Returns a semantic label for TalkBack accessibility.
  ///
  /// [percentage] should be a value between 0.0 and 1.0.
  ///
  /// Example outputs:
  /// - 0.45: "Budget en bonne santé"
  /// - 0.25: "Budget à surveiller"
  /// - 0.05: "Budget critique"
  static String accessibilityLabel(double percentage) {
    if (percentage > okThreshold) return 'Budget en bonne santé';
    if (percentage > warningThreshold) return 'Budget à surveiller';
    return 'Budget critique';
  }
}
