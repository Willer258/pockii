# Story 1.6: Empty States & First Launch Guidance

Status: done

## Story

As a **new user with no transactions**,
I want **to see helpful guidance instead of a blank screen**,
So that **I understand how to use the app**.

## Acceptance Criteria

### AC1: Home Screen Empty State
**Given** the user has completed onboarding
**When** they view the home screen with no transactions
**Then**:
- [x] `EmptyStateWidget` displays below the budget card
- [x] The message is encouraging ("Commence à tracker tes dépenses")
- [x] A visual cue points toward the FAB button
- [x] The tone is supportive, never guilt-tripping

### AC2: History Empty State
**Given** the user navigates to History with no transactions
**When** the screen loads
**Then**:
- [x] An empty state shows "Aucune transaction ce mois"
- [x] A CTA button offers "Ajouter une dépense"

### AC3: Visual Design
**Given** any empty state is displayed
**When** rendering the widget
**Then**:
- [x] Includes an illustrative icon or visual element
- [x] Uses muted colors for secondary information
- [x] Maintains accessibility (TalkBack support)
- [x] Touch targets are at least 48x48dp

## Technical Requirements

### Files Created

```
lib/
└── shared/
    └── widgets/
        └── empty_state_widget.dart

test/
└── unit/
    └── shared/
        └── widgets/
            └── empty_state_widget_test.dart
```

### Files Modified

```
lib/
└── features/
    └── home/
        └── presentation/
            └── screens/
                └── home_screen.dart    # Integrated EmptyStateWidget
```

### FRs Covered
- FR56: User can see meaningful empty state when no transactions exist
- FR57: User can see guidance on first launch before any data entry

### UX Requirements
- UX-10: EmptyStateWidget with supportive messaging

## Tasks

### Task 1: Create EmptyStateWidget ✅
**File:** `lib/shared/widgets/empty_state_widget.dart`

Features implemented:
- Configurable icon, title, subtitle, and optional CTA button
- Animated FAB pointer that bounces to draw attention
- Semantic labels for accessibility

### Task 2: Create Predefined Empty State Variants ✅
Factory methods created:
- `EmptyStateWidget.home()` - Home screen variant with FAB pointer
- `EmptyStateWidget.history()` - History screen variant with CTA button
- `EmptyStateWidget.patternsLocked(daysRemaining)` - Patterns locked state
- `EmptyStateWidget.patternsNoData()` - Patterns no data state

### Task 3: Integrate into HomeScreen ✅
Updated `HomeScreen` to show empty state below BudgetHeroCard

### Task 4: Write Unit Tests ✅
- 14 tests covering all variants and behaviors

## Definition of Done

- [x] All acceptance criteria met
- [x] Unit tests pass (344 total tests after code review fixes)
- [x] No lint errors
- [x] Widget renders correctly in all variants
- [x] Accessibility labels present
- [x] French UI strings correct (singular/plural handling)
- [x] Touch targets verified at 48x48dp minimum

## Code Review Notes

**Reviewed:** 2026-01-10

**Issues Fixed:**
1. French grammar: "1 jours" → "1 jour" (singular/plural handling)
2. Added explicit minimumSize: 48x48 to FilledButton for touch targets
3. Fixed test expecting wrong text ("1 jours" → "1 jour")
4. Added test for plural form ("2 jours")
5. Added animation disposal test
6. Added touch target size verification test
7. Added Files Modified section to story

## Dependencies

**Depends On:**
- Story 1.1: Project Bootstrap (done)
- Story 1.2: Theme (done)
- Story 1.3: Home Screen (review)

**Blocks:**
- Epic 2: Transaction History needs empty state
- Epic 5: Patterns screen needs locked/empty state
