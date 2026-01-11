import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/budget_colors.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../domain/models/planned_expense_model.dart';
import '../../domain/models/planned_expense_status.dart';

/// A list tile displaying planned expense information.
///
/// Shows description, amount, expected date, and days until due.
/// Completed expenses are displayed with reduced opacity.
class PlannedExpenseTile extends ConsumerWidget {
  /// Creates a PlannedExpenseTile.
  const PlannedExpenseTile({
    required this.expense,
    this.onTap,
    this.onMarkAsPaid,
    this.onCancel,
    super.key,
  });

  /// The planned expense to display.
  final PlannedExpenseModel expense;

  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  /// Callback when "Mark as paid" is tapped.
  final VoidCallback? onMarkAsPaid;

  /// Callback when "Cancel" is tapped.
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final now = clock.now();
    final daysUntil = expense.daysUntilDue(now);
    final isCompleted = !expense.isPending;

    return Opacity(
      opacity: isCompleted ? 0.5 : 1.0,
      child: ListTile(
        onTap: onTap,
        leading: _LeadingIcon(
          expense: expense,
          daysUntil: daysUntil,
          isCompleted: isCompleted,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                expense.description,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCompleted)
              _StatusBadge(status: expense.status),
          ],
        ),
        subtitle: _DaysUntilLabel(
          daysUntil: daysUntil,
          isCompleted: isCompleted,
          status: expense.status,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              FcfaFormatter.format(expense.amountFcfa),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCompleted
                    ? AppColors.onSurfaceVariant
                    : AppColors.onSurface,
              ),
            ),
            if (expense.isPending && (onMarkAsPaid != null || onCancel != null))
              _ActionButtons(
                onMarkAsPaid: onMarkAsPaid,
                onCancel: onCancel,
              ),
          ],
        ),
      ),
    );
  }
}

/// Leading icon with color based on urgency.
class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.expense,
    required this.daysUntil,
    required this.isCompleted,
  });

  final PlannedExpenseModel expense;
  final int daysUntil;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;

    if (isCompleted) {
      backgroundColor = AppColors.outlineVariant;
      iconColor = AppColors.onSurfaceVariant;
      icon = expense.isConverted ? Icons.check_circle : Icons.cancel;
    } else if (daysUntil < 0) {
      // Overdue
      backgroundColor = AppColors.error.withValues(alpha: 0.1);
      iconColor = AppColors.error;
      icon = Icons.warning;
    } else if (daysUntil <= 3) {
      // Soon (within 3 days)
      backgroundColor = BudgetColors.warning.withValues(alpha: 0.1);
      iconColor = BudgetColors.warning;
      icon = Icons.schedule;
    } else {
      // Normal
      backgroundColor = AppColors.primary.withValues(alpha: 0.1);
      iconColor = AppColors.primary;
      icon = Icons.event;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}

/// Status badge for completed expenses.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PlannedExpenseStatus status;

  @override
  Widget build(BuildContext context) {
    final isConverted = status == PlannedExpenseStatus.converted;

    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: isConverted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          color: isConverted ? AppColors.success : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Label showing days until due.
class _DaysUntilLabel extends StatelessWidget {
  const _DaysUntilLabel({
    required this.daysUntil,
    required this.isCompleted,
    required this.status,
  });

  final int daysUntil;
  final bool isCompleted;
  final PlannedExpenseStatus status;

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (isCompleted) {
      text = status == PlannedExpenseStatus.converted
          ? 'Payé'
          : 'Annulé';
      color = AppColors.onSurfaceVariant;
    } else if (daysUntil < 0) {
      text = 'En retard de ${-daysUntil} jour${-daysUntil > 1 ? 's' : ''}';
      color = AppColors.error;
    } else if (daysUntil == 0) {
      text = 'Aujourd\'hui';
      color = BudgetColors.warning;
    } else if (daysUntil == 1) {
      text = 'Demain';
      color = BudgetColors.warning;
    } else if (daysUntil <= 7) {
      text = 'Dans $daysUntil jours';
      color = BudgetColors.warning;
    } else {
      text = 'Dans $daysUntil jours';
      color = AppColors.onSurfaceVariant;
    }

    return Text(
      text,
      style: TextStyle(color: color),
    );
  }
}

/// Action buttons for pending expenses.
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    this.onMarkAsPaid,
    this.onCancel,
  });

  final VoidCallback? onMarkAsPaid;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onMarkAsPaid != null)
          IconButton(
            onPressed: onMarkAsPaid,
            icon: const Icon(Icons.check_circle_outline),
            iconSize: 20,
            color: AppColors.success,
            tooltip: 'Marquer comme payé',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        if (onCancel != null)
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined),
            iconSize: 20,
            color: AppColors.error,
            tooltip: 'Annuler',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
      ],
    );
  }
}
