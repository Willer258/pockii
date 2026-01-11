# Story 1.4: Onboarding Flow - Budget Setup

Status: done

## Story

As a **new user**,
I want **to complete onboarding in <2 minutes by entering my budget**,
So that **I can immediately see my "Remaining Budget"**.

## Acceptance Criteria

### AC1: Welcome Screen (Screen 1)
**Given** the app is launched for the first time
**When** the user opens the app
**Then**:
- [x] Screen 1 shows value proposition ("Sais combien tu peux dépenser")
- [x] User can swipe or tap "Suivant" to proceed
- [x] User can tap "Passer l'intro" to skip to budget setup
- [x] Page indicators show current position (1/3)

### AC2: Features Screen (Screen 2)
**Given** the user is on screen 2
**When** they view the features screen
**Then**:
- [x] Screen shows key features (tracking, patterns, notifications)
- [x] User can swipe or tap "Suivant" to proceed
- [x] User can tap "Passer l'intro" to skip to budget setup
- [x] Page indicators show current position (2/3)

### AC3: Budget Setup Screen (Screen 3)
**Given** the user reaches screen 3 (budget setup)
**When** the user enters a valid budget amount (>0)
**Then**:
- [x] The amount is formatted with space separators (e.g., "350 000")
- [x] The "Commencer" button becomes enabled
- [x] Tapping "Commencer" saves the budget and navigates to home
- [x] First budget period is created in database

### AC4: Invalid Amount Validation
**Given** the user enters an invalid amount (0 or empty)
**When** they try to proceed
**Then**:
- [x] An inline error message appears ("Montant requis")
- [x] The "Commencer" button remains disabled

### AC5: Persistence
**Given** the user completes onboarding
**When** they reopen the app
**Then**:
- [x] Onboarding is not shown again
- [x] User goes directly to HomeScreen

## Technical Requirements

### Files Created

```
lib/
└── features/
    └── onboarding/
        ├── domain/
        │   └── models/
        │       └── onboarding_state.dart
        └── presentation/
            ├── providers/
            │   └── onboarding_provider.dart
            ├── screens/
            │   └── onboarding_screen.dart
            └── widgets/
                ├── onboarding_page.dart
                ├── budget_setup_page.dart
                └── page_indicator.dart

test/
└── unit/
    └── features/
        └── onboarding/
            ├── onboarding_provider_test.dart
            └── onboarding_state_test.dart
```

### Files Modified

```
lib/
└── features/
    └── onboarding/
        └── presentation/
            └── widgets/
                └── budget_setup_page.dart    # Refactored to use FcfaFormatter
```

### FRs Covered
- FR41: User can complete initial setup in under 2 minutes
- FR42: User can enter their monthly income(s) during onboarding
- FR43: User can enter their fixed monthly expenses during onboarding
- FR57: User can see guidance on first launch before any data entry

### UX Requirements Covered
- UX-13: Onboarding flow: 3 screens (<90 seconds total)

### Database Changes
- Use `app_settings` table to store `onboarding_completed` flag
- Create first `budget_period` when onboarding completes

## Tasks

### Task 1: Create OnboardingState Model
**File:** `lib/features/onboarding/domain/models/onboarding_state.dart`

### Task 2: Create OnboardingProvider
**File:** `lib/features/onboarding/presentation/providers/onboarding_provider.dart`

### Task 3: Create OnboardingPage Widget
**File:** `lib/features/onboarding/presentation/widgets/onboarding_page.dart`

### Task 4: Create BudgetSetupPage Widget
**File:** `lib/features/onboarding/presentation/widgets/budget_setup_page.dart`

### Task 5: Create PageIndicator Widget
**File:** `lib/features/onboarding/presentation/widgets/page_indicator.dart`

### Task 6: Create OnboardingScreen
**File:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

### Task 7: Update Router with Onboarding Logic
**File:** `lib/core/router/app_router.dart`

### Task 8: Write Unit Tests

## Definition of Done

- [x] All acceptance criteria met
- [x] Unit tests pass (38 onboarding tests + 278 total tests)
- [x] No lint errors (only info-level warnings)
- [x] Onboarding completes in <90 seconds
- [x] Budget is saved to database
- [x] App remembers onboarding completed
- [x] French UI strings are correct

## Code Review Notes

**Reviewed:** 2026-01-10

**Issues Found and Fixed:**
1. **DRY Violation** (MEDIUM) - Replaced duplicated `_formatWithSpaces()` method in BudgetSetupPage with `FcfaFormatter.formatCompact()`
2. **Dead Code** (MEDIUM) - Removed unused `onboardingBudgetDisplayProvider` from onboarding_provider.dart
3. **Documentation Fix** (LOW) - Removed non-existent `onboarding_repository.dart` from Files section, added Files Modified section

**Notes:**
- Widget tests not added (only unit tests exist) - recommended for future improvement
- 38 unit tests pass and cover all critical functionality

## Dependencies

**Depends On:**
- Story 1.1: Project Bootstrap (done)
- Story 1.3: Home Screen (done)

**Blocks:**
- Story 1.5: Budget Period Calculation Logic
- Story 2.2: Add Expense (needs budget to exist)
