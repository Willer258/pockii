import '../enums/expense_category.dart';

/// Settings for the 50/30/20 budget rule.
class BudgetRuleSettings {
  const BudgetRuleSettings({
    required this.isEnabled,
    required this.needsPercentage,
    required this.wantsPercentage,
    required this.savingsPercentage,
  });

  /// Default 50/30/20 rule settings.
  factory BudgetRuleSettings.default503020() {
    return const BudgetRuleSettings(
      isEnabled: false,
      needsPercentage: 50,
      wantsPercentage: 30,
      savingsPercentage: 20,
    );
  }

  /// Whether the budget rule is enabled.
  final bool isEnabled;

  /// Target percentage for needs (default 50%).
  final int needsPercentage;

  /// Target percentage for wants (default 30%).
  final int wantsPercentage;

  /// Target percentage for savings (default 20%).
  final int savingsPercentage;

  /// Get the target percentage for a category.
  int getTargetForCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.needs:
        return needsPercentage;
      case ExpenseCategory.wants:
        return wantsPercentage;
      case ExpenseCategory.savings:
        return savingsPercentage;
    }
  }

  BudgetRuleSettings copyWith({
    bool? isEnabled,
    int? needsPercentage,
    int? wantsPercentage,
    int? savingsPercentage,
  }) {
    return BudgetRuleSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      needsPercentage: needsPercentage ?? this.needsPercentage,
      wantsPercentage: wantsPercentage ?? this.wantsPercentage,
      savingsPercentage: savingsPercentage ?? this.savingsPercentage,
    );
  }
}

/// Calculated allocation for a single category.
class CategoryAllocation {
  const CategoryAllocation({
    required this.category,
    required this.targetAmount,
    required this.actualAmount,
    required this.targetPercentage,
  });

  final ExpenseCategory category;
  final int targetAmount;
  final int actualAmount;
  final int targetPercentage;

  /// Actual percentage of budget spent in this category.
  double get actualPercentage {
    if (targetAmount == 0) return 0;
    // Calculate based on total budget, not just target
    return (actualAmount / (targetAmount / targetPercentage * 100)) * 100;
  }

  /// Remaining amount for this category.
  int get remaining => targetAmount - actualAmount;

  /// Whether this category is over budget.
  bool get isOverBudget => actualAmount > targetAmount;

  /// Whether this category is under-utilized (good for savings).
  bool get isUnderUtilized => actualAmount < targetAmount * 0.5;

  /// Progress towards target (0.0 to 1.0+).
  double get progress {
    if (targetAmount == 0) return 0;
    return actualAmount / targetAmount;
  }
}

/// Full budget allocation breakdown.
class BudgetAllocation {
  const BudgetAllocation({
    required this.totalBudget,
    required this.needs,
    required this.wants,
    required this.savings,
    required this.settings,
  });

  /// Create from budget and spending data.
  factory BudgetAllocation.calculate({
    required int totalBudget,
    required int needsSpent,
    required int wantsSpent,
    required int savingsSpent,
    required BudgetRuleSettings settings,
  }) {
    return BudgetAllocation(
      totalBudget: totalBudget,
      needs: CategoryAllocation(
        category: ExpenseCategory.needs,
        targetAmount: (totalBudget * settings.needsPercentage / 100).round(),
        actualAmount: needsSpent,
        targetPercentage: settings.needsPercentage,
      ),
      wants: CategoryAllocation(
        category: ExpenseCategory.wants,
        targetAmount: (totalBudget * settings.wantsPercentage / 100).round(),
        actualAmount: wantsSpent,
        targetPercentage: settings.wantsPercentage,
      ),
      savings: CategoryAllocation(
        category: ExpenseCategory.savings,
        targetAmount: (totalBudget * settings.savingsPercentage / 100).round(),
        actualAmount: savingsSpent,
        targetPercentage: settings.savingsPercentage,
      ),
      settings: settings,
    );
  }

  final int totalBudget;
  final CategoryAllocation needs;
  final CategoryAllocation wants;
  final CategoryAllocation savings;
  final BudgetRuleSettings settings;

  /// Get allocation for a specific category.
  CategoryAllocation forCategory(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.needs:
        return needs;
      case ExpenseCategory.wants:
        return wants;
      case ExpenseCategory.savings:
        return savings;
    }
  }

  /// Total amount spent across all categories.
  int get totalSpent => needs.actualAmount + wants.actualAmount + savings.actualAmount;

  /// Total remaining across all categories.
  int get totalRemaining => totalBudget - totalSpent;

  /// Check if any category is over budget.
  bool get hasOverspending =>
      needs.isOverBudget || wants.isOverBudget;

  /// Get the category that needs most attention (most over budget).
  ExpenseCategory? get categoryNeedingAttention {
    if (needs.isOverBudget && needs.progress > wants.progress) {
      return ExpenseCategory.needs;
    }
    if (wants.isOverBudget) {
      return ExpenseCategory.wants;
    }
    return null;
  }
}
