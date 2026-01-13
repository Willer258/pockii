import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/planned_expense_repository.dart';
import '../../domain/models/planned_expense_model.dart';

/// State for the planned expense form.
class PlannedExpenseFormState {
  const PlannedExpenseFormState({
    this.description = '',
    this.amountFcfa = 0,
    this.expectedDate,
    this.category,
    this.isEditing = false,
    this.editingId,
    this.isSaving = false,
    this.errorMessage,
  });

  /// Description of the planned expense.
  final String description;

  /// Amount in FCFA (integer only).
  final int amountFcfa;

  /// Expected date when the expense will occur.
  final DateTime? expectedDate;

  /// Optional category for the expense.
  final String? category;

  /// Whether we are editing an existing expense.
  final bool isEditing;

  /// ID of the expense being edited (if editing).
  final int? editingId;

  /// Whether a save operation is in progress.
  final bool isSaving;

  /// Error message if validation or save failed.
  final String? errorMessage;

  /// Whether the form is valid for submission.
  bool get isValid =>
      description.trim().isNotEmpty &&
      amountFcfa > 0 &&
      expectedDate != null;

  /// Creates a copy of this state with the given fields replaced.
  PlannedExpenseFormState copyWith({
    String? description,
    int? amountFcfa,
    DateTime? expectedDate,
    String? category,
    bool? isEditing,
    int? editingId,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
    bool clearCategory = false,
  }) {
    return PlannedExpenseFormState(
      description: description ?? this.description,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      expectedDate: expectedDate ?? this.expectedDate,
      category: clearCategory ? null : (category ?? this.category),
      isEditing: isEditing ?? this.isEditing,
      editingId: editingId ?? this.editingId,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier for managing planned expense form state.
class PlannedExpenseFormNotifier extends StateNotifier<PlannedExpenseFormState> {
  PlannedExpenseFormNotifier(this._repository)
      : super(const PlannedExpenseFormState());

  final PlannedExpenseRepository _repository;

  /// Initializes the form for editing an existing planned expense.
  void initForEdit(PlannedExpenseModel expense) {
    state = PlannedExpenseFormState(
      description: expense.description,
      amountFcfa: expense.amountFcfa,
      expectedDate: expense.expectedDate,
      category: expense.category,
      isEditing: true,
      editingId: expense.id,
    );
  }

  /// Initializes the form for creating a new planned expense.
  void initForCreate({DateTime? defaultDate}) {
    state = PlannedExpenseFormState(
      expectedDate: defaultDate,
    );
  }

  /// Resets the form to its initial state.
  void reset() {
    state = const PlannedExpenseFormState();
  }

  /// Sets the description.
  void setDescription(String value) {
    state = state.copyWith(description: value, clearError: true);
  }

  /// Appends a digit to the amount.
  void appendDigit(int digit) {
    if (digit < 0 || digit > 9) return;

    // Limit to 9 digits (max 999,999,999 FCFA)
    if (state.amountFcfa >= 100000000) return;

    final newAmount = state.amountFcfa * 10 + digit;
    state = state.copyWith(amountFcfa: newAmount, clearError: true);
  }

  /// Deletes the last digit from the amount.
  void deleteDigit() {
    final newAmount = state.amountFcfa ~/ 10;
    state = state.copyWith(amountFcfa: newAmount, clearError: true);
  }

  /// Clears the amount to 0.
  void clearAmount() {
    state = state.copyWith(amountFcfa: 0, clearError: true);
  }

  /// Sets the amount directly (used with system keyboard).
  void setAmount(int amount) {
    state = state.copyWith(amountFcfa: amount, clearError: true);
  }

  /// Sets the expected date.
  void setExpectedDate(DateTime date) {
    state = state.copyWith(expectedDate: date, clearError: true);
  }

  /// Sets the category.
  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true, clearError: true);
    } else {
      state = state.copyWith(category: category, clearError: true);
    }
  }

  /// Validates the form for submission.
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validate(DateTime now) {
    if (state.description.trim().isEmpty) {
      return 'Description requise';
    }
    if (state.amountFcfa <= 0) {
      return 'Montant requis';
    }
    if (state.expectedDate == null) {
      return 'Date requise';
    }

    // Validate that date is today or in the future
    final today = DateTime(now.year, now.month, now.day);
    final expectedDay = DateTime(
      state.expectedDate!.year,
      state.expectedDate!.month,
      state.expectedDate!.day,
    );
    if (expectedDay.isBefore(today)) {
      return 'La date doit être aujourd\'hui ou plus tard';
    }

    return null;
  }

  /// Saves the planned expense (creates or updates).
  ///
  /// Returns true if successful, false otherwise.
  Future<bool> save(DateTime now) async {
    final error = validate(now);
    if (error != null) {
      state = state.copyWith(errorMessage: error);
      return false;
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      if (state.isEditing && state.editingId != null) {
        // Update existing
        final existing = await _repository.getPlannedExpenseById(state.editingId!);
        if (existing == null) {
          state = state.copyWith(
            isSaving: false,
            errorMessage: 'Dépense non trouvée',
          );
          return false;
        }

        final updated = existing.copyWith(
          description: state.description.trim(),
          amountFcfa: state.amountFcfa,
          expectedDate: state.expectedDate,
          category: state.category,
          updatedAt: now,
        );
        await _repository.updatePlannedExpense(updated);
      } else {
        // Create new
        await _repository.createPlannedExpense(
          description: state.description.trim(),
          amountFcfa: state.amountFcfa,
          expectedDate: state.expectedDate!,
          category: state.category,
        );
      }

      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erreur lors de l\'enregistrement',
      );
      return false;
    }
  }
}

/// Provider for PlannedExpenseFormNotifier.
final plannedExpenseFormProvider =
    StateNotifierProvider.autoDispose<PlannedExpenseFormNotifier, PlannedExpenseFormState>(
  (ref) {
    final repository = ref.watch(plannedExpenseRepositoryProvider);
    return PlannedExpenseFormNotifier(repository);
  },
);
