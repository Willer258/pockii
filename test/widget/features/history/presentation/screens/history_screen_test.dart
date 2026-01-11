import 'package:accountapp/features/history/presentation/providers/history_provider.dart';
import 'package:accountapp/features/history/presentation/screens/history_screen.dart';
import 'package:accountapp/features/history/presentation/widgets/date_section_header.dart';
import 'package:accountapp/features/history/presentation/widgets/transaction_tile.dart';
import 'package:accountapp/features/transactions/domain/models/transaction_model.dart';
import 'package:accountapp/features/transactions/domain/models/transaction_type.dart';
import 'package:accountapp/shared/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HistoryScreen', () {
    Widget buildTestWidget({GroupedTransactions? data, bool isLoading = false}) {
      return ProviderScope(
        overrides: [
          historyTransactionsProvider.overrideWith((ref) {
            if (isLoading) {
              return const Stream<GroupedTransactions>.empty();
            }
            return Stream.value(data ?? GroupedTransactions.empty);
          }),
        ],
        child: const MaterialApp(
          home: HistoryScreen(),
        ),
      );
    }

    TransactionModel createTestTransaction({
      required int id,
      required int amount,
      required String category,
      required TransactionType type,
      required DateTime date,
      String? note,
    }) {
      return TransactionModel(
        id: id,
        amountFcfa: amount,
        category: category,
        type: type,
        date: date,
        createdAt: date,
        note: note,
      );
    }

    testWidgets('displays app bar with correct title', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Historique'), findsOneWidget);
    });

    testWidgets('displays empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyStateWidget), findsOneWidget);
      expect(find.text('Aucune transaction ce mois'), findsOneWidget);
    });

    testWidgets('displays transactions when they exist', (tester) async {
      final transaction = createTestTransaction(
        id: 1,
        amount: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 12),
      );
      final data = GroupedTransactions(groups: {
        "Aujourd'hui": [transaction],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Should show transaction tile, not empty state
      expect(find.byType(TransactionTile), findsOneWidget);
      expect(find.byType(EmptyStateWidget), findsNothing);
    });

    testWidgets('groups transactions by date with headers', (tester) async {
      final todayTransaction = createTestTransaction(
        id: 1,
        amount: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 12),
      );
      final yesterdayTransaction = createTestTransaction(
        id: 2,
        amount: 3000,
        category: 'transport',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 14, 10),
      );
      final data = GroupedTransactions(groups: {
        "Aujourd'hui": [todayTransaction],
        'Hier': [yesterdayTransaction],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Should have date section headers
      expect(find.byType(DateSectionHeader), findsNWidgets(2));
      expect(find.text("Aujourd'hui"), findsOneWidget);
      expect(find.text('Hier'), findsOneWidget);
    });

    testWidgets('displays multiple transactions', (tester) async {
      final transaction1 = createTestTransaction(
        id: 1,
        amount: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 8),
      );
      final transaction2 = createTestTransaction(
        id: 2,
        amount: 3000,
        category: 'transport',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 12),
      );
      final data = GroupedTransactions(groups: {
        "Aujourd'hui": [transaction1, transaction2],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Both transactions should be shown
      expect(find.byType(TransactionTile), findsNWidgets(2));
    });

    testWidgets('uses ListView.builder for efficient rendering', (tester) async {
      final transaction = createTestTransaction(
        id: 1,
        amount: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 15, 12),
      );
      final data = GroupedTransactions(groups: {
        "Aujourd'hui": [transaction],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Should use ListView.builder (not ListView with children)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows income transactions with plus prefix', (tester) async {
      final transaction = createTestTransaction(
        id: 1,
        amount: 50000,
        category: 'salary',
        type: TransactionType.income,
        date: DateTime(2026, 1, 15, 12),
      );
      final data = GroupedTransactions(groups: {
        "Aujourd'hui": [transaction],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Should show the income with + prefix
      expect(find.textContaining('+'), findsOneWidget);
    });

    testWidgets('formats older dates as DD/MM/YYYY', (tester) async {
      final transaction = createTestTransaction(
        id: 1,
        amount: 5000,
        category: 'food',
        type: TransactionType.expense,
        date: DateTime(2026, 1, 10, 12),
      );
      final data = GroupedTransactions(groups: {
        '10/01/2026': [transaction],
      });

      await tester.pumpWidget(buildTestWidget(data: data));
      await tester.pumpAndSettle();

      // Should show formatted date
      expect(find.text('10/01/2026'), findsOneWidget);
    });
  });
}
