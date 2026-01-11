# Story 1.5: Budget Period & Calculation Logic

Status: done

## Story

As a **user**,
I want **my budget to reset on the 1st of each month**,
So that **I start fresh each month with my full budget**.

## Acceptance Criteria

### AC1: Budget Calculation
**Given** a budget period exists for the current month
**When** the remaining budget is calculated
**Then**:
- [x] It equals: Monthly Budget - Σ(Expenses) - Σ(Planned Expenses) - Σ(Recurring Expenses Due)
- [x] The calculation completes in <100ms
- [x] The result is stored as int (FCFA, no decimals)

### AC2: Auto Period Creation
**Given** the app is opened on the 1st of a new month
**When** no budget period exists for the new month
**Then**:
- [x] A new budget period is automatically created
- [x] The previous month's data is preserved for history
- [x] The new period uses the user's configured monthly budget

### AC3: Time Inconsistency Handling
**Given** the user's device clock is manipulated backward
**When** the app detects a time inconsistency
**Then**:
- [x] A warning is shown to the user (hasTimeInconsistency flag in BudgetState)
- [x] No data corruption occurs

## Technical Requirements

### Files Created

```
lib/
└── features/
    └── budget/
        ├── data/
        │   └── repositories/
        │       └── budget_period_repository.dart
        └── domain/
            └── services/
                └── budget_calculation_service.dart

test/
└── unit/
    └── features/
        └── budget/
            ├── budget_period_repository_test.dart
            └── budget_calculation_service_test.dart
```

### Files Modified

```
lib/
├── features/
│   └── home/
│       ├── domain/
│       │   └── models/
│       │       └── budget_state.dart          # Added hasTimeInconsistency field
│       └── presentation/
│           └── providers/
│               └── budget_provider.dart       # Connected to real BudgetCalculationService
└── core/
    └── database/
        └── daos/
            └── budget_periods_dao.dart        # Fixed multiple periods bug

test/
└── unit/
    └── core/
        └── database/
            └── daos/
                └── budget_periods_dao_test.dart  # Added regression test
```

### FRs Covered
- FR2: User can see the "Remaining Budget" update immediately after any transaction entry
- FR5: System recalculates "Remaining Budget" as: Σ(Monthly Incomes) - Σ(Recurring Expenses) - Σ(One-time Expenses) - Σ(Planned Expenses)
- FR44: User can see their initial "Remaining Budget" immediately after onboarding
- FR45: System creates a new budget period on the 1st of each calendar month
- FR51: System retains all transaction history across months for pattern analysis

### Architecture Requirements
- ARCH-6: Injectable Clock provider for testable time handling
- NFR18: Atomic month transitions

### Database Tables Used
- `budget_periods` (existing from Story 1.1)
- `transactions` (will be created in Story 2.1 - for now, return 0)
- `subscriptions` (will be created in Story 3.1 - for now, return 0)
- `planned_expenses` (will be created in Story 3.5 - for now, return 0)

## Tasks

### Task 1: Create BudgetPeriodRepository ✅
**File:** `lib/features/budget/data/repositories/budget_period_repository.dart`

Responsibilities:
- Get current period
- Create new period if needed
- Get period by date range
- Update period budget

### Task 2: Create BudgetCalculationService ✅
**File:** `lib/features/budget/domain/services/budget_calculation_service.dart`

Responsibilities:
- Calculate remaining budget
- Handle period transitions
- Detect time inconsistencies

### Task 3: Update BudgetProvider ✅
Connect the real calculation service to the existing BudgetProvider.

### Task 4: Write Unit Tests ✅
- 24 tests for BudgetPeriodRepository
- 24 tests for BudgetCalculationService

## Definition of Done

- [x] All acceptance criteria met
- [x] Unit tests pass (341 total tests after code review fixes)
- [x] No lint errors (only info-level warnings for TODOs)
- [x] Calculation completes in <100ms (verified via test)
- [x] Period auto-creation works
- [x] Time inconsistency detection works

## Code Review Notes

**Reviewed:** 2026-01-10

**Issues Fixed:**
1. BudgetState factory methods no longer use DateTime.now() directly (testability)
2. Added regression test for multiple overlapping periods bug
3. Removed // ignore: unused_element comments, replaced with proper TODO format
4. Added equals/hashCode to BudgetCalculationResult
5. Fixed DAO to use id DESC as secondary sort for deterministic behavior
6. Updated this file with complete file list

## Dependencies

**Depends On:**
- Story 1.1: Project Bootstrap (done)
- Story 1.4: Onboarding Flow (review)

**Blocks:**
- Story 2.2: Add Expense (needs budget calculation)
- Story 3.4: Integrate Subscriptions in Budget
