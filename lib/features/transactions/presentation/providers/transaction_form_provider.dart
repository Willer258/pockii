import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/transaction_type.dart';

/// State for the transaction form.
///
/// Tracks the amount, category, note, and type for a new transaction.
/// All amounts are in FCFA (integer only, never double).
class TransactionFormState {
  /// Creates a new TransactionFormState.
  const TransactionFormState({
    this.amountFcfa = 0,
    this.category,
    this.note,
    this.transactionType = TransactionType.expense,
    this.hasInteracted = false,
  });

  /// The amount in FCFA (integer only).
  final int amountFcfa;

  /// Selected category ID, or null if none selected.
  final String? category;

  /// Optional note for the transaction.
  final String? note;

  /// The type of transaction (expense or income).
  final TransactionType transactionType;

  /// Whether the user has interacted with the amount input.
  /// Used to determine when to show validation errors.
  final bool hasInteracted;

  /// Whether the form is valid for submission.
  ///
  /// A form is valid when the amount is greater than 0.
  bool get isValid => amountFcfa > 0;

  /// Whether this is an income transaction.
  bool get isIncome => transactionType == TransactionType.income;

  /// Whether to show the amount error.
  /// Shows error when user has interacted but amount is still 0.
  bool get showAmountError => hasInteracted && amountFcfa == 0;

  /// Creates a copy with the given fields replaced.
  TransactionFormState copyWith({
    int? amountFcfa,
    String? category,
    String? note,
    TransactionType? transactionType,
    bool? hasInteracted,
    bool clearCategory = false,
    bool clearNote = false,
  }) {
    return TransactionFormState(
      amountFcfa: amountFcfa ?? this.amountFcfa,
      category: clearCategory ? null : (category ?? this.category),
      note: clearNote ? null : (note ?? this.note),
      transactionType: transactionType ?? this.transactionType,
      hasInteracted: hasInteracted ?? this.hasInteracted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionFormState &&
        other.amountFcfa == amountFcfa &&
        other.category == category &&
        other.note == note &&
        other.transactionType == transactionType &&
        other.hasInteracted == hasInteracted;
  }

  @override
  int get hashCode =>
      Object.hash(amountFcfa, category, note, transactionType, hasInteracted);
}

/// StateNotifier for managing transaction form state.
///
/// Provides methods for modifying the amount digit by digit,
/// selecting categories, and managing the optional note.
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  /// Creates a new TransactionFormNotifier with initial empty state.
  TransactionFormNotifier() : super(const TransactionFormState());

  /// Maximum allowed digits (up to 999,999,999 FCFA).
  static const int _maxDigits = 9;

  /// Adds a digit to the current amount.
  ///
  /// The digit is appended to the end of the current amount.
  /// If adding the digit would exceed the maximum, it's ignored.
  /// Marks the form as interacted for validation purposes.
  void addDigit(String digit) {
    // Validate input is a single digit
    if (digit.length != 1 || !RegExp('[0-9]').hasMatch(digit)) {
      return;
    }

    // Check if we've reached max digits
    if (state.amountFcfa.toString().length >= _maxDigits) {
      return;
    }

    // Special case: prevent leading zeros
    final newAmount = state.amountFcfa * 10 + int.parse(digit);

    state = state.copyWith(amountFcfa: newAmount, hasInteracted: true);
  }

  /// Removes the last digit from the current amount.
  ///
  /// If the amount is already 0, nothing happens.
  /// Keeps hasInteracted true once set.
  void removeDigit() {
    if (state.amountFcfa == 0) return;

    final newAmount = state.amountFcfa ~/ 10;
    state = state.copyWith(amountFcfa: newAmount);
  }

  /// Clears the entire amount to 0.
  void clearAmount() {
    state = state.copyWith(amountFcfa: 0);
  }

  /// Sets the selected category.
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  /// Clears the selected category.
  void clearCategory() {
    state = state.copyWith(clearCategory: true);
  }

  /// Sets the optional note.
  ///
  /// If the note is empty or whitespace-only, it's stored as null.
  void setNote(String? note) {
    final trimmed = note?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      state = state.copyWith(clearNote: true);
    } else {
      state = state.copyWith(note: trimmed);
    }
  }

  /// Clears the optional note.
  void clearNote() {
    state = state.copyWith(clearNote: true);
  }

  /// Sets the transaction type (expense or income).
  ///
  /// When the type changes, the category is cleared since expense and
  /// income have different category sets. The amount is preserved.
  void setTransactionType(TransactionType type) {
    if (state.transactionType == type) return;

    state = state.copyWith(
      transactionType: type,
      clearCategory: true, // Clear category when switching types
    );
  }

  /// Resets the form to initial empty state.
  void reset() {
    state = const TransactionFormState();
  }

  /// Initializes the form with existing transaction data for editing.
  ///
  /// This is used when editing an existing transaction to pre-fill
  /// all the form fields with the current values.
  void initializeForEdit({
    required int amountFcfa,
    required String category,
    required TransactionType type,
    String? note,
  }) {
    state = TransactionFormState(
      amountFcfa: amountFcfa,
      category: category,
      transactionType: type,
      note: note,
    );
  }
}

/// Provider for the transaction form state.
///
/// Uses autoDispose so the form resets when the bottom sheet closes.
final transactionFormProvider = StateNotifierProvider.autoDispose<
    TransactionFormNotifier, TransactionFormState>(
  (ref) => TransactionFormNotifier(),
);
