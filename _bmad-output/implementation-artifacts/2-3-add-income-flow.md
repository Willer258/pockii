# Story 2.3: Add Income Flow

Status: done

## Story

As a **user**,
I want **to add income (salary, freelance, gifts)**,
So that **my budget reflects money coming in, not just going out**.

## Acceptance Criteria

### AC1: Toggle Between Expense and Income Mode
**Given** the user opens the transaction bottom sheet
**When** the sheet is displayed
**Then**:
- [x] A segmented button toggle shows "Depense" and "Revenu" options
- [x] Toggle is positioned below the title, above amount display
- [x] "Depense" mode is selected by default
- [x] Toggle has smooth transition animation (200ms)
- [x] Haptic feedback on toggle change

### AC2: Income Mode Title Change
**Given** the user toggles to "Revenu" mode
**When** the mode changes
**Then**:
- [x] The form title changes from "Nouvelle depense" to "Nouveau revenu"
- [x] Title transition is animated (fade)
- [x] Submit button text changes to "Ajouter" (same text, keeps consistency)

### AC3: Income-Specific Categories Display
**Given** the user is in "Revenu" mode
**When** the category chips are displayed
**Then**:
- [x] 5 income categories shown: Salaire, Freelance, Remboursement, Cadeau, Autre
- [x] Each chip has appropriate icon (see Technical Notes)
- [x] Chips replace expense categories (not shown simultaneously)
- [x] Default selection behavior same as expense (none selected = "Autre")

### AC4: Save Income Transaction
**Given** the user is in "Revenu" mode and has entered an amount
**When** they tap "Ajouter"
**Then**:
- [x] Transaction is saved with type = "income"
- [x] Category is stored from income categories list
- [x] Snackbar shows "Revenu ajoute" (different from expense message)
- [x] Budget increases by the income amount (calculation verification)
- [x] BudgetHeroCard updates within 100ms (NFR2)

### AC5: Mode Persists During Entry
**Given** the user toggles to "Revenu" mode
**When** they enter amount and select category
**Then**:
- [x] Mode selection persists through the entire entry flow
- [x] Form state includes transaction type
- [x] Toggling mode clears category selection (different category sets)
- [x] Toggling mode preserves entered amount

### AC6: Income Categories Definition
**Given** the income categories exist
**When** they are displayed
**Then**:
- [x] Salaire (Salary): Icons.account_balance_wallet
- [x] Freelance: Icons.laptop_mac
- [x] Remboursement (Reimbursement): Icons.receipt_long
- [x] Cadeau (Gift): Icons.card_giftcard
- [x] Autre (Other): Icons.more_horiz

## Technical Requirements

### Files to Modify

```
lib/
├── features/
│   └── transactions/
│       └── presentation/
│           ├── widgets/
│           │   ├── transaction_bottom_sheet.dart  # Add mode toggle
│           │   └── category_chip_row.dart         # Support income categories
│           └── providers/
│               └── transaction_form_provider.dart # Add transactionType state
```

### Files to Create

```
test/
├── widget/
│   └── features/
│       └── transactions/
│           └── presentation/
│               └── widgets/
│                   └── income_flow_test.dart      # Income-specific tests
```

### Dependencies
- Uses: All widgets from Story 2-2 (TransactionBottomSheet, NumericKeypad, AmountDisplay)
- Uses: `TransactionRepository.createTransaction()` with type parameter
- Uses: `TransactionType.income` enum value (from Story 2-1)
- Uses: `clockProvider` for date handling (ARCH-6)
- Uses: `FcfaFormatter` for amount display
- Follows: Riverpod 2.x state management (ARCH-4)

### FRs Covered
- FR7: User can add a new income with amount, category, and optional note
- FR10: User can select from predefined income categories (Salary, Freelance, Reimbursement, Gift, Other)

### ARCH Requirements
- ARCH-4: Riverpod 2.x state management with StateNotifierProvider
- ARCH-6: Injectable Clock provider for testable time handling
- ARCH-7: FCFA amounts as int only (no double anywhere)

### UX Requirements
- UX-2: TransactionBottomSheet with 3-tap flow maintained
- UX-12: Haptic feedback on toggle and submission

### NFR Requirements
- NFR2: "Remaining Budget" update <100ms after income added
- NFR3: Transaction entry flow <10 seconds total

## Tasks

### Task 1: Extend TransactionFormState with TransactionType
**File:** `lib/features/transactions/presentation/providers/transaction_form_provider.dart`

Add transaction type to form state:
- Add `transactionType: TransactionType` field (defaults to `expense`)
- Add `setTransactionType(TransactionType type)` method to notifier
- When type changes, clear category (different category sets)
- Keep amount preserved when toggling

```dart
class TransactionFormState {
  const TransactionFormState({
    this.amountFcfa = 0,
    this.category,
    this.note,
    this.transactionType = TransactionType.expense,
  });

  final int amountFcfa;
  final String? category;
  final String? note;
  final TransactionType transactionType;

  bool get isValid => amountFcfa > 0;
  bool get isIncome => transactionType == TransactionType.income;
  // ...
}
```

### Task 2: Add Income Categories to CategoryChipRow
**File:** `lib/features/transactions/presentation/widgets/category_chip_row.dart`

Add income categories and modify widget to accept category type:

```dart
/// Predefined income categories.
const List<ExpenseCategory> incomeCategories = [
  ExpenseCategory(id: 'salary', label: 'Salaire', icon: Icons.account_balance_wallet),
  ExpenseCategory(id: 'freelance', label: 'Freelance', icon: Icons.laptop_mac),
  ExpenseCategory(id: 'reimbursement', label: 'Remboursement', icon: Icons.receipt_long),
  ExpenseCategory(id: 'gift', label: 'Cadeau', icon: Icons.card_giftcard),
  ExpenseCategory(id: 'other', label: 'Autre', icon: Icons.more_horiz),
];

class CategoryChipRow extends StatelessWidget {
  const CategoryChipRow({
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isIncome = false,  // NEW: Determines which category set to show
    super.key,
  });

  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool isIncome;

  List<ExpenseCategory> get _categories =>
      isIncome ? incomeCategories : expenseCategories;
  // ...
}
```

### Task 3: Add Mode Toggle to TransactionBottomSheet
**File:** `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`

Add segmented button for expense/income toggle:

```dart
// Below title, above AmountDisplay
SegmentedButton<TransactionType>(
  segments: const [
    ButtonSegment(
      value: TransactionType.expense,
      label: Text('Depense'),
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
)
```

### Task 4: Update Title Based on Mode
**File:** `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`

Dynamic title based on transaction type:

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: Text(
    formState.isIncome ? 'Nouveau revenu' : 'Nouvelle depense',
    key: ValueKey(formState.transactionType),
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Task 5: Update Submit Logic for Income
**File:** `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`

Modify submit to use form's transaction type:

```dart
await repository.createTransaction(
  amountFcfa: formState.amountFcfa,
  category: category,
  type: formState.transactionType,  // Changed from hardcoded expense
  note: formState.note,
  date: now,
);

// Different snackbar message
final message = formState.isIncome ? 'Revenu ajoute' : 'Depense ajoutee';
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)),
);
```

### Task 6: Pass isIncome to CategoryChipRow
**File:** `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`

Update CategoryChipRow usage:

```dart
CategoryChipRow(
  selectedCategory: formState.category,
  onCategorySelected: formNotifier.setCategory,
  isIncome: formState.isIncome,
)
```

### Task 7: Write Widget Tests for Income Flow
**File:** `test/widget/features/transactions/presentation/widgets/income_flow_test.dart`

Test coverage:
- Toggle switches between expense/income mode
- Income categories display when in income mode
- Title changes when toggling mode
- Toggling clears category selection
- Income transaction saves with correct type
- Snackbar shows correct message for income

```dart
testWidgets('toggles to income mode and shows income categories', (tester) async {
  // ...
  await tester.tap(find.text('Revenu'));
  await tester.pumpAndSettle();

  expect(find.text('Nouveau revenu'), findsOneWidget);
  expect(find.text('Salaire'), findsOneWidget);
  expect(find.text('Transport'), findsNothing); // Expense category hidden
});
```

### Task 8: Update Existing Tests
**Files:**
- `test/widget/features/transactions/presentation/widgets/transaction_bottom_sheet_test.dart`
- `test/widget/features/transactions/presentation/widgets/category_chip_row_test.dart`

Ensure existing tests still pass with new isIncome parameter:
- Add default `isIncome: false` to CategoryChipRow tests
- Verify expense flow unchanged

## Dev Notes

### Critical Rules from Epic 1 & Story 2-1/2-2 Retrospectives

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

5. **Income default category:** `'other'` (same as expense)

6. **Use `on Exception catch (e)`** - Not generic `catch (e)` (from Story 2-2 review)

### Income Category Constants

```dart
const incomeCategories = ['salary', 'freelance', 'reimbursement', 'gift', 'other'];
```

Mapping to French labels:
- `salary` -> "Salaire"
- `freelance` -> "Freelance"
- `reimbursement` -> "Remboursement"
- `gift` -> "Cadeau"
- `other` -> "Autre"

### SegmentedButton Pattern

Use Material 3 SegmentedButton for mode toggle:

```dart
SegmentedButton<TransactionType>(
  segments: const [
    ButtonSegment(value: TransactionType.expense, label: Text('Depense')),
    ButtonSegment(value: TransactionType.income, label: Text('Revenu')),
  ],
  selected: {currentType},
  onSelectionChanged: (Set<TransactionType> selected) {
    // Handle change
  },
  showSelectedIcon: false, // Cleaner look
)
```

### AnimatedSwitcher for Title

```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  transitionBuilder: (child, animation) => FadeTransition(
    opacity: animation,
    child: child,
  ),
  child: Text(
    title,
    key: ValueKey(title), // Important for animation
  ),
)
```

### Test Data Guidelines

Use realistic FCFA amounts for income:
- Small income: 15000 FCFA (reimbursement)
- Medium income: 50000 FCFA (freelance)
- Large income: 350000 FCFA (salary)

### Existing Patterns to Follow

- Widget structure: See `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`
- Provider pattern: See `lib/features/transactions/presentation/providers/transaction_form_provider.dart`
- Category pattern: See `lib/features/transactions/presentation/widgets/category_chip_row.dart`

## References

### Architecture Document
- **Location:** `_bmad-output/planning-artifacts/architecture.md`
- **Relevant sections:** Data Architecture, UI Components

### Project Context
- **Location:** `_bmad-output/project-context.md`
- **Critical rules:** FCFA = int only, clockProvider, Riverpod patterns

### Epic 1 Retrospective
- **Location:** `_bmad-output/implementation-artifacts/epic-1-retro-2026-01-10.md`
- **Key learnings:** DateTime.now() violations, widget tests required

### Story 2-1 (Database Foundation)
- **Location:** `_bmad-output/implementation-artifacts/2-1-transactions-database-table-repository.md`
- **Provides:** TransactionModel, TransactionType, TransactionRepository

### Story 2-2 (Expense Bottom Sheet)
- **Location:** `_bmad-output/implementation-artifacts/2-2-add-expense-bottom-sheet.md`
- **Provides:** TransactionBottomSheet, NumericKeypad, CategoryChipRow, TransactionFormProvider

### Existing Code Files
- **TransactionBottomSheet:** `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart`
- **CategoryChipRow:** `lib/features/transactions/presentation/widgets/category_chip_row.dart`
- **TransactionFormProvider:** `lib/features/transactions/presentation/providers/transaction_form_provider.dart`
- **TransactionType:** `lib/features/transactions/domain/models/transaction_type.dart`

## Definition of Done

- [x] All acceptance criteria met
- [x] Toggle between expense/income modes works smoothly
- [x] Income categories display correctly in income mode
- [x] Transactions save with correct type (expense/income)
- [x] Budget calculation handles income correctly (increases budget)
- [x] Widget tests pass for income flow
- [x] Existing expense tests still pass
- [x] No lint errors (`dart analyze`)
- [x] FCFA amounts verified as `int` (no double)
- [x] No DateTime.now() direct usage - clockProvider only
- [x] Haptic feedback on toggle and submission
- [x] Snackbar shows appropriate message per type

## File List

### To Modify
- `lib/features/transactions/presentation/widgets/transaction_bottom_sheet.dart` (add toggle)
- `lib/features/transactions/presentation/widgets/category_chip_row.dart` (add income categories)
- `lib/features/transactions/presentation/providers/transaction_form_provider.dart` (add type state)

### To Create
- `test/widget/features/transactions/presentation/widgets/income_flow_test.dart`

### To Update Tests
- `test/widget/features/transactions/presentation/widgets/transaction_bottom_sheet_test.dart`
- `test/widget/features/transactions/presentation/widgets/category_chip_row_test.dart`

## Dependencies

**Depends On:**
- Story 2.1: Transactions Database Table & Repository (done)
- Story 2.2: Add Expense with Bottom Sheet (done)

**Blocks:**
- Story 2.5: Transaction History Screen (will show income in green)

## Notes

- This story extends the existing bottom sheet, NOT creating a new one
- Keep expense flow completely unchanged - only add income mode
- Future Story 2.5 will handle income display color (green) in history
- Consider: Should mode toggle persist across sessions? (Answer: No, default to expense each time - simpler UX)

## Senior Developer Review (AI)

**Date:** 2026-01-10
**Reviewer:** Adversarial Code Reviewer

### Issues Found & Fixed

| Severity | Issue | Resolution |
|----------|-------|------------|
| HIGH | Missing integration test for income submission | Added 2 tests: submit with category + submit with default category |
| MEDIUM | Generic Exception catch (`on Exception catch`) | Changed to `on AppException catch` for specific handling |
| MEDIUM | Lint warning - redundant DateTime default | Fixed `DateTime(2026, 1)` → `DateTime(2026)` |
| MEDIUM | No test for default income category | Added test verifying default 'other' category |

### Verification Results
- **Total tests:** 42 (up from 40)
- **All tests passing:** ✅
- **No lint errors**

### Low Priority Items (Not Fixed - Documentation Only)
- L1: `ExpenseCategory` class naming (could be `TransactionCategory`)
- L2: Story file accent inconsistency
- L3: Test assertion weakness in category selection

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-10 | Story created with comprehensive developer context | SM Agent |
| 2026-01-10 | Story implemented - 13 income flow tests, all ACs complete | Dev Agent |
| 2026-01-10 | Code review: Fixed 4 issues (1 HIGH, 3 MEDIUM), added 2 integration tests | Reviewer |
