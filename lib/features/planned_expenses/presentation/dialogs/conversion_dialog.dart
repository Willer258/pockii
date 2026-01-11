import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../domain/models/planned_expense_model.dart';

/// Result of the conversion dialog.
class ConversionDialogResult {
  const ConversionDialogResult({
    required this.confirmed,
    required this.adjustedAmount,
  });

  /// Whether the user confirmed the conversion.
  final bool confirmed;

  /// The adjusted amount (may differ from original).
  final int adjustedAmount;
}

/// Dialog for confirming planned expense conversion with amount adjustment.
///
/// Allows users to adjust the actual amount paid before converting
/// the planned expense to a transaction.
///
/// Returns [ConversionDialogResult] with confirmed=true and the adjusted amount,
/// or confirmed=false if cancelled.
class ConversionDialog extends StatefulWidget {
  const ConversionDialog({
    required this.expense,
    super.key,
  });

  /// The planned expense to convert.
  final PlannedExpenseModel expense;

  /// Shows the conversion dialog and returns the result.
  static Future<ConversionDialogResult?> show(
    BuildContext context,
    PlannedExpenseModel expense,
  ) {
    return showDialog<ConversionDialogResult>(
      context: context,
      builder: (context) => ConversionDialog(expense: expense),
    );
  }

  @override
  State<ConversionDialog> createState() => _ConversionDialogState();
}

class _ConversionDialogState extends State<ConversionDialog> {
  late int _adjustedAmount;
  bool _isAdjusting = false;

  @override
  void initState() {
    super.initState();
    _adjustedAmount = widget.expense.amountFcfa;
  }

  void _appendDigit(int digit) {
    HapticFeedback.selectionClick();
    setState(() {
      // Cap at 9 digits (max 999,999,999)
      if (_adjustedAmount.toString().length < 9) {
        _adjustedAmount = _adjustedAmount * 10 + digit;
      }
    });
  }

  void _deleteDigit() {
    HapticFeedback.selectionClick();
    setState(() {
      _adjustedAmount = _adjustedAmount ~/ 10;
    });
  }

  void _toggleAdjusting() {
    setState(() {
      _isAdjusting = !_isAdjusting;
      if (_isAdjusting) {
        // Reset to 0 when entering adjustment mode
        _adjustedAmount = 0;
      } else {
        // Restore original amount when cancelling
        _adjustedAmount = widget.expense.amountFcfa;
      }
    });
  }

  void _confirm() {
    if (_adjustedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide')),
      );
      return;
    }
    Navigator.of(context).pop(
      ConversionDialogResult(
        confirmed: true,
        adjustedAmount: _adjustedAmount,
      ),
    );
  }

  void _cancel() {
    Navigator.of(context).pop(
      ConversionDialogResult(
        confirmed: false,
        adjustedAmount: _adjustedAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountDifference = _adjustedAmount - widget.expense.amountFcfa;
    final hasAdjustment = amountDifference != 0;

    return AlertDialog(
      title: const Text('Marquer comme payé'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Expense description
            Text(
              widget.expense.description,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount display
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _isAdjusting ? 'Montant ajusté' : 'Montant prévu',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    FcfaFormatter.format(_adjustedAmount),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (hasAdjustment) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Prévu: ${FcfaFormatter.format(widget.expense.amountFcfa)}',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      amountDifference > 0
                          ? '+${FcfaFormatter.format(amountDifference)}'
                          : FcfaFormatter.format(amountDifference),
                      style: TextStyle(
                        color: amountDifference > 0
                            ? AppColors.error
                            : AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Adjust button
            if (!_isAdjusting)
              TextButton.icon(
                onPressed: _toggleAdjusting,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Ajuster le montant'),
              ),

            // Numeric keypad for adjustment
            if (_isAdjusting) ...[
              const SizedBox(height: AppSpacing.sm),
              _NumericKeypad(
                onDigitPressed: _appendDigit,
                onDeletePressed: _deleteDigit,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _toggleAdjusting,
                child: const Text('Utiliser le montant prévu'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _adjustedAmount > 0 ? _confirm : null,
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}

/// Simple numeric keypad for amount adjustment.
class _NumericKeypad extends StatelessWidget {
  const _NumericKeypad({
    required this.onDigitPressed,
    required this.onDeletePressed,
  });

  final ValueChanged<int> onDigitPressed;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow([1, 2, 3]),
        const SizedBox(height: AppSpacing.xs),
        _buildRow([4, 5, 6]),
        const SizedBox(height: AppSpacing.xs),
        _buildRow([7, 8, 9]),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEmptyKey(),
            _buildDigitKey(0),
            _buildDeleteKey(),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<int> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map(_buildDigitKey).toList(),
    );
  }

  Widget _buildDigitKey(int digit) {
    return SizedBox(
      width: 56,
      height: 48,
      child: TextButton(
        onPressed: () => onDigitPressed(digit),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          digit.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey() {
    return SizedBox(
      width: 56,
      height: 48,
      child: TextButton(
        onPressed: onDeletePressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Icon(Icons.backspace_outlined, size: 22),
      ),
    );
  }

  Widget _buildEmptyKey() {
    return const SizedBox(width: 56, height: 48);
  }
}
