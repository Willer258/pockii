import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/utils/fcfa_formatter.dart';

/// Result from emergency fund dialog.
class EmergencyFundDialogResult {
  const EmergencyFundDialogResult({
    required this.monthlySalary,
    required this.currentSavings,
    required this.targetMonths,
  });

  final int monthlySalary;
  final int currentSavings;
  final int targetMonths;
}

/// Dialog for configuring emergency fund settings.
class EmergencyFundDialog extends StatefulWidget {
  const EmergencyFundDialog({
    required this.monthlySalary,
    required this.currentSavings,
    required this.targetMonths,
    super.key,
  });

  final int monthlySalary;
  final int currentSavings;
  final int targetMonths;

  /// Show the dialog and return the updated settings, or null if cancelled.
  static Future<EmergencyFundDialogResult?> show(
    BuildContext context, {
    required int monthlySalary,
    required int currentSavings,
    required int targetMonths,
  }) {
    return showDialog<EmergencyFundDialogResult>(
      context: context,
      builder: (context) => EmergencyFundDialog(
        monthlySalary: monthlySalary,
        currentSavings: currentSavings,
        targetMonths: targetMonths,
      ),
    );
  }

  @override
  State<EmergencyFundDialog> createState() => _EmergencyFundDialogState();
}

class _EmergencyFundDialogState extends State<EmergencyFundDialog> {
  late TextEditingController _salaryController;
  late TextEditingController _savingsController;
  late int _targetMonths;

  @override
  void initState() {
    super.initState();
    _salaryController = TextEditingController(
      text: widget.monthlySalary > 0 ? widget.monthlySalary.toString() : '',
    );
    _savingsController = TextEditingController(
      text: widget.currentSavings > 0 ? widget.currentSavings.toString() : '',
    );
    _targetMonths = widget.targetMonths;
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  int get _targetAmount {
    final salary = int.tryParse(_salaryController.text) ?? 0;
    return salary * _targetMonths;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Text('🛡️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          const Expanded(child: Text('Fonds d\'urgence')),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salary field
            TextField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Salaire mensuel',
                suffixText: 'FCFA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.md),

            // Target months selector
            Text(
              'Objectif en mois',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [3, 6, 9, 12].map((months) {
                final isSelected = months == _targetMonths;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _targetMonths = months),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$months',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Current savings field
            TextField(
              controller: _savingsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Épargne actuelle',
                suffixText: 'FCFA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Target calculation
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Objectif: ${FcfaFormatter.format(_targetAmount)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(EmergencyFundDialogResult(
              monthlySalary: int.tryParse(_salaryController.text) ?? 0,
              currentSavings: int.tryParse(_savingsController.text) ?? 0,
              targetMonths: _targetMonths,
            ));
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
