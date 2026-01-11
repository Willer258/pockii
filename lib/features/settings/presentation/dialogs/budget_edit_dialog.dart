import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';

/// Dialog for editing the monthly budget amount.
///
/// Displays a numeric keypad for entering the new budget amount.
/// Returns the new amount if confirmed, null if cancelled.
class BudgetEditDialog extends StatefulWidget {
  const BudgetEditDialog({
    required this.currentBudget,
    super.key,
  });

  /// Current budget amount to pre-fill.
  final int currentBudget;

  /// Shows the dialog and returns the new budget amount.
  static Future<int?> show(BuildContext context, int currentBudget) {
    return showDialog<int>(
      context: context,
      builder: (context) => BudgetEditDialog(currentBudget: currentBudget),
    );
  }

  @override
  State<BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<BudgetEditDialog> {
  late int _amount;
  bool _hasEdited = false;

  @override
  void initState() {
    super.initState();
    _amount = widget.currentBudget;
  }

  void _appendDigit(int digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (!_hasEdited) {
        _amount = digit;
        _hasEdited = true;
      } else if (_amount.toString().length < 9) {
        _amount = _amount * 10 + digit;
      }
    });
  }

  void _deleteDigit() {
    HapticFeedback.selectionClick();
    setState(() {
      _amount = _amount ~/ 10;
      _hasEdited = true;
    });
  }

  void _confirm() {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le budget doit être supérieur à 0')),
      );
      return;
    }
    Navigator.of(context).pop(_amount);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le budget'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current vs new budget
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Nouveau budget mensuel',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    FcfaFormatter.format(_amount),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_amount != widget.currentBudget) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Actuellement: ${FcfaFormatter.format(widget.currentBudget)}',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Note about mid-month changes
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      'Le nouveau budget sera appliqué au mois en cours.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Numeric keypad
            _NumericKeypad(
              onDigitPressed: _appendDigit,
              onDeletePressed: _deleteDigit,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _amount > 0 ? _confirm : null,
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Numeric keypad for budget input.
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
