# Story 2.4: Category Selection Component

Status: done

## Story

As a **user**,
I want **to select a category with a single tap on a visual chip**,
So that **I can categorize my transaction without typing**.

## Implementation Note

**This story was already implemented as part of Story 2-2 (Add Expense with Bottom Sheet).**

The `CategoryChipRow` and `_CategoryChip` widgets were created during the expense bottom sheet implementation, as they were essential components of the transaction entry flow.

## Acceptance Criteria

### AC1: Category Chips Display
**Given** the bottom sheet is open
**When** the category chips are displayed
**Then**:
- [x] 6 expense categories shown with icons: Transport, Repas, Loisirs, Famille, Abonnements, Autre
- [x] Each chip has appropriate icon (Icons.directions_car, Icons.restaurant, etc.)
- [x] Categories displayed in horizontal scrollable row

### AC2: Touch Target Size
**Given** the category chips are displayed
**When** measuring touch targets
**Then**:
- [x] SizedBox height is 48dp (minimum touch target)
- [x] NFR-19 accessibility requirement met

### AC3: Single Selection Behavior
**Given** a category is already selected
**When** the user taps a different category
**Then**:
- [x] Previous selection is deselected
- [x] New category becomes selected
- [x] Only one category can be selected at a time

### AC4: Visual Feedback
**Given** a category is selected
**When** the selection state changes
**Then**:
- [x] Selected chip shows filled style with primary color
- [x] Unselected chips show outlined style
- [x] AnimatedContainer provides smooth 200ms transition

### AC5: Selection Animation
**Given** the user taps a category
**When** it's selected
**Then**:
- [x] 150ms scale animation plays (ScaleTransition)
- [x] Animation uses easeInOut curve
- [x] Haptic feedback (selectionClick) confirms tap

## Technical Implementation

### Files Created (in Story 2-2)

```
lib/features/transactions/presentation/widgets/category_chip_row.dart
test/widget/features/transactions/presentation/widgets/category_chip_row_test.dart
```

### Key Components

```dart
/// ExpenseCategory data class
class ExpenseCategory {
  final String id;
  final String label;
  final IconData icon;
}

/// Predefined expense categories
const List<ExpenseCategory> expenseCategories = [
  ExpenseCategory(id: 'transport', label: 'Transport', icon: Icons.directions_car),
  ExpenseCategory(id: 'food', label: 'Repas', icon: Icons.restaurant),
  ExpenseCategory(id: 'leisure', label: 'Loisirs', icon: Icons.celebration),
  ExpenseCategory(id: 'family', label: 'Famille', icon: Icons.family_restroom),
  ExpenseCategory(id: 'subscriptions', label: 'Abonnements', icon: Icons.credit_card),
  ExpenseCategory(id: 'other', label: 'Autre', icon: Icons.inventory_2),
];

/// CategoryChipRow - horizontal scrollable row of chips
class CategoryChipRow extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final bool isIncome; // Added in Story 2-3
}

/// _CategoryChip - individual chip with animation
class _CategoryChip extends StatefulWidget {
  // 150ms scale animation
  // Haptic feedback on tap
  // Filled/outlined styles based on selection
}
```

### FRs Covered
- FR9: User can select from predefined expense categories (Transport, Food, Leisure, Family, Subscriptions, Other)

### UX Requirements
- UX-7: CategoryChip component with 6 predefined categories (icons)

### NFR Requirements
- NFR-19: Touch targets minimum 48x48dp

## Test Coverage

9 tests in `category_chip_row_test.dart`:

1. displays first visible expense categories
2. displays icons for visible categories
3. calls onCategorySelected when category is tapped
4. highlights selected category
5. allows single selection only
6. scrolls horizontally when content overflows
7. expenseCategories contains 6 categories
8. expenseCategories has correct category IDs
9. expenseCategories has French labels

## Definition of Done

- [x] All acceptance criteria met
- [x] 6 expense categories display with icons
- [x] 48dp touch targets (NFR-19)
- [x] Single selection behavior works
- [x] Filled/outlined visual styles
- [x] 150ms scale animation on selection
- [x] Haptic feedback on tap
- [x] Widget tests pass (9 tests)
- [x] No lint errors
- [x] UX-7 requirement covered

## Dependencies

**Depends On:**
- Story 2.1: Transactions Database Table & Repository (done)

**Part Of:**
- Story 2.2: Add Expense with Bottom Sheet (implemented together)

**Extended By:**
- Story 2.3: Add Income Flow (added income categories with isIncome parameter)

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-10 | Story marked as done - already implemented in Story 2-2 | SM Agent |
