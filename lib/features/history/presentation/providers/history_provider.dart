import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/clock_service.dart';
import '../../../transactions/data/transaction_repository.dart';
import '../../../transactions/domain/models/transaction_model.dart';

/// Provider for category filter state.
///
/// When set to a category ID, history will show only transactions
/// in that category. Set to null to show all transactions.
final historyCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// State class for grouped transactions.
class GroupedTransactions {
  /// Creates a GroupedTransactions with the given groups.
  const GroupedTransactions({required this.groups});

  /// Empty state.
  static const empty = GroupedTransactions(groups: {});

  /// Map of date labels to transactions for that date.
  final Map<String, List<TransactionModel>> groups;

  /// Returns date headers in order (as inserted - most recent first).
  List<String> get headers => groups.keys.toList();

  /// Total transaction count.
  int get totalCount => groups.values.fold(0, (sum, list) => sum + list.length);
}

/// Provider for watching current month transactions grouped by date.
///
/// Uses [clockProvider] for testable time handling (ARCH-6).
/// Returns transactions grouped as "Aujourd'hui", "Hier", or "DD/MM/YYYY".
/// Respects [historyCategoryFilterProvider] to filter by category.
final historyTransactionsProvider =
    StreamProvider.autoDispose<GroupedTransactions>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final clock = ref.watch(clockProvider);
  final categoryFilter = ref.watch(historyCategoryFilterProvider);
  final now = clock.now();

  return repository.watchTransactionsForMonth(now).map((transactions) {
    // Apply category filter if set
    var filtered = transactions;
    if (categoryFilter != null) {
      filtered = transactions
          .where((t) => t.category == categoryFilter)
          .toList();
    }
    return _groupTransactionsByDate(filtered, now);
  });
});

/// Groups transactions by date label.
///
/// Labels are:
/// - "Aujourd'hui" for today's transactions
/// - "Hier" for yesterday's transactions
/// - "DD/MM/YYYY" for older transactions
GroupedTransactions _groupTransactionsByDate(
  List<TransactionModel> transactions,
  DateTime now,
) {
  if (transactions.isEmpty) {
    return GroupedTransactions.empty;
  }

  final groups = <String, List<TransactionModel>>{};
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  for (final transaction in transactions) {
    final transactionDate = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    String label;
    if (transactionDate == today) {
      label = "Aujourd'hui";
    } else if (transactionDate == yesterday) {
      label = 'Hier';
    } else {
      // Format: DD/MM/YYYY
      label = '${transactionDate.day.toString().padLeft(2, '0')}/'
          '${transactionDate.month.toString().padLeft(2, '0')}/'
          '${transactionDate.year}';
    }

    groups.putIfAbsent(label, () => []).add(transaction);
  }

  return GroupedTransactions(groups: groups);
}
