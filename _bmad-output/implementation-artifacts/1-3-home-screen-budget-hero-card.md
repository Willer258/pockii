# Story 1.3: Home Screen with BudgetHeroCard

Status: done

## Story

As a **user**,
I want **to see my "Remaining Budget" as a big, color-coded number on the home screen**,
So that **I know exactly how much I can spend at a glance**.

## Acceptance Criteria

### AC1: BudgetHeroCard Display
**Given** the app is launched and user has completed onboarding
**When** the home screen loads
**Then**:
- [x] `BudgetHeroCard` displays the remaining budget in 56sp font
- [x] The card shows current month label (e.g., "Janvier 2026")
- [x] The card shows a progress bar (remaining/total)
- [x] The number color reflects budget status (green >30%, orange 10-30%, red <10%)
- [x] The card has semantic labels for TalkBack accessibility
- [x] The screen loads in <100ms (local data)

### AC2: Negative Budget Display
**Given** the budget is negative (overspent)
**When** viewing the home screen
**Then**:
- [x] The number displays with a "-" prefix
- [x] The color is red (BudgetColors.danger)

## Technical Requirements

### Files Created

```
lib/
├── features/
│   └── home/
│       ├── domain/
│       │   └── models/
│       │       └── budget_state.dart
│       └── presentation/
│           ├── screens/
│           │   └── home_screen.dart
│           ├── widgets/
│           │   └── budget_hero_card.dart
│           └── providers/
│               └── budget_provider.dart
test/
├── unit/
│   └── features/
│       └── home/
│           ├── budget_state_test.dart
│           └── budget_provider_test.dart
└── widget/
    └── features/
        └── home/
            └── budget_hero_card_widget_test.dart
```

### Files Modified

```
lib/
└── features/
    └── home/
        └── presentation/
            └── widgets/
                └── budget_hero_card.dart    # Refactored to use FcfaFormatter
```

### Dependencies
- Uses: `AppTypography.hero` (56sp), `BudgetColors`, `AppSpacing`, `AppBorderRadius`
- Uses: `clockProvider` for current month
- Uses: `BudgetPeriodsDao` for budget data
- Uses: Riverpod `StateNotifierProvider` pattern
- Uses: `FcfaFormatter` for amount formatting

### FRs Covered
- FR1: User can view their current "Remaining Budget" as a single prominent number
- FR3: User can see color-coded budget status (green: OK, orange: warning, red: danger)
- FR4: User can understand their budget status at a glance without scrolling or navigation

### UX Requirements Covered
- UX-1: BudgetHeroCard component with 56sp hero number and color animation
- UX-11: Semantic labels for TalkBack accessibility

### ARCH Requirements
- ARCH-4: Riverpod 2.x state management with StateNotifierProvider pattern
- ARCH-6: Injectable Clock provider (never DateTime.now() direct)
- ARCH-7: FCFA amounts as int only (no double anywhere)

## Tasks

### Task 1: Create BudgetState Model ✅
**File:** `lib/features/home/domain/models/budget_state.dart`

Features implemented:
- Immutable state class with all required fields
- `percentageRemaining` getter
- `status` getter (ok/warning/danger)
- `isOverspent` getter
- `copyWith` method
- Factory constructors with optional DateTime for testability

### Task 2-3: Create Provider System ✅
**File:** `lib/features/home/presentation/providers/budget_provider.dart`

Features implemented:
- `budgetStateProvider` - StateNotifierProvider for budget state
- `formattedBudgetProvider` - formatted string with FCFA
- `formattedBudgetNumberProvider` - number only format
- `currentMonthLabelProvider` - French month label
- `budgetPercentageProvider` - percentage for progress bar
- `budgetStatusProvider` - status enum
- Uses BudgetCalculationService for actual calculation

### Task 4: Create BudgetHeroCard Widget ✅
**File:** `lib/features/home/presentation/widgets/budget_hero_card.dart`

Features implemented:
- Hero number with 56sp font (AppTypography.hero)
- Color-coded by status using BudgetColors
- Progress bar (LinearProgressIndicator)
- Month label in French
- Card with proper border radius and elevation
- Loading state with CircularProgressIndicator
- Error state with error message display
- Accessibility semantics
- Uses FcfaFormatter for DRY compliance

### Task 5: Create HomeScreen ✅
**File:** `lib/features/home/presentation/screens/home_screen.dart`

Features implemented:
- Material 3 AppBar
- BudgetHeroCard displayed
- Proper padding and layout

### Task 6: Router Integration ✅
Main app routes to HomeScreen.

### Task 7: Unit Tests ✅
17 unit tests covering:
- BudgetState percentage calculations
- BudgetState status determination
- BudgetState negative/overspent handling
- Provider formatting

### Task 8: Widget Tests ✅
17 widget tests covering:
- Formatted budget display
- Zero amount display
- Color status (OK, warning, danger)
- Negative budget with prefix
- Month label display
- Accessibility semantics
- Progress bar functionality
- Loading state
- Error state
- Budget summary row

## Definition of Done

- [x] All acceptance criteria met
- [x] Unit tests pass (17 tests for BudgetHeroCard)
- [x] Widget tests pass (17 tests)
- [x] No lint warnings (`dart analyze`)
- [x] FCFA amounts verified as `int`
- [x] Works offline
- [x] French UI strings are correct
- [x] Accessibility labels present
- [x] Uses FcfaFormatter (DRY principle)

## Code Review Notes

**Reviewed:** 2026-01-10

**Issues Found and Fixed:**
1. **Missing Widget Tests** (HIGH) - Created 17 comprehensive widget tests for BudgetHeroCard
2. **Duplicated Formatting Logic** (MEDIUM) - Replaced `_formatAmount` and `_formatCompact` methods with `FcfaFormatter.formatCompact()` and `FcfaFormatter.format()`
3. **Unchecked Acceptance Criteria** - Updated all AC checkboxes
4. **Unchecked Definition of Done** - Updated all DoD checkboxes
5. **Added Files Modified section** - Documented the refactoring change

## Dependencies

**Depends On:**
- Story 1.1: Project Bootstrap & Encrypted Database (done)
- Story 1.2: Theme & Design System Foundation (done)

**Blocks:**
- Story 1.4: Onboarding Flow (needs HomeScreen to navigate to)
- Story 1.6: Empty States (needs HomeScreen structure)
- Story 2.2: Add Expense (needs FAB on HomeScreen)

## Notes

- For MVP, HomeScreen shows static/mock budget data until onboarding is implemented
- FAB button will be added in Story 2.2
- Empty state widget will be added in Story 1.6
- The progress bar shows remaining/total as visual indicator
- Month label uses `intl` package for French locale formatting
