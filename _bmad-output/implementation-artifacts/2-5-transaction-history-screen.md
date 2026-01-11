# Story 2.5: Transaction History Screen

Status: done

## Story

As a **user**,
I want **to see a chronological list of all my transactions**,
So that **I can review and verify my spending**.

## Acceptance Criteria

### AC1: History Screen Navigation
**Given** the bottom navigation exists
**When** the user taps the History icon
**Then**:
- [x] Navigation occurs with slide transition (300ms)
- [x] The History tab shows as active (filled icon)
- [x] Screen displays transaction list
- [x] Title bar shows "Historique"

### AC2: Bottom Navigation Setup
**Given** the app is open
**When** viewing any main screen
**Then**:
- [x] Bottom navigation shows 4 items: Accueil (Home), Historique (History), Patterns, Parametres (Settings)
- [x] Each item has icon + label
- [x] Active item uses filled icon style, inactive use outlined
- [x] Navigation persists across tab changes
- [x] Icons: Home, Receipt (history), Analytics (patterns), Settings

### AC3: Transaction List Display
**Given** the user has transactions
**When** viewing the History screen
**Then**:
- [x] Transactions are grouped by date section headers
- [x] Date groupings: "Aujourd'hui", "Hier", and "DD/MM/YYYY" for older
- [x] Each transaction shows: category icon, note/category label, amount, time
- [x] List scrolls smoothly with 1000+ items (ListView.builder)
- [x] Most recent transactions appear first (descending order)

### AC4: Transaction Tile Layout
**Given** a transaction exists
**When** it's displayed in the list
**Then**:
- [x] Left: Category icon in colored circle (48x48dp)
- [x] Center: Category label (or note if present), time below
- [x] Right: Amount with +/- prefix
- [x] Expenses show amount in default text color
- [x] Incomes show amount in green (AppColors.success)
- [x] Time format: "HH:mm"

### AC5: Empty State
**Given** no transactions exist for the current period
**When** viewing the History screen
**Then**:
- [x] EmptyStateWidget displays "Aucune transaction ce mois"
- [x] CTA button shows "Ajouter une depense"
- [x] Tapping CTA opens TransactionBottomSheet

### AC6: Reactive Updates
**Given** transactions are displayed
**When** a new transaction is added (from any screen)
**Then**:
- [x] History list updates automatically (reactive via stream)
- [x] New transaction appears at correct position
- [x] No manual refresh required

## Technical Requirements

### Files to Create

```
lib/
├── features/
│   ├── history/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── history_screen.dart
│   │       ├── widgets/
│   │       │   ├── transaction_tile.dart
│   │       │   └── date_section_header.dart
│   │       └── providers/
│   │           └── history_provider.dart
│   └── shell/
│       └── presentation/
│           ├── screens/
│           │   └── main_shell.dart
│           └── widgets/
│               └── app_bottom_nav.dart
test/
├── widget/
│   └── features/
│       ├── history/
│       │   └── presentation/
│       │       ├── screens/
│       │       │   └── history_screen_test.dart
│       │       └── widgets/
│       │           └── transaction_tile_test.dart
│       └── shell/
│           └── presentation/
│               └── widgets/
│                   └── app_bottom_nav_test.dart
```

### Files to Modify

```
lib/core/router/app_router.dart         # Add ShellRoute for bottom nav
lib/features/home/presentation/screens/home_screen.dart  # Remove FAB position (now in shell)
```

### Dependencies
- Uses: `TransactionRepository.watchTransactionsForMonth()` for reactive list
- Uses: `clockProvider` for date handling (ARCH-6)
- Uses: `FcfaFormatter` for amount display
- Uses: `TransactionModel` from Story 2-1
- Uses: `EmptyStateWidget` from Story 1-6
- Follows: Riverpod 2.x state management (ARCH-4)
- Uses: go_router ShellRoute for persistent bottom nav

### FRs Covered
- FR11: User can view a chronological list of all transactions
- FR14: User can see transaction date and time for each entry

### UX Requirements
- UX-15: Bottom Navigation with 4 items (Home, History, Patterns, Settings)

### NFR Requirements
- NFR4: Screen transitions < 300ms
- NFR5: App memory usage < 150MB (ListView.builder required)

## Tasks

### Task 1: Create MainShell with Bottom Navigation
**Files:**
- `lib/features/shell/presentation/screens/main_shell.dart`
- `lib/features/shell/presentation/widgets/app_bottom_nav.dart`

Create shell widget that wraps all main screens with persistent bottom navigation:

```dart
/// Main shell widget providing bottom navigation structure.
///
/// Uses go_router's ShellRoute pattern for persistent navigation.
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TransactionBottomSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        tooltip: 'Ajouter une transaction',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
```

```dart
/// Bottom navigation bar widget.
///
/// Shows 4 navigation items: Home, History, Patterns, Settings.
/// Active item uses filled icon, inactive use outlined.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current route to determine active tab
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _getIndexFromLocation(location);

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Historique',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Patterns',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Parametres',
        ),
      ],
    );
  }

  int _getIndexFromLocation(String location) {
    if (location.startsWith(AppRoutes.history)) return 1;
    if (location.startsWith(AppRoutes.patterns)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0; // Default to home
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.history);
      case 2:
        context.go(AppRoutes.patterns);
      case 3:
        context.go(AppRoutes.settings);
    }
  }
}
```

### Task 2: Update AppRouter with ShellRoute
**File:** `lib/core/router/app_router.dart`

Add ShellRoute for main screens with bottom navigation:

```dart
routes: [
  // Onboarding route (no shell)
  GoRoute(
    path: AppRoutes.onboarding,
    name: 'onboarding',
    builder: (context, state) => const OnboardingScreen(),
  ),
  // Shell route for main screens with bottom nav
  ShellRoute(
    builder: (context, state, child) => MainShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HistoryScreen(),
          // Same slide transition
        ),
      ),
      GoRoute(
        path: AppRoutes.patterns,
        name: 'patterns',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PatternsLockedScreen(), // Placeholder until Epic 5
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsPlaceholderScreen(), // Placeholder until Story 3.7
        ),
      ),
    ],
  ),
],
```

### Task 3: Create HistoryProvider
**File:** `lib/features/history/presentation/providers/history_provider.dart`

Provider for reactive transaction list with date grouping:

```dart
/// State class for grouped transactions.
class GroupedTransactions {
  const GroupedTransactions({required this.groups});

  final Map<String, List<TransactionModel>> groups;

  /// Returns date headers in chronological order (most recent first).
  List<String> get headers => groups.keys.toList();

  /// Total transaction count.
  int get totalCount => groups.values.fold(0, (sum, list) => sum + list.length);
}

/// Provider for watching current month transactions.
final historyTransactionsProvider =
    StreamProvider.autoDispose<GroupedTransactions>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final clock = ref.watch(clockProvider);
  final now = clock.now();

  return repository.watchTransactionsForMonth(now).map((transactions) {
    return _groupTransactionsByDate(transactions, now);
  });
});

/// Groups transactions by date label.
GroupedTransactions _groupTransactionsByDate(
  List<TransactionModel> transactions,
  DateTime now,
) {
  final Map<String, List<TransactionModel>> groups = {};
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
```

### Task 4: Create TransactionTile Widget
**File:** `lib/features/history/presentation/widgets/transaction_tile.dart`

Display individual transaction with proper styling:

```dart
/// Widget displaying a single transaction in the history list.
///
/// Shows category icon, label/note, time, and amount.
/// Income amounts display in green, expenses in default color.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    required this.transaction,
    super.key,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final categoryData = _getCategoryData(transaction.category, isIncome);
    final amountText = isIncome
        ? '+${FcfaFormatter.format(transaction.amountFcfa)}'
        : '-${FcfaFormatter.format(transaction.amountFcfa)}';
    final timeText = '${transaction.date.hour.toString().padLeft(2, '0')}:'
        '${transaction.date.minute.toString().padLeft(2, '0')}';

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: categoryData.color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          categoryData.icon,
          color: categoryData.color,
          size: 24,
        ),
      ),
      title: Text(
        transaction.note ?? categoryData.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        timeText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
      ),
      trailing: Text(
        amountText,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isIncome ? AppColors.success : AppColors.onSurface,
            ),
      ),
    );
  }

  /// Gets category display data (icon, label, color).
  _CategoryDisplayData _getCategoryData(String categoryId, bool isIncome) {
    if (isIncome) {
      return _incomeCategoryMap[categoryId] ?? _defaultIncomeCategory;
    }
    return _expenseCategoryMap[categoryId] ?? _defaultExpenseCategory;
  }
}

/// Display data for a category.
class _CategoryDisplayData {
  const _CategoryDisplayData({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;
}

const _expenseCategoryMap = {
  'transport': _CategoryDisplayData(
    icon: Icons.directions_car,
    label: 'Transport',
    color: AppColors.primary,
  ),
  'food': _CategoryDisplayData(
    icon: Icons.restaurant,
    label: 'Repas',
    color: Colors.orange,
  ),
  'leisure': _CategoryDisplayData(
    icon: Icons.celebration,
    label: 'Loisirs',
    color: Colors.purple,
  ),
  'family': _CategoryDisplayData(
    icon: Icons.family_restroom,
    label: 'Famille',
    color: Colors.pink,
  ),
  'subscriptions': _CategoryDisplayData(
    icon: Icons.credit_card,
    label: 'Abonnements',
    color: Colors.blue,
  ),
  'other': _CategoryDisplayData(
    icon: Icons.inventory_2,
    label: 'Autre',
    color: Colors.grey,
  ),
};

const _incomeCategoryMap = {
  'salary': _CategoryDisplayData(
    icon: Icons.account_balance_wallet,
    label: 'Salaire',
    color: AppColors.success,
  ),
  'freelance': _CategoryDisplayData(
    icon: Icons.laptop_mac,
    label: 'Freelance',
    color: AppColors.success,
  ),
  'reimbursement': _CategoryDisplayData(
    icon: Icons.receipt_long,
    label: 'Remboursement',
    color: AppColors.success,
  ),
  'gift': _CategoryDisplayData(
    icon: Icons.card_giftcard,
    label: 'Cadeau',
    color: AppColors.success,
  ),
  'other': _CategoryDisplayData(
    icon: Icons.more_horiz,
    label: 'Autre',
    color: AppColors.success,
  ),
};

const _defaultExpenseCategory = _CategoryDisplayData(
  icon: Icons.inventory_2,
  label: 'Autre',
  color: Colors.grey,
);

const _defaultIncomeCategory = _CategoryDisplayData(
  icon: Icons.more_horiz,
  label: 'Autre',
  color: AppColors.success,
);
```

### Task 5: Create DateSectionHeader Widget
**File:** `lib/features/history/presentation/widgets/date_section_header.dart`

Section header for date groupings:

```dart
/// Section header widget showing date label in transaction list.
class DateSectionHeader extends StatelessWidget {
  const DateSectionHeader({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surfaceVariant,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
      ),
    );
  }
}
```

### Task 6: Create HistoryScreen
**File:** `lib/features/history/presentation/screens/history_screen.dart`

Main history screen with grouped transaction list:

```dart
/// Screen displaying chronological transaction history.
///
/// Shows transactions grouped by date (Aujourd'hui, Hier, DD/MM/YYYY).
/// Uses ListView.builder for efficient rendering with large lists.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: ${error.toString()}'),
        ),
        data: (grouped) {
          if (grouped.totalCount == 0) {
            return Center(
              child: EmptyStateWidget.history(
                onAction: () => TransactionBottomSheet.show(context),
              ),
            );
          }

          // Build flat list with headers and tiles
          return _TransactionListView(grouped: grouped);
        },
      ),
    );
  }
}

/// Builds flat list from grouped transactions.
class _TransactionListView extends StatelessWidget {
  const _TransactionListView({required this.grouped});

  final GroupedTransactions grouped;

  @override
  Widget build(BuildContext context) {
    // Create flat list of items (headers + transactions)
    final items = <_ListItem>[];
    for (final header in grouped.headers) {
      items.add(_HeaderItem(header));
      for (final transaction in grouped.groups[header]!) {
        items.add(_TransactionItem(transaction));
      }
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is _HeaderItem) {
          return DateSectionHeader(label: item.label);
        } else if (item is _TransactionItem) {
          return TransactionTile(transaction: item.transaction);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Base class for list items.
sealed class _ListItem {}

/// Header item for date sections.
class _HeaderItem extends _ListItem {
  _HeaderItem(this.label);
  final String label;
}

/// Transaction item.
class _TransactionItem extends _ListItem {
  _TransactionItem(this.transaction);
  final TransactionModel transaction;
}
```

### Task 7: Create Placeholder Screens
**Files:**
- `lib/features/patterns/presentation/screens/patterns_locked_screen.dart`
- `lib/features/settings/presentation/screens/settings_placeholder_screen.dart`

Placeholder screens until Epic 3 and Epic 5:

```dart
// patterns_locked_screen.dart
class PatternsLockedScreen extends StatelessWidget {
  const PatternsLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patterns')),
      body: const Center(
        child: EmptyStateWidget(
          icon: Icons.lock_outline,
          title: 'Patterns verrouilles',
          message: 'Disponible apres 30 jours de suivi',
        ),
      ),
    );
  }
}

// settings_placeholder_screen.dart
class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parametres')),
      body: const Center(
        child: Text('Bientot disponible'),
      ),
    );
  }
}
```

### Task 8: Update HomeScreen
**File:** `lib/features/home/presentation/screens/home_screen.dart`

Remove FAB (now in MainShell) and update empty state logic:

```dart
// Remove floatingActionButton and floatingActionButtonLocation
// FAB is now in MainShell

// Update hasTransactions to check real data
final transactionsAsync = ref.watch(historyTransactionsProvider);
final hasTransactions = transactionsAsync.maybeWhen(
  data: (grouped) => grouped.totalCount > 0,
  orElse: () => false,
);
```

### Task 9: Add EmptyStateWidget.history Variant
**File:** `lib/shared/widgets/empty_state_widget.dart`

Add history-specific empty state:

```dart
/// Creates an empty state for the history screen.
factory EmptyStateWidget.history({VoidCallback? onAction}) {
  return EmptyStateWidget(
    icon: Icons.receipt_long_outlined,
    title: 'Aucune transaction ce mois',
    message: 'Commence a tracker tes depenses',
    actionLabel: 'Ajouter une depense',
    onAction: onAction,
  );
}
```

### Task 10: Write Widget Tests
**Files:**
- `test/widget/features/history/presentation/screens/history_screen_test.dart`
- `test/widget/features/history/presentation/widgets/transaction_tile_test.dart`
- `test/widget/features/shell/presentation/widgets/app_bottom_nav_test.dart`

Test coverage:
- HistoryScreen displays loading, error, empty, and data states
- TransactionTile shows correct layout for expense vs income
- AppBottomNav highlights active tab
- Navigation between tabs works
- Date grouping logic works correctly

```dart
group('HistoryScreen', () {
  testWidgets('displays empty state when no transactions', (tester) async {
    // ...
    expect(find.text('Aucune transaction ce mois'), findsOneWidget);
  });

  testWidgets('displays transactions grouped by date', (tester) async {
    // ...
    expect(find.text("Aujourd'hui"), findsOneWidget);
  });
});

group('TransactionTile', () {
  testWidgets('displays expense in default color', (tester) async {
    // ...
  });

  testWidgets('displays income in green with + prefix', (tester) async {
    // ...
    final amountWidget = tester.widget<Text>(find.text('+50 000'));
    expect(amountWidget.style?.color, AppColors.success);
  });
});
```

## Dev Notes

### Critical Rules from Epic 1 & Story 2-1/2-2/2-3 Retrospectives

1. **NEVER use DateTime.now() directly** - Always use `clockProvider`
   ```dart
   // CORRECT
   final now = ref.read(clockProvider).now();

   // WRONG
   final now = DateTime.now();
   ```

2. **Use int for ALL FCFA amounts** - No double anywhere (ARCH-7)

3. **Use FcfaFormatter for display** - Already exists in lib/core/utils/

4. **Widget tests are REQUIRED** - Missing tests were flagged in Epic 1 retro

5. **Use `on AppException catch (e)`** - Not generic `catch (e)`

6. **ListView.builder is MANDATORY** - Never use ListView with children (NFR5)

### Date Formatting

```dart
// French labels for date sections
final today = DateTime(now.year, now.month, now.day);
final transactionDay = DateTime(t.year, t.month, t.day);

if (transactionDay == today) {
  return "Aujourd'hui";
} else if (transactionDay == today.subtract(const Duration(days: 1))) {
  return 'Hier';
} else {
  return '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')}/${t.year}';
}
```

### ShellRoute Pattern (go_router)

```dart
ShellRoute(
  builder: (context, state, child) => MainShell(child: child),
  routes: [
    GoRoute(path: '/'),
    GoRoute(path: '/history'),
    // ...
  ],
)
```

### Category Colors

Use consistent category colors from design system:
- Transport: Primary (green)
- Food: Orange
- Leisure: Purple
- Family: Pink
- Subscriptions: Blue
- Other: Grey
- All income: Success green

### Time Format

Use 24-hour format for French locale:
```dart
final timeText = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
// Output: "14:30"
```

## References

### Architecture Document
- **Location:** `_bmad-output/planning-artifacts/architecture.md`
- **Relevant sections:** Navigation, State Management

### Project Context
- **Location:** `_bmad-output/project-context.md`
- **Critical rules:** FCFA = int only, clockProvider, Riverpod patterns, ListView.builder

### Epic 1 Retrospective
- **Location:** `_bmad-output/implementation-artifacts/epic-1-retro-2026-01-10.md`
- **Key learnings:** DateTime.now() violations, widget tests required

### Story 2-1 (Database Foundation)
- **Location:** `_bmad-output/implementation-artifacts/2-1-transactions-database-table-repository.md`
- **Provides:** TransactionModel, TransactionType, TransactionRepository

### Story 2-3 (Income Flow)
- **Location:** `_bmad-output/implementation-artifacts/2-3-add-income-flow.md`
- **Provides:** Income categories, type toggle pattern

### Existing Code Files
- **TransactionRepository:** `lib/features/transactions/data/transaction_repository.dart`
- **TransactionModel:** `lib/features/transactions/domain/models/transaction_model.dart`
- **AppRouter:** `lib/core/router/app_router.dart`
- **HomeScreen:** `lib/features/home/presentation/screens/home_screen.dart`
- **EmptyStateWidget:** `lib/shared/widgets/empty_state_widget.dart`
- **AppColors:** `lib/core/theme/app_colors.dart`

## Definition of Done

- [x] All acceptance criteria met
- [x] Bottom navigation with 4 items works
- [x] HistoryScreen displays transactions grouped by date
- [x] TransactionTile shows correct expense/income styling
- [x] Empty state displays when no transactions
- [x] List updates reactively when transactions added
- [x] Navigation transitions are 300ms
- [x] ListView.builder used for efficient scrolling
- [x] Widget tests pass for all new components
- [x] No lint errors (`dart analyze`)
- [x] FCFA amounts verified as `int` (no double)
- [x] No DateTime.now() direct usage - clockProvider only

## File List

### To Create
- `lib/features/shell/presentation/screens/main_shell.dart`
- `lib/features/shell/presentation/widgets/app_bottom_nav.dart`
- `lib/features/history/presentation/screens/history_screen.dart`
- `lib/features/history/presentation/widgets/transaction_tile.dart`
- `lib/features/history/presentation/widgets/date_section_header.dart`
- `lib/features/history/presentation/providers/history_provider.dart`
- `lib/features/patterns/presentation/screens/patterns_locked_screen.dart`
- `lib/features/settings/presentation/screens/settings_placeholder_screen.dart`
- `test/widget/features/history/presentation/screens/history_screen_test.dart`
- `test/widget/features/history/presentation/widgets/transaction_tile_test.dart`
- `test/widget/features/shell/presentation/widgets/app_bottom_nav_test.dart`

### To Modify
- `lib/core/router/app_router.dart` (add ShellRoute)
- `lib/features/home/presentation/screens/home_screen.dart` (remove FAB)
- `lib/shared/widgets/empty_state_widget.dart` (add history variant)

## Dependencies

**Depends On:**
- Story 2.1: Transactions Database Table & Repository (done)
- Story 2.2: Add Expense with Bottom Sheet (done)
- Story 2.3: Add Income Flow (done)
- Story 2.4: Category Selection Component (done)

**Blocks:**
- Story 2.6: Edit Existing Transaction (will add swipe-to-edit on history items)
- Story 2.7: Delete Transaction with Swipe (will add swipe-to-delete)
- Story 3.7: Settings Screen (will replace placeholder)
- Story 5.1: Patterns Feature Unlock (will replace placeholder)

## Notes

- Bottom navigation is a significant structural change affecting the entire app
- ShellRoute pattern keeps FAB persistent across all main screens
- Placeholder screens for Patterns and Settings prevent navigation errors
- History list uses flat list with mixed item types (headers + transactions)
- Consider: Should FAB be visible on all tabs? (Current: Yes - UX-3 specifies centered FAB)

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-10 | Story created with comprehensive developer context | SM Agent |
