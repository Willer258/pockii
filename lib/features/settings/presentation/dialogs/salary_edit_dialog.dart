import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Dialog for entering monthly salary.
class SalaryEditDialog extends StatefulWidget {
  const SalaryEditDialog({
    required this.currentSalary,
    super.key,
  });

  final int currentSalary;

  /// Show the dialog and return the new salary, or null if cancelled.
  static Future<int?> show(BuildContext context, int currentSalary) {
    return showDialog<int>(
      context: context,
      builder: (context) => SalaryEditDialog(currentSalary: currentSalary),
    );
  }

  @override
  State<SalaryEditDialog> createState() => _SalaryEditDialogState();
}

class _SalaryEditDialogState extends State<SalaryEditDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentSalary > 0 ? widget.currentSalary.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salaire mensuel'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entre ton salaire mensuel pour calculer ton objectif de fonds d\'urgence.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Salaire (FCFA)',
              hintText: 'Ex: 250000',
              suffixText: 'FCFA',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final salary = int.tryParse(_controller.text) ?? 0;
            Navigator.of(context).pop(salary);
          },
          child: const Text('Valider'),
        ),
      ],
    );
  }
}
