import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/subscription_frequency.dart';
import '../../domain/models/subscription_model.dart';

/// State for the subscription form.
///
/// Tracks all fields needed to create or edit a subscription.
/// All amounts are in FCFA (integer only, never double).
class SubscriptionFormState {
  /// Creates a new SubscriptionFormState.
  const SubscriptionFormState({
    this.name = '',
    this.amountFcfa = 0,
    this.category,
    this.frequency = SubscriptionFrequency.monthly,
    this.dueDay = 1,
    this.isActive = true,
    this.hasInteracted = false,
    this.editingId,
  });

  /// Subscription name.
  final String name;

  /// Amount in FCFA (integer only).
  final int amountFcfa;

  /// Selected category, or null if none selected.
  final String? category;

  /// Payment frequency.
  final SubscriptionFrequency frequency;

  /// Day of the period when payment is due (1-31 for monthly, 1-7 for weekly).
  final int dueDay;

  /// Whether this subscription is active.
  final bool isActive;

  /// Whether the user has interacted with the form.
  final bool hasInteracted;

  /// ID of the subscription being edited, or null if creating new.
  final int? editingId;

  /// Whether this is an edit operation.
  bool get isEditing => editingId != null;

  /// Whether the form is valid for submission.
  ///
  /// A form is valid when name is not empty and amount is greater than 0.
  bool get isValid => name.trim().isNotEmpty && amountFcfa > 0;

  /// Whether to show the name error.
  bool get showNameError => hasInteracted && name.trim().isEmpty;

  /// Whether to show the amount error.
  bool get showAmountError => hasInteracted && amountFcfa == 0;

  /// Maximum due day based on frequency.
  int get maxDueDay {
    switch (frequency) {
      case SubscriptionFrequency.weekly:
        return 7;
      case SubscriptionFrequency.monthly:
      case SubscriptionFrequency.quarterly:
      case SubscriptionFrequency.biannual:
      case SubscriptionFrequency.yearly:
        return 31;
    }
  }

  /// Creates a copy with the given fields replaced.
  SubscriptionFormState copyWith({
    String? name,
    int? amountFcfa,
    String? category,
    SubscriptionFrequency? frequency,
    int? dueDay,
    bool? isActive,
    bool? hasInteracted,
    int? editingId,
    bool clearCategory = false,
    bool clearEditingId = false,
  }) {
    return SubscriptionFormState(
      name: name ?? this.name,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      category: clearCategory ? null : (category ?? this.category),
      frequency: frequency ?? this.frequency,
      dueDay: dueDay ?? this.dueDay,
      isActive: isActive ?? this.isActive,
      hasInteracted: hasInteracted ?? this.hasInteracted,
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionFormState &&
        other.name == name &&
        other.amountFcfa == amountFcfa &&
        other.category == category &&
        other.frequency == frequency &&
        other.dueDay == dueDay &&
        other.isActive == isActive &&
        other.hasInteracted == hasInteracted &&
        other.editingId == editingId;
  }

  @override
  int get hashCode => Object.hash(
        name,
        amountFcfa,
        category,
        frequency,
        dueDay,
        isActive,
        hasInteracted,
        editingId,
      );
}

/// StateNotifier for managing subscription form state.
class SubscriptionFormNotifier extends StateNotifier<SubscriptionFormState> {
  /// Creates a new SubscriptionFormNotifier with initial empty state.
  SubscriptionFormNotifier() : super(const SubscriptionFormState());

  /// Maximum allowed digits for amount (up to 999,999,999 FCFA).
  static const int _maxDigits = 9;

  /// Sets the subscription name.
  void setName(String name) {
    state = state.copyWith(name: name, hasInteracted: true);
  }

  /// Adds a digit to the current amount.
  void addDigit(String digit) {
    // Validate input is a single digit
    if (digit.length != 1 || !RegExp('[0-9]').hasMatch(digit)) {
      return;
    }

    // Check if we've reached max digits
    if (state.amountFcfa.toString().length >= _maxDigits) {
      return;
    }

    final newAmount = state.amountFcfa * 10 + int.parse(digit);
    state = state.copyWith(amountFcfa: newAmount, hasInteracted: true);
  }

  /// Removes the last digit from the current amount.
  void removeDigit() {
    if (state.amountFcfa == 0) return;

    final newAmount = state.amountFcfa ~/ 10;
    state = state.copyWith(amountFcfa: newAmount);
  }

  /// Clears the entire amount to 0.
  void clearAmount() {
    state = state.copyWith(amountFcfa: 0);
  }

  /// Sets the amount directly (used for editing).
  void setAmount(int amount) {
    state = state.copyWith(amountFcfa: amount, hasInteracted: true);
  }

  /// Sets the selected category.
  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  /// Clears the selected category.
  void clearCategory() {
    state = state.copyWith(clearCategory: true);
  }

  /// Sets the payment frequency.
  ///
  /// When frequency changes, dueDay is adjusted if it exceeds the new maximum.
  void setFrequency(SubscriptionFrequency frequency) {
    var newDueDay = state.dueDay;

    // Adjust dueDay if it exceeds the new maximum
    if (frequency == SubscriptionFrequency.weekly && newDueDay > 7) {
      newDueDay = 7;
    }

    state = state.copyWith(frequency: frequency, dueDay: newDueDay);
  }

  /// Sets the due day.
  void setDueDay(int day) {
    // Clamp to valid range
    final clampedDay = day.clamp(1, state.maxDueDay);
    state = state.copyWith(dueDay: clampedDay);
  }

  /// Sets whether the subscription is active.
  void setIsActive(bool isActive) {
    state = state.copyWith(isActive: isActive);
  }

  /// Marks the form as interacted (for validation display).
  void markInteracted() {
    state = state.copyWith(hasInteracted: true);
  }

  /// Resets the form to initial empty state.
  void reset() {
    state = const SubscriptionFormState();
  }

  /// Initializes the form with existing subscription data for editing.
  void initializeForEdit(SubscriptionModel subscription) {
    state = SubscriptionFormState(
      name: subscription.name,
      amountFcfa: subscription.amountFcfa,
      category: subscription.category,
      frequency: subscription.frequency,
      dueDay: subscription.dueDay,
      isActive: subscription.isActive,
      editingId: subscription.id,
    );
  }
}

/// Provider for the subscription form state.
///
/// Uses autoDispose so the form resets when the screen closes.
final subscriptionFormProvider = StateNotifierProvider.autoDispose<
    SubscriptionFormNotifier, SubscriptionFormState>(
  (ref) => SubscriptionFormNotifier(),
);
