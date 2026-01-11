import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/clock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/budget_colors.dart';
import '../../../../shared/utils/fcfa_formatter.dart';
import '../../../transactions/presentation/widgets/numeric_keypad.dart';
import '../../domain/models/planned_expense_model.dart';
import '../providers/planned_expense_form_provider.dart';

/// Screen for adding or editing a planned expense.
///
/// Shows a form with description, amount (numeric keypad), expected date,
/// and optional category.
class PlannedExpenseFormScreen extends ConsumerStatefulWidget {
  /// Creates a PlannedExpenseFormScreen.
  ///
  /// If [expense] is provided, the form is in edit mode.
  const PlannedExpenseFormScreen({
    this.expense,
    super.key,
  });

  /// The expense to edit (null for create mode).
  final PlannedExpenseModel? expense;

  @override
  ConsumerState<PlannedExpenseFormScreen> createState() =>
      _PlannedExpenseFormScreenState();
}

class _PlannedExpenseFormScreenState
    extends ConsumerState<PlannedExpenseFormScreen> {
  final _descriptionController = TextEditingController();
  final _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initialize form after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(plannedExpenseFormProvider.notifier);
      if (widget.expense != null) {
        notifier.initForEdit(widget.expense!);
        _descriptionController.text = widget.expense!.description;
      } else {
        // Default to tomorrow's date for new planned expenses
        final clock = ref.read(clockProvider);
        final tomorrow = clock.now().add(const Duration(days: 1));
        notifier.initForCreate(defaultDate: tomorrow);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(plannedExpenseFormProvider);
    final isEditing = widget.expense != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la dépense' : 'Nouvelle dépense prévue'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Description field
                  _DescriptionField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocusNode,
                    onChanged: (value) {
                      ref
                          .read(plannedExpenseFormProvider.notifier)
                          .setDescription(value);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Amount display
                  _AmountDisplay(amount: formState.amountFcfa),
                  const SizedBox(height: AppSpacing.md),

                  // Expected date picker
                  _DatePicker(
                    selectedDate: formState.expectedDate,
                    onDateSelected: (date) {
                      ref
                          .read(plannedExpenseFormProvider.notifier)
                          .setExpectedDate(date);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Days until due indicator
                  if (formState.expectedDate != null)
                    _DaysUntilDueIndicator(
                      expectedDate: formState.expectedDate!,
                    ),

                  // Error message
                  if (formState.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      formState.errorMessage!,
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Numeric keypad and submit button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumericKeypad(
                    onDigitPressed: (digit) {
                      ref
                          .read(plannedExpenseFormProvider.notifier)
                          .appendDigit(int.parse(digit));
                    },
                    onBackspacePressed: ref
                        .read(plannedExpenseFormProvider.notifier)
                        .deleteDigit,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: formState.isValid && !formState.isSaving
                            ? _onSubmit
                            : null,
                        child: formState.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : Text(isEditing ? 'Modifier' : 'Ajouter'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final clock = ref.read(clockProvider);
    final success = await ref
        .read(plannedExpenseFormProvider.notifier)
        .save(clock.now());

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

/// Text field for description.
class _DescriptionField extends StatelessWidget {
  const _DescriptionField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Ex: Nouveau téléphone, Réparation voiture...',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
      maxLength: 200,
    );
  }
}

/// Display for the amount with FCFA formatting.
class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Montant',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            FcfaFormatter.format(amount),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Date picker for expected date.
class _DatePicker extends ConsumerWidget {
  const _DatePicker({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final now = clock.now();
    final dateFormat = DateFormat('EEEE d MMMM yyyy', 'fr_FR');

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? now.add(const Duration(days: 1)),
          firstDate: now, // Can't select past dates
          lastDate: now.add(const Duration(days: 365)), // Max 1 year ahead
          locale: const Locale('fr', 'FR'),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date prévue',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? dateFormat.format(selectedDate!)
                        : 'Sélectionner une date',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: selectedDate != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                      color: selectedDate != null
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicator showing days until the expense is due.
class _DaysUntilDueIndicator extends ConsumerWidget {
  const _DaysUntilDueIndicator({required this.expectedDate});

  final DateTime expectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clock = ref.watch(clockProvider);
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      expectedDate.year,
      expectedDate.month,
      expectedDate.day,
    );
    final daysUntil = dueDate.difference(today).inDays;

    String message;
    Color color;
    IconData icon;

    if (daysUntil == 0) {
      message = 'Prévu pour aujourd\'hui';
      color = BudgetColors.warning;
      icon = Icons.today;
    } else if (daysUntil == 1) {
      message = 'Prévu pour demain';
      color = BudgetColors.warning;
      icon = Icons.schedule;
    } else if (daysUntil < 0) {
      message = 'Date passée';
      color = AppColors.error;
      icon = Icons.error_outline;
    } else if (daysUntil <= 7) {
      message = 'Dans $daysUntil jours';
      color = BudgetColors.warning;
      icon = Icons.schedule;
    } else {
      message = 'Dans $daysUntil jours';
      color = AppColors.primary;
      icon = Icons.event;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
