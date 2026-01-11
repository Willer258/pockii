import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/services/clock_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../home/presentation/providers/budget_provider.dart';
import '../../../streaks/domain/services/streak_service.dart';
import '../../../streaks/presentation/providers/streak_provider.dart';
import '../../../streaks/presentation/widgets/milestone_celebration_dialog.dart';
import '../../data/transaction_repository.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/transaction_type.dart';
import '../providers/transaction_form_provider.dart';
import 'amount_display.dart';
import 'category_chip_row.dart';
import 'numeric_keypad.dart';

/// A bottom sheet for adding or editing a transaction (expense or income).
///
/// Provides a quick 3-tap flow: FAB → Amount+Category → Submit.
/// Supports toggling between expense and income modes.
/// In edit mode, pre-fills with existing transaction data.
/// The form auto-disposes when closed, resetting state automatically.
class TransactionBottomSheet extends ConsumerStatefulWidget {
  /// Creates a TransactionBottomSheet.
  ///
  /// If [editTransaction] is provided, the sheet opens in edit mode
  /// with pre-filled data.
  const TransactionBottomSheet({
    this.editTransaction,
    super.key,
  });

  /// The transaction to edit, if in edit mode.
  final TransactionModel? editTransaction;

  /// Whether this sheet is in edit mode.
  bool get isEditMode => editTransaction != null;

  /// Shows the transaction bottom sheet for adding a new transaction.
  ///
  /// Returns when the sheet is dismissed.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const TransactionBottomSheet(),
    );
  }

  /// Shows the transaction bottom sheet for editing an existing transaction.
  ///
  /// Returns when the sheet is dismissed.
  static Future<void> showEdit(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TransactionBottomSheet(editTransaction: transaction),
    );
  }

  @override
  ConsumerState<TransactionBottomSheet> createState() =>
      _TransactionBottomSheetState();
}

class _TransactionBottomSheetState
    extends ConsumerState<TransactionBottomSheet> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // In edit mode, pre-fill the form with existing transaction data
    if (widget.isEditMode) {
      final tx = widget.editTransaction!;
      _noteController.text = tx.note ?? '';
      _selectedDate = tx.date;

      // Initialize the form provider with existing data after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formNotifier = ref.read(transactionFormProvider.notifier);
        formNotifier.initializeForEdit(
          amountFcfa: tx.amountFcfa,
          category: tx.category,
          type: tx.type,
          note: tx.note,
        );
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    final formState = ref.read(transactionFormProvider);
    if (!formState.isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current date via clockProvider (ARCH-6)
      final clock = ref.read(clockProvider);
      final now = clock.now();

      // Default category to 'other' if not selected
      final category = formState.category ?? 'other';

      // Use selected date if set (for backdating), otherwise current time
      final transactionDate = _selectedDate ?? now;

      final repository = ref.read(transactionRepositoryProvider);

      StreakResult? streakResult;

      if (widget.isEditMode) {
        // Update existing transaction
        final updatedTransaction = widget.editTransaction!.copyWith(
          amountFcfa: formState.amountFcfa,
          category: category,
          type: formState.transactionType,
          note: formState.note,
          date: transactionDate,
        );
        await repository.updateTransaction(updatedTransaction);
      } else {
        // Create new transaction
        await repository.createTransaction(
          amountFcfa: formState.amountFcfa,
          category: category,
          type: formState.transactionType,
          note: formState.note,
          date: transactionDate,
        );

        // Record streak activity for new transactions (FR52)
        final streakService = ref.read(streakRecorderProvider);
        streakResult = await streakService.recordTransactionActivity();

        // Invalidate streak provider to refresh UI
        ref.invalidate(streakStatusProvider);
      }

      // Refresh budget to reflect changes (NFR2: <100ms)
      await ref.read(budgetStateProvider.notifier).refresh();

      // Haptic feedback on success (UX-12)
      await HapticFeedback.mediumImpact();

      // Close bottom sheet
      if (mounted) {
        Navigator.of(context).pop();

        // Show success snackbar with appropriate message
        final String message;
        if (widget.isEditMode) {
          message = 'Transaction modifiée';
        } else {
          message = formState.isIncome ? 'Revenu ajouté' : 'Dépense ajoutée';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show milestone celebration if reached (FR54)
        if (streakResult != null &&
            streakResult.isNewMilestone &&
            streakResult.milestoneReached != null) {
          // Small delay to let the snackbar appear first
          await Future<void>.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await MilestoneCelebrationDialog.show(
              context,
              milestone: streakResult.milestoneReached!,
              currentStreak: streakResult.currentStreak,
            );
          }
        }
      }
    } on AppException catch (e) {
      // Show error snackbar for app-specific exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.message}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Opens a date picker for backdating the transaction.
  Future<void> _selectDate() async {
    final clock = ref.read(clockProvider);
    final now = clock.now();

    // Allow backdating only within the current month
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDayOfMonth,
      lastDate: now,
      helpText: 'Sélectionner une date',
      cancelText: 'Annuler',
      confirmText: 'OK',
    );

    if (picked != null) {
      setState(() {
        // Preserve the time from the original date or use current time
        final time = _selectedDate ?? now;
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(transactionFormProvider);
    final formNotifier = ref.read(transactionFormProvider.notifier);
    final isEditMode = widget.isEditMode;

    // Format selected date for display
    final dateFormat = DateFormat('dd/MM/yyyy');
    final displayDate = _selectedDate != null
        ? dateFormat.format(_selectedDate!)
        : "Aujourd'hui";

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title with animated transition
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    isEditMode
                        ? (formState.isIncome
                            ? 'Modifier le revenu'
                            : 'Modifier la dépense')
                        : (formState.isIncome
                            ? 'Nouveau revenu'
                            : 'Nouvelle dépense'),
                    key: ValueKey('${formState.transactionType}_$isEditMode'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),

              // Transaction type toggle (expense/income)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Dépense'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Revenu'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  selected: {formState.transactionType},
                  onSelectionChanged: (selected) {
                    HapticFeedback.selectionClick();
                    formNotifier.setTransactionType(selected.first);
                  },
                  showSelectedIcon: false,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Amount display with validation
              AmountDisplay(
                amountFcfa: formState.amountFcfa,
                showError: formState.showAmountError,
                errorMessage: 'Montant requis',
              ),

              const SizedBox(height: AppSpacing.md),

              // Category chips (different categories for expense vs income)
              CategoryChipRow(
                selectedCategory: formState.category,
                onCategorySelected: formNotifier.setCategory,
                isIncome: formState.isIncome,
              ),

              const SizedBox(height: AppSpacing.md),

              // Note field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optionnel)',
                    hintText: 'Ajouter un commentaire...',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 200,
                  textInputAction: TextInputAction.done,
                  onChanged: formNotifier.setNote,
                ),
              ),

              // Date picker (for backdating)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    'Date: $displayDate',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Numeric keypad
              NumericKeypad(
                onDigitPressed: formNotifier.addDigit,
                onBackspacePressed: formNotifier.removeDigit,
              ),

              const SizedBox(height: AppSpacing.md),

              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: FilledButton(
                  onPressed: formState.isValid && !_isSubmitting
                      ? _handleSubmit
                      : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSpacing.touchTarget),
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.outlineVariant,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Text(
                          isEditMode ? 'Modifier' : 'Ajouter',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
