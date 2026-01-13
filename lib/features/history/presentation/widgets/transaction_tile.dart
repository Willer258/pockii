import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../transactions/domain/models/transaction_model.dart';
import '../../../transactions/domain/models/transaction_type.dart';

/// Widget displaying a single transaction in the history list.
///
/// Shows category icon, label/note, time, and amount.
/// Income amounts display in green (AppColors.success), expenses in default color.
/// Supports swipe-to-edit (right swipe) and swipe-to-delete (left swipe).
/// Expandable to show full transaction details.
class TransactionTile extends StatefulWidget {
  /// Creates a TransactionTile.
  const TransactionTile({
    required this.transaction,
    this.onEdit,
    this.onDelete,
    this.expandable = true,
    super.key,
  });

  /// The transaction to display.
  final TransactionModel transaction;

  /// Callback when swipe-to-edit is triggered.
  final VoidCallback? onEdit;

  /// Callback when swipe-to-delete is triggered.
  final VoidCallback? onDelete;

  /// Whether the tile can be expanded to show details.
  final bool expandable;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isIncome = transaction.type == TransactionType.income;
    final categoryData = _getCategoryData(transaction.category, isIncome);

    // Format amount with +/- prefix
    final amountText = isIncome
        ? '+${FcfaFormatter.formatCompact(transaction.amountFcfa)}'
        : '-${FcfaFormatter.formatCompact(transaction.amountFcfa)}';

    // Format time as HH:mm
    final timeText = '${transaction.date.hour.toString().padLeft(2, '0')}:'
        '${transaction.date.minute.toString().padLeft(2, '0')}';

    final content = Column(
      children: [
        // Main tile content
        ListTile(
          onTap: widget.expandable
              ? () => setState(() => _isExpanded = !_isExpanded)
              : null,
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amountText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isIncome ? AppColors.success : AppColors.onSurface,
                    ),
              ),
              if (widget.expandable) ...[
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Expandable details section
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedDetails(
            context,
            transaction,
            categoryData,
            isIncome,
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );

    // If no swipe actions, return content directly
    if (widget.onEdit == null && widget.onDelete == null) {
      return content;
    }

    // Wrap in Dismissible for swipe actions
    return Dismissible(
      key: ValueKey(transaction.id),
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && widget.onEdit != null) {
          widget.onEdit!();
          return false; // Don't dismiss, just trigger edit
        } else if (direction == DismissDirection.endToStart &&
            widget.onDelete != null) {
          widget.onDelete!();
          return false; // Don't dismiss, let parent handle delete
        }
        return false;
      },
      child: content,
    );
  }

  /// Builds the expanded details section.
  Widget _buildExpandedDetails(
    BuildContext context,
    TransactionModel transaction,
    _CategoryDisplayData categoryData,
    bool isIncome,
  ) {
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
    final fullDate = dateFormat.format(transaction.date);

    return Container(
      padding: const EdgeInsets.only(
        left: 72, // Align with title (48 icon + 24 padding)
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full date
          _DetailRow(
            icon: Icons.calendar_today,
            label: 'Date',
            value: fullDate,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Category
          _DetailRow(
            icon: categoryData.icon,
            label: 'Catégorie',
            value: categoryData.label,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Full amount
          _DetailRow(
            icon: isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            label: 'Montant',
            value: FcfaFormatter.format(transaction.amountFcfa),
            valueColor: isIncome ? AppColors.success : null,
          ),
          // Note (if exists and different from title)
          if (transaction.note?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.sm),
            _DetailRow(
              icon: Icons.notes,
              label: 'Note',
              value: transaction.note!,
            ),
          ],
          // Type
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            icon: isIncome ? Icons.add_circle : Icons.remove_circle,
            label: 'Type',
            value: isIncome ? 'Revenu' : 'Dépense',
          ),
        ],
      ),
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

/// Widget for displaying a detail row in the expanded section.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? AppColors.onSurface,
                ),
          ),
        ),
      ],
    );
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
