import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/domain/models/transaction_type.dart';

/// Widget displaying a single transaction in the history list.
///
/// Shows category icon, label/note, time, and amount.
/// Income amounts display in green (AppColors.success), expenses in default color.
/// Supports swipe-to-edit (right swipe) and swipe-to-delete (left swipe).
class TransactionTile extends StatelessWidget {
  /// Creates a TransactionTile.
  const TransactionTile({
    required this.transaction,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  /// The transaction to display.
  final TransactionModel transaction;

  /// Callback when swipe-to-edit is triggered.
  final VoidCallback? onEdit;

  /// Callback when swipe-to-delete is triggered.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final categoryData = _getCategoryData(transaction.category, isIncome);

    // Format amount with +/- prefix
    final amountText = isIncome
        ? '+${FcfaFormatter.formatCompact(transaction.amountFcfa)}'
        : '-${FcfaFormatter.formatCompact(transaction.amountFcfa)}';

    // Format time as HH:mm
    final timeText = '${transaction.date.hour.toString().padLeft(2, '0')}:'
        '${transaction.date.minute.toString().padLeft(2, '0')}';

    final listTile = ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: categoryData.color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          categoryData.icon,
          color: categoryData.color,
          size: 24,
        ),
      ),
      title: Text(
        (transaction.note?.isNotEmpty ?? false)
            ? transaction.note!
            : categoryData.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        timeText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      trailing: Text(
        amountText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isIncome ? AppColors.success : AppColors.onSurface,
            ),
      ),
    );

    // If no swipe actions, return plain ListTile
    if (onEdit == null && onDelete == null) {
      return listTile;
    }

    // Wrap in Dismissible for swipe actions
    return Dismissible(
      key: ValueKey(transaction.id),
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && onEdit != null) {
          onEdit!();
          return false; // Don't dismiss, just trigger edit
        } else if (direction == DismissDirection.endToStart &&
            onDelete != null) {
          onDelete!();
          return false; // Don't dismiss, let parent handle delete
        }
        return false;
      },
      child: listTile,
    );
  }

  /// Builds the edit action background (blue, shown on right swipe).
  Widget _buildEditBackground() {
    return Container(
      color: Colors.blue,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Icon(
        Icons.edit,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Builds the delete action background (red, shown on left swipe).
  Widget _buildDeleteBackground() {
    return Container(
      color: AppColors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(
        Icons.delete,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Gets category display data (icon, label, color).
  _CategoryDisplayData _getCategoryData(String categoryId, bool isIncome) {
    if (isIncome) {
      return _incomeCategoryMap[categoryId] ?? _defaultIncomeCategory;
    }
    return _expenseCategoryMap[categoryId] ?? _defaultExpenseCategory;
  }
}

/// Display data for a category.
class _CategoryDisplayData {
  const _CategoryDisplayData({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}

/// Expense category display mappings.
const _expenseCategoryMap = {
  'transport': _CategoryDisplayData(
    icon: Icons.directions_car,
    label: 'Transport',
    color: AppColors.primary,
  ),
  'food': _CategoryDisplayData(
    icon: Icons.restaurant,
    label: 'Repas',
    color: Colors.orange,
  ),
  'leisure': _CategoryDisplayData(
    icon: Icons.celebration,
    label: 'Loisirs',
    color: Colors.purple,
  ),
  'family': _CategoryDisplayData(
    icon: Icons.family_restroom,
    label: 'Famille',
    color: Colors.pink,
  ),
  'subscriptions': _CategoryDisplayData(
    icon: Icons.credit_card,
    label: 'Abonnements',
    color: Colors.blue,
  ),
  'other': _CategoryDisplayData(
    icon: Icons.inventory_2,
    label: 'Autre',
    color: Colors.grey,
  ),
};

/// Income category display mappings.
const _incomeCategoryMap = {
  'salary': _CategoryDisplayData(
    icon: Icons.account_balance_wallet,
    label: 'Salaire',
    color: AppColors.success,
  ),
  'freelance': _CategoryDisplayData(
    icon: Icons.laptop_mac,
    label: 'Freelance',
    color: AppColors.success,
  ),
  'reimbursement': _CategoryDisplayData(
    icon: Icons.receipt_long,
    label: 'Remboursement',
    color: AppColors.success,
  ),
  'gift': _CategoryDisplayData(
    icon: Icons.card_giftcard,
    label: 'Cadeau',
    color: AppColors.success,
  ),
  'other': _CategoryDisplayData(
    icon: Icons.more_horiz,
    label: 'Autre',
    color: AppColors.success,
  ),
};

/// Default expense category for unknown IDs.
const _defaultExpenseCategory = _CategoryDisplayData(
  icon: Icons.inventory_2,
  label: 'Autre',
  color: Colors.grey,
);

/// Default income category for unknown IDs.
const _defaultIncomeCategory = _CategoryDisplayData(
  icon: Icons.more_horiz,
  label: 'Autre',
  color: AppColors.success,
);
