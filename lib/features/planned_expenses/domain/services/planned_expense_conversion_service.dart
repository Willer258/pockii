import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/data/transaction_repository.dart';
import '../../../transactions/domain/models/transaction_type.dart';
import '../../data/planned_expense_repository.dart';
import '../models/planned_expense_model.dart';

/// Result of a planned expense conversion.
class ConversionResult {
  /// Creates a ConversionResult with all fields.
  const ConversionResult({
    required this.success,
    required this.transactionId,
    this.errorMessage,
  });

  /// Factory for successful conversion.
  const ConversionResult.success(this.transactionId)
      : success = true,
        errorMessage = null;

  /// Factory for failed conversion.
  const ConversionResult.failure(this.errorMessage)
      : success = false,
        transactionId = 0;

  /// Whether the conversion was successful.
  final bool success;

  /// ID of the created transaction (0 if failed).
  final int transactionId;

  /// Error message if conversion failed.
  final String? errorMessage;
}

/// Service for converting planned expenses to actual transactions.
///
/// Handles the conversion flow:
/// 1. Validates the planned expense exists and is pending
/// 2. Creates a new transaction with the (optionally adjusted) amount
/// 3. Marks the planned expense as converted
///
/// Covers: FR33 (convert planned expense to transaction)
class PlannedExpenseConversionService {
  PlannedExpenseConversionService({
    required PlannedExpenseRepository plannedExpenseRepository,
    required TransactionRepository transactionRepository,
  })  : _plannedExpenseRepository = plannedExpenseRepository,
        _transactionRepository = transactionRepository;

  final PlannedExpenseRepository _plannedExpenseRepository;
  final TransactionRepository _transactionRepository;

  /// Converts a planned expense to an actual transaction.
  ///
  /// [plannedExpenseId] - ID of the planned expense to convert
  /// [actualAmount] - The actual amount paid (may differ from planned amount)
  /// [transactionDate] - Date of the transaction (defaults to now)
  ///
  /// Returns a [ConversionResult] indicating success or failure.
  Future<ConversionResult> convertToTransaction({
    required int plannedExpenseId,
    required int actualAmount,
    required DateTime transactionDate,
  }) async {
    // Validate amount
    if (actualAmount <= 0) {
      return const ConversionResult.failure('Montant invalide');
    }

    // Get the planned expense
    final plannedExpense = await _plannedExpenseRepository.getPlannedExpenseById(
      plannedExpenseId,
    );

    if (plannedExpense == null) {
      return const ConversionResult.failure('Dépense prévue introuvable');
    }

    if (!plannedExpense.isPending) {
      return const ConversionResult.failure(
        'Cette dépense a déjà été convertie ou annulée',
      );
    }

    try {
      // Create the transaction
      final transactionId = await _transactionRepository.createTransaction(
        amountFcfa: actualAmount,
        category: plannedExpense.category ?? 'other',
        type: TransactionType.expense,
        date: transactionDate,
        note: plannedExpense.description,
      );

      // Mark the planned expense as converted
      final marked = await _plannedExpenseRepository.markAsConverted(
        plannedExpenseId,
      );

      if (!marked) {
        // Transaction was created but marking failed - rollback transaction
        await _transactionRepository.deleteTransaction(transactionId);
        return const ConversionResult.failure(
          'Erreur lors de la mise à jour du statut',
        );
      }

      return ConversionResult.success(transactionId);
    } catch (e) {
      return ConversionResult.failure('Erreur: $e');
    }
  }

  /// Cancels a planned expense, releasing the reserved budget.
  ///
  /// [plannedExpenseId] - ID of the planned expense to cancel
  ///
  /// Returns true if successful, false otherwise.
  ///
  /// Covers: FR34 (cancel planned expense)
  Future<bool> cancelPlannedExpense(int plannedExpenseId) async {
    final plannedExpense = await _plannedExpenseRepository.getPlannedExpenseById(
      plannedExpenseId,
    );

    if (plannedExpense == null) {
      return false;
    }

    if (!plannedExpense.isPending) {
      return false;
    }

    return _plannedExpenseRepository.markAsCancelled(plannedExpenseId);
  }

  /// Gets a planned expense by ID for conversion preview.
  Future<PlannedExpenseModel?> getPlannedExpenseById(int id) {
    return _plannedExpenseRepository.getPlannedExpenseById(id);
  }
}

/// Provider for PlannedExpenseConversionService.
///
/// Uses Riverpod provider pattern (ARCH-4).
final plannedExpenseConversionServiceProvider =
    Provider<PlannedExpenseConversionService>((ref) {
  final plannedExpenseRepository = ref.watch(plannedExpenseRepositoryProvider);
  final transactionRepository = ref.watch(transactionRepositoryProvider);

  return PlannedExpenseConversionService(
    plannedExpenseRepository: plannedExpenseRepository,
    transactionRepository: transactionRepository,
  );
});
