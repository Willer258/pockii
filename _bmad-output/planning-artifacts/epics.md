---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - planning-artifacts/prd.md
  - planning-artifacts/architecture.md
  - planning-artifacts/ux-design-specification.md
project_name: accountapp
user_name: Wilfriedhouinlindjonon
date: '2026-01-07'
---

# accountapp - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for accountapp, decomposing the requirements from the PRD, Architecture, and UX Design Specification into implementable stories.

## Requirements Inventory

### Functional Requirements

**Budget Visibility (Core Value) — FR1-FR5**
- FR1: User can view their current "Remaining Budget" as a single prominent number
- FR2: User can see the "Remaining Budget" update immediately after any transaction entry
- FR3: User can see color-coded budget status (green: OK, orange: warning, red: danger)
- FR4: User can understand their budget status at a glance without scrolling or navigation
- FR5: System recalculates "Remaining Budget" as: Σ(Monthly Incomes) - Σ(Recurring Expenses) - Σ(One-time Expenses) - Σ(Planned Expenses)

**Transaction Management — FR6-FR17**
- FR6: User can add a new expense with amount, category, and optional note
- FR7: User can add a new income with amount, category, and optional note
- FR8: User can complete a transaction entry in under 10 seconds
- FR9: User can select from predefined expense categories (Transport, Food, Leisure, Family, Subscriptions, Other)
- FR10: User can select from predefined income categories (Salary, Freelance, Reimbursement, Gift, Other)
- FR11: User can view a chronological list of all transactions
- FR12: User can edit an existing transaction (amount, category, note)
- FR13: User can delete a transaction
- FR14: User can see transaction date and time for each entry
- FR15: System treats all amounts as integers (FCFA has no decimals)
- FR16: User can backdate a transaction to a previous date within the current month
- FR17: System validates transaction amounts (positive integers only, rejects zero or negative)

**Pattern Analysis ("Your Patterns") — FR18-FR23**
- FR18: System unlocks "Your Patterns" feature after 30 days of data collection
- FR19: User can view average spending by category
- FR20: User can see their top 3 expense categories
- FR21: User can compare current month spending vs previous month
- FR22: User can see total income vs total expenses for the current month
- FR23: User can see day-of-week spending distribution (e.g., "You spend 2x more on Fridays")

**Subscription & Recurring Expense Management — FR24-FR29**
- FR24: User can add a recurring expense (tontine, subscription, family obligation)
- FR25: User can specify due date and frequency for recurring expenses
- FR26: User can view a list of all active subscriptions/recurring expenses
- FR27: User can edit or delete a recurring expense
- FR28: System integrates recurring expenses into "Remaining Budget" calculation
- FR29: System sends reminders before recurring expense due dates

**Planned Future Expenses — FR30-FR34**
- FR30: User can add a planned future expense (one-time, not recurring)
- FR31: User can specify the expected date for a planned expense
- FR32: System deducts planned expenses from "Remaining Budget" before they occur
- FR33: User can convert a planned expense to an actual transaction when paid
- FR34: User can cancel or modify a planned expense

**Notification & Alerts — FR35-FR40**
- FR35: User can receive budget warning notification when remaining budget drops below 30%
- FR36: User can receive budget alert notification when remaining budget drops below 10%
- FR37: User can receive subscription reminder notification before due date
- FR38: User can receive streak celebration notification upon achieving 7-day streak
- FR39: User can configure notification preferences per notification type
- FR40: System limits notifications to maximum 2 per day

**Onboarding & Setup — FR41-FR45**
- FR41: User can complete initial setup in under 2 minutes
- FR42: User can enter their monthly income(s) during onboarding
- FR43: User can enter their fixed monthly expenses during onboarding
- FR44: User can see their initial "Remaining Budget" immediately after onboarding
- FR45: System creates a new budget period on the 1st of each calendar month

**Data Security & Privacy — FR46-FR51**
- FR46: System stores all data locally on device (no cloud sync for MVP)
- FR47: System encrypts the local database using SQLCipher
- FR48: System stores encryption key securely in Android Keystore
- FR49: User can use the app 100% offline without any functionality loss
- FR50: System never transmits user financial data to external servers
- FR51: System retains all transaction history across months for pattern analysis

**User Engagement & Gamification — FR52-FR55**
- FR52: System tracks consecutive days of transaction entry (streak)
- FR53: User can view their current streak count
- FR54: User receives visual celebration upon achieving 7-day streak
- FR55: User can see month-end summary showing final budget balance

**Empty States & Edge Cases — FR56-FR57**
- FR56: User can see meaningful empty state when no transactions exist
- FR57: User can see guidance on first launch before any data entry

### NonFunctional Requirements

**Performance — NFR1-NFR7**
- NFR1: Cold start time < 3 seconds (Tecno Spark 8)
- NFR2: "Remaining Budget" update < 100ms
- NFR3: Transaction entry flow < 10 seconds total
- NFR4: Screen transitions < 300ms
- NFR5: App memory usage < 150MB RAM
- NFR6: APK size < 30MB
- NFR7: Minimal battery impact (WorkManager 15min intervals)

**Security — NFR8-NFR13**
- NFR8: Database encryption AES-256 via SQLCipher
- NFR9: Encryption key storage in Android Keystore
- NFR10: Zero network calls (no data transmission)
- NFR11: No sensitive data logging
- NFR12: Screen capture protection (FLAG_SECURE) - optional
- NFR13: Biometric unlock - post-MVP

**Reliability — NFR14-NFR18**
- NFR14: Zero data loss (SQLite WAL mode)
- NFR15: Full crash recovery (state persistence)
- NFR16: 100% offline availability
- NFR17: Database integrity (self-healing)
- NFR18: Atomic month transitions

**Accessibility — NFR19-NFR22**
- NFR19: Touch targets minimum 48x48dp
- NFR20: Color contrast 4.5:1 minimum (WCAG AA)
- NFR21: Support system font scaling
- NFR22: TalkBack screen reader basic support

**Localization — NFR23-NFR27**
- NFR23: UI language French only (MVP)
- NFR24: Number format with space thousands separator (350 000 FCFA)
- NFR25: Date format DD/MM/YYYY
- NFR26: Currency FCFA (XOF) integers only
- NFR27: Architecture ready for future languages

### Additional Requirements

**From Architecture Document:**

- **ARCH-1:** Project initialization with Custom Bootstrap (flutter create + dependencies)
- **ARCH-2:** Database layer with drift 2.x + SQLCipher encryption
- **ARCH-3:** Feature-based folder structure (lib/features/{feature}/data|domain|presentation)
- **ARCH-4:** Riverpod 2.x state management with StateNotifierProvider pattern
- **ARCH-5:** go_router declarative navigation with deep link support
- **ARCH-6:** Injectable Clock provider for testable time handling (never DateTime.now() direct)
- **ARCH-7:** FCFA amounts as int only (no double anywhere)
- **ARCH-8:** Custom exception types (DatabaseException, ValidationException, StorageException)
- **ARCH-9:** WorkManager for background tasks (streak check, month transition)
- **ARCH-10:** 80% test coverage on critical paths (budget calculation, data persistence)
- **ARCH-11:** In-memory drift database for unit tests

**From UX Design Specification:**

- **UX-1:** BudgetHeroCard component with 56sp hero number and color animation
- **UX-2:** TransactionBottomSheet with 3-tap flow (FAB → Amount+Category → Submit)
- **UX-3:** FAB centered position (Wave-style, not Material default)
- **UX-4:** Material Design 3 with custom theme (explicit ColorScheme, not fromSeed)
- **UX-5:** Inter font family (~100KB)
- **UX-6:** 8dp spacing base, 16dp border radius
- **UX-7:** CategoryChip component with 6 predefined categories (icons)
- **UX-8:** StreakBadge component with milestone animations (7, 14, 30 days)
- **UX-9:** PatternCard component for category breakdown display
- **UX-10:** EmptyStateWidget with supportive messaging
- **UX-11:** Semantic labels for TalkBack accessibility
- **UX-12:** Haptic feedback on transaction confirmation
- **UX-13:** Onboarding flow: 3 screens (<90 seconds total)
- **UX-14:** Swipe gestures on history items (left=delete, right=edit)
- **UX-15:** Bottom Navigation with 4 items (Home, History, Patterns, Settings)

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1-FR5 | Epic 1 | Budget Visibility (core) |
| FR6-FR17 | Epic 2 | Transaction Management |
| FR18-FR23 | Epic 5 | Pattern Analysis |
| FR24-FR29 | Epic 3 | Subscriptions |
| FR30-FR34 | Epic 3 | Planned Expenses |
| FR35-FR40 | Epic 4 | Notifications |
| FR41-FR45 | Epic 1 | Onboarding |
| FR46-FR51 | Epic 1 | Data Security |
| FR52-FR55 | Epic 4 | Gamification |
| FR56-FR57 | Epic 1 | Empty States |

**Coverage:** 57/57 FRs (100%)

## Epic List

### Epic 1: Foundation & First Budget View
L'utilisateur peut voir son "Reste à Vivre" pour la première fois après une configuration rapide (<2 minutes).

**User Outcome:** En <2 minutes, l'utilisateur voit le nombre central qui répond à "Combien puis-je dépenser?"

**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR41, FR42, FR43, FR44, FR45, FR46, FR47, FR48, FR49, FR50, FR51, FR56, FR57

**Additional Requirements:** ARCH-1, ARCH-2, ARCH-3, ARCH-4, ARCH-5, ARCH-6, ARCH-7, ARCH-8, UX-1, UX-4, UX-5, UX-6, UX-13

---

### Epic 2: Transaction Tracking
L'utilisateur peut ajouter, éditer et supprimer des transactions pour mettre à jour son budget en temps réel.

**User Outcome:** En <10 secondes, l'utilisateur log une dépense et voit son budget se mettre à jour instantanément.

**FRs covered:** FR6, FR7, FR8, FR9, FR10, FR11, FR12, FR13, FR14, FR15, FR16, FR17

**Additional Requirements:** UX-2, UX-3, UX-7, UX-12, UX-14, UX-15

---

### Epic 3: Recurring Expenses & Planning
L'utilisateur peut gérer ses obligations récurrentes (tontines, abonnements) et planifier des dépenses futures.

**User Outcome:** L'utilisateur voit ses obligations intégrées dans son "Reste à Vivre" et peut anticiper les dépenses à venir.

**FRs covered:** FR24, FR25, FR26, FR27, FR28, FR29, FR30, FR34, FR31, FR32, FR33

---

### Epic 4: Notifications & Engagement
L'utilisateur reçoit des alertes préventives et est motivé par le système de streaks.

**User Outcome:** L'utilisateur ne découvre plus son budget bas par surprise et est encouragé à maintenir l'habitude de tracking.

**FRs covered:** FR35, FR36, FR37, FR38, FR39, FR40, FR52, FR53, FR54, FR55

**Additional Requirements:** ARCH-9, UX-8, UX-10

---

### Epic 5: Pattern Analysis ("Tes Patterns")
Après 30 jours, l'utilisateur découvre ses habitudes de dépenses cachées.

**User Outcome:** L'utilisateur a son "Aha moment" — il voit pour la première fois ses patterns comportementaux.

**FRs covered:** FR18, FR19, FR20, FR21, FR22, FR23

**Additional Requirements:** UX-9

---

## Epic 1: Foundation & First Budget View

L'utilisateur peut voir son "Reste à Vivre" pour la première fois après une configuration rapide (<2 minutes).

### Story 1.1: Project Bootstrap & Encrypted Database

As a **developer**,
I want **the Flutter project initialized with drift + SQLCipher encryption**,
So that **all future features have a secure, type-safe database foundation**.

**Acceptance Criteria:**

**Given** a fresh development environment
**When** the project is created with `flutter create accountapp`
**Then** the project compiles successfully for Android
**And** drift 2.x is configured with code generation
**And** SQLCipher encryption is enabled with AES-256
**And** encryption key is stored in Android Keystore
**And** `FcfaFormatter` utility class exists for int-only currency handling
**And** `clockProvider` is implemented for injectable time (never `DateTime.now()` direct)

**Technical Notes:**
- Creates: `budget_periods` table, `app_settings` table
- Covers: ARCH-1, ARCH-2, ARCH-6, ARCH-7, FR46, FR47, FR48, FR49, FR50

---

### Story 1.2: Theme & Design System Foundation

As a **developer**,
I want **Material 3 theme with custom AppColors and AppTypography**,
So that **all screens have consistent visual design from day one**.

**Acceptance Criteria:**

**Given** the project structure exists
**When** theme classes are implemented
**Then** `AppTheme` provides light ThemeData with explicit ColorScheme
**And** `AppColors` defines primary (#2E7D32), secondary (#1565C0), budget status colors
**And** `AppTypography` uses Inter font with 56sp hero size
**And** `BudgetColors` provides ok/warning/danger color constants
**And** 8dp spacing base is defined in constants
**And** dark mode structure is prepared (not implemented)

**Technical Notes:**
- Creates: `lib/core/theme/` folder structure
- Covers: UX-4, UX-5, UX-6

---

### Story 1.3: Home Screen with BudgetHeroCard

As a **user**,
I want **to see my "Remaining Budget" as a big, color-coded number on the home screen**,
So that **I know exactly how much I can spend at a glance**.

**Acceptance Criteria:**

**Given** the app is launched and user has completed onboarding
**When** the home screen loads
**Then** `BudgetHeroCard` displays the remaining budget in 56sp font
**And** the card shows current month label (e.g., "Janvier 2026")
**And** the card shows a progress bar (remaining/total)
**And** the number color reflects budget status (green >30%, orange 10-30%, red <10%)
**And** the card has semantic labels for TalkBack accessibility
**And** the screen loads in <100ms (local data)

**Given** the budget is negative (overspent)
**When** viewing the home screen
**Then** the number displays with a "-" prefix
**And** the color is red

**Technical Notes:**
- Creates: `BudgetHeroCard` widget, `HomeScreen`
- Covers: FR1, FR3, FR4, UX-1, UX-11

---

### Story 1.4: Onboarding Flow - Budget Setup

As a **new user**,
I want **to complete onboarding in <2 minutes by entering my budget**,
So that **I can immediately see my "Remaining Budget"**.

**Acceptance Criteria:**

**Given** the app is launched for the first time
**When** the user opens the app
**Then** screen 1 shows value proposition ("Sais combien tu peux dépenser")
**And** user can swipe or tap "Suivant" to proceed
**And** user can tap "Passer l'intro" to skip to budget setup

**Given** the user reaches screen 3 (budget setup)
**When** the user enters a valid budget amount (>0)
**Then** the amount is formatted with space separators (e.g., "250 000")
**And** the "Commencer" button becomes enabled
**And** tapping "Commencer" saves the budget and navigates to home

**Given** the user enters an invalid amount (0 or empty)
**When** they try to proceed
**Then** an inline error message appears
**And** the "Commencer" button remains disabled

**Technical Notes:**
- Creates: 3 onboarding screens, `OnboardingProvider`
- Covers: FR41, FR42, FR43, FR57, UX-13

---

### Story 1.5: Budget Period & Calculation Logic

As a **user**,
I want **my budget to reset on the 1st of each month**,
So that **I start fresh each month with my full budget**.

**Acceptance Criteria:**

**Given** a budget period exists for the current month
**When** the remaining budget is calculated
**Then** it equals: Monthly Budget - Σ(Expenses) - Σ(Planned Expenses) - Σ(Recurring Expenses Due)
**And** the calculation completes in <100ms
**And** the result is stored as int (FCFA, no decimals)

**Given** the app is opened on the 1st of a new month
**When** no budget period exists for the new month
**Then** a new budget period is automatically created
**And** the previous month's data is preserved for history
**And** the new period uses the user's configured monthly budget

**Given** the user's device clock is manipulated backward
**When** the app detects a time inconsistency
**Then** a warning is shown to the user
**And** no data corruption occurs

**Technical Notes:**
- Creates: `BudgetCalculationService`, `BudgetPeriodRepository`
- Covers: FR2, FR5, FR44, FR45, FR51, ARCH-6, NFR18

---

### Story 1.6: Empty States & First Launch Guidance

As a **new user with no transactions**,
I want **to see helpful guidance instead of a blank screen**,
So that **I understand how to use the app**.

**Acceptance Criteria:**

**Given** the user has completed onboarding
**When** they view the home screen with no transactions
**Then** `EmptyStateWidget` displays below the budget card
**And** the message is encouraging ("Commence à tracker tes dépenses")
**And** a visual cue points toward the FAB button
**And** the tone is supportive, never guilt-tripping

**Given** the user navigates to History with no transactions
**When** the screen loads
**Then** an empty state shows "Aucune transaction ce mois"
**And** a CTA button offers "Ajouter une dépense"

**Technical Notes:**
- Creates: `EmptyStateWidget` with variants
- Covers: FR56, FR57, UX-10

---

## Epic 2: Transaction Tracking

L'utilisateur peut ajouter, éditer et supprimer des transactions pour mettre à jour son budget en temps réel.

### Story 2.1: Transactions Database Table & Repository

As a **developer**,
I want **the transactions table and repository implemented**,
So that **transaction data can be persisted and queried efficiently**.

**Acceptance Criteria:**

**Given** the database exists from Epic 1
**When** the transactions table is created
**Then** it stores: id, amount_fcfa (int), category, type (expense/income), note, date, created_at
**And** `TransactionsDao` provides CRUD operations
**And** `TransactionRepository` abstracts the DAO for the presentation layer
**And** all amounts are stored as int (FCFA, no decimals)
**And** queries support filtering by date range and category

**Technical Notes:**
- Creates: `transactions` table, `TransactionsDao`, `TransactionRepository`
- Covers: FR15, ARCH-2

---

### Story 2.2: Add Expense with Bottom Sheet

As a **user**,
I want **to add an expense in <10 seconds using a bottom sheet**,
So that **I can quickly log my spending without friction**.

**Acceptance Criteria:**

**Given** the user is on the home screen
**When** they tap the centered FAB (+)
**Then** a bottom sheet slides up with the transaction form
**And** the numeric keypad is visible immediately (no tap to focus)
**And** amount displays with space separators as typed (e.g., "5 000")

**Given** the user has entered an amount
**When** they select a category chip and tap "Ajouter"
**Then** the transaction is saved to the database
**And** the bottom sheet closes
**And** haptic feedback confirms the action
**And** a snackbar shows "Dépense ajoutée"
**And** the budget hero updates within 100ms

**Given** no category is selected
**When** the user taps "Ajouter"
**Then** the category defaults to "Autre"

**Technical Notes:**
- Creates: `TransactionBottomSheet`, `NumericKeypad`
- Covers: FR6, FR8, FR9, UX-2, UX-3, UX-12

---

### Story 2.3: Add Income Flow

As a **user**,
I want **to add income (salary, freelance, gifts)**,
So that **my budget reflects money coming in, not just going out**.

**Acceptance Criteria:**

**Given** the user opens the transaction bottom sheet
**When** they toggle to "Revenu" mode
**Then** income-specific categories appear (Salaire, Freelance, Remboursement, Cadeau, Autre)
**And** the form title changes to "Nouveau revenu"

**Given** the user submits an income
**When** saved successfully
**Then** the transaction is stored with type "income"
**And** the budget increases by the income amount
**And** income appears in green in the history

**Technical Notes:**
- Modifies: `TransactionBottomSheet` to support income mode
- Covers: FR7, FR10

---

### Story 2.4: Category Selection Component

As a **user**,
I want **to select a category with a single tap on a visual chip**,
So that **I can categorize my transaction without typing**.

**Acceptance Criteria:**

**Given** the bottom sheet is open
**When** the category chips are displayed
**Then** 6 expense categories show with icons: 🍽️ Food, 🚗 Transport, 🛒 Shopping, 🎉 Fun, 💊 Health, 📦 Other
**And** each chip has a 48dp touch target
**And** only one category can be selected at a time
**And** selected chip shows filled style, others show outlined

**Given** the user taps a category
**When** it's selected
**Then** a scale animation (150ms) provides visual feedback
**And** the previous selection (if any) is deselected

**Technical Notes:**
- Creates: `CategoryChip` widget, `CategoryChipRow`
- Covers: UX-7

---

### Story 2.5: Transaction History Screen

As a **user**,
I want **to see a chronological list of all my transactions**,
So that **I can review and verify my spending**.

**Acceptance Criteria:**

**Given** the user navigates to the History tab
**When** the screen loads
**Then** transactions are grouped by date (Aujourd'hui, Hier, date for older)
**And** each transaction shows: category icon, description/note, amount, time
**And** expenses show negative amounts in default color
**And** incomes show positive amounts in green
**And** the list scrolls smoothly with 1000+ items (ListView.builder)

**Given** the bottom navigation exists
**When** the user taps the History icon
**Then** navigation occurs with slide transition (300ms)
**And** the History tab shows as active (filled icon)

**Technical Notes:**
- Creates: `HistoryScreen`, `TransactionTile`, bottom navigation setup
- Covers: FR11, FR14, UX-15

---

### Story 2.6: Edit Existing Transaction

As a **user**,
I want **to edit a transaction I entered incorrectly**,
So that **my budget remains accurate**.

**Acceptance Criteria:**

**Given** the user is viewing the history
**When** they swipe right on a transaction
**Then** an edit action is revealed (blue background)
**And** tapping opens the bottom sheet pre-filled with transaction data

**Given** the user modifies and saves the transaction
**When** "Modifier" is tapped
**Then** the transaction is updated in the database
**And** the budget recalculates immediately
**And** a snackbar confirms "Transaction modifiée"

**Given** the user backdates a transaction
**When** they select a date in the past (within current month)
**Then** the transaction is saved with that date
**And** appears in the correct position in history

**Technical Notes:**
- Modifies: `TransactionBottomSheet` for edit mode, `TransactionTile` for swipe
- Covers: FR12, FR16, UX-14

---

### Story 2.7: Delete Transaction with Swipe

As a **user**,
I want **to delete a transaction by swiping**,
So that **I can remove errors quickly**.

**Acceptance Criteria:**

**Given** the user is viewing the history
**When** they swipe left on a transaction past 30% threshold
**Then** the delete action is revealed (red background with trash icon)
**And** releasing triggers deletion

**Given** the user confirms deletion (swipe completes)
**When** the transaction is deleted
**Then** it's removed from the database
**And** the budget recalculates immediately
**And** a snackbar shows "Transaction supprimée" with "Annuler" action
**And** the item animates out of the list

**Given** the user taps "Annuler" on the snackbar
**When** within 4 seconds
**Then** the transaction is restored
**And** the budget recalculates

**Technical Notes:**
- Creates: `Dismissible` wrapper for `TransactionTile`
- Covers: FR13, UX-14

---

### Story 2.8: Transaction Amount Validation

As a **user**,
I want **the app to prevent invalid transaction amounts**,
So that **my data stays clean and accurate**.

**Acceptance Criteria:**

**Given** the user enters 0 as an amount
**When** they try to submit
**Then** the "Ajouter" button remains disabled
**And** an inline error shows "Montant requis"

**Given** the user enters a negative number (via edge case)
**When** validation runs
**Then** the amount is rejected
**And** only positive integers are accepted

**Given** the user enters a very large amount (>999,999,999)
**When** they type
**Then** input is capped at 9 digits
**And** formatting continues to work correctly

**Technical Notes:**
- Creates: Validation logic in `TransactionFormNotifier`
- Covers: FR17, ARCH-8

---

## Epic 3: Recurring Expenses & Planning

L'utilisateur peut gérer ses obligations récurrentes (tontines, abonnements) et planifier des dépenses futures.

### Story 3.1: Subscriptions Database Table & Repository

As a **developer**,
I want **the subscriptions table and repository implemented**,
So that **recurring expenses can be persisted and managed**.

**Acceptance Criteria:**

**Given** the database exists from Epic 1
**When** the subscriptions table is created
**Then** it stores: id, name, amount_fcfa (int), category, frequency (monthly/weekly/yearly), due_day, is_active, created_at
**And** `SubscriptionsDao` provides CRUD operations
**And** `SubscriptionRepository` abstracts the DAO for the presentation layer
**And** queries support filtering by active status and due date range

**Technical Notes:**
- Creates: `subscriptions` table, `SubscriptionsDao`, `SubscriptionRepository`
- Covers: ARCH-2, FR24

---

### Story 3.2: Add & Edit Subscription

As a **user**,
I want **to add a recurring expense (tontine, subscription, family obligation)**,
So that **my budget accounts for my regular commitments**.

**Acceptance Criteria:**

**Given** the user navigates to Settings > Abonnements
**When** they tap "Ajouter un abonnement"
**Then** a form appears with: name, amount, category, frequency (mensuel/hebdo/annuel), due day
**And** the form validates required fields (name, amount, frequency)
**And** frequency defaults to "Mensuel"

**Given** the user submits a valid subscription
**When** saved successfully
**Then** the subscription appears in the list
**And** it's marked as active
**And** the budget calculation includes this subscription

**Given** the user taps an existing subscription
**When** the edit form opens
**Then** all fields are pre-filled
**And** user can modify any field
**And** user can deactivate (not delete) the subscription

**Technical Notes:**
- Creates: `SubscriptionFormScreen`, `SubscriptionFormNotifier`
- Covers: FR24, FR25, FR27

---

### Story 3.3: Subscriptions List Screen

As a **user**,
I want **to see all my active subscriptions in one place**,
So that **I can track my recurring financial obligations**.

**Acceptance Criteria:**

**Given** the user navigates to Settings > Abonnements
**When** the screen loads
**Then** all active subscriptions are listed
**And** each item shows: name, amount (formatted), frequency, next due date
**And** total monthly recurring expenses is shown at the top
**And** inactive subscriptions are hidden by default

**Given** the user toggles "Afficher inactifs"
**When** the toggle is enabled
**Then** inactive subscriptions appear (grayed out)
**And** user can reactivate them

**Technical Notes:**
- Creates: `SubscriptionsListScreen`, `SubscriptionTile`
- Covers: FR26

---

### Story 3.4: Integrate Subscriptions in Budget Calculation

As a **user**,
I want **my recurring expenses automatically deducted from my budget**,
So that **I see my true "Reste à Vivre" after obligations**.

**Acceptance Criteria:**

**Given** active subscriptions exist
**When** the budget is calculated
**Then** Remaining = Monthly Budget - Σ(Active Subscriptions due this period) - Σ(Expenses)
**And** monthly subscriptions are fully deducted on the 1st
**And** weekly subscriptions are prorated for remaining weeks
**And** yearly subscriptions are prorated monthly (amount/12)

**Given** a subscription is deactivated mid-month
**When** the budget recalculates
**Then** only the prorated amount already "consumed" is deducted
**And** future periods exclude this subscription

**Technical Notes:**
- Modifies: `BudgetCalculationService`
- Covers: FR28

---

### Story 3.5: Planned Expenses Database & Management

As a **user**,
I want **to add a planned future expense (one-time)**,
So that **my budget reserves money for upcoming purchases**.

**Acceptance Criteria:**

**Given** the user is on the home screen
**When** they tap "Planifier une dépense" (or via Settings)
**Then** a form appears with: description, amount, expected date
**And** the date must be in the future (current month or later)
**And** validation prevents past dates

**Given** the user submits a valid planned expense
**When** saved successfully
**Then** the planned expense appears in a "Dépenses prévues" section
**And** it shows: description, amount, days until due
**And** the budget immediately decreases by this amount

**Given** multiple planned expenses exist
**When** viewing the list
**Then** they are sorted by date (nearest first)
**And** each shows a progress indicator (days remaining)

**Technical Notes:**
- Creates: `planned_expenses` table, `PlannedExpenseRepository`, `PlannedExpenseFormScreen`
- Covers: FR30, FR31, FR32

---

### Story 3.6: Planned Expense Integration & Conversion

As a **user**,
I want **to convert a planned expense to an actual transaction when I pay it**,
So that **my budget tracking stays accurate**.

**Acceptance Criteria:**

**Given** a planned expense exists
**When** the user taps "Marquer comme payé"
**Then** a confirmation dialog appears with the planned amount
**And** user can adjust the actual amount if different
**And** confirming creates a transaction with the planned details

**Given** the user confirms conversion
**When** the transaction is created
**Then** the planned expense is marked as "converted"
**And** it no longer appears in active planned expenses
**And** the budget calculation removes the planned deduction (already in expenses)

**Given** the user wants to cancel a planned expense
**When** they tap "Annuler"
**Then** the planned expense is deleted
**And** the reserved budget is released

**Technical Notes:**
- Modifies: `PlannedExpenseRepository`, creates conversion flow
- Covers: FR33, FR34

---

### Story 3.7: Settings Screen with Budget Configuration

As a **user**,
I want **to modify my monthly budget and view my settings**,
So that **I can adjust my financial configuration as my situation changes**.

**Acceptance Criteria:**

**Given** the user navigates to Settings (bottom nav)
**When** the screen loads
**Then** it shows sections: Budget mensuel, Abonnements, Dépenses prévues, À propos
**And** current monthly budget is displayed with "Modifier" action
**And** subscription count and total are shown
**And** planned expense count is shown

**Given** the user taps "Modifier" on budget
**When** the edit dialog opens
**Then** the current budget is pre-filled
**And** user can enter a new amount
**And** saving updates the budget for the current period

**Given** the budget is modified mid-month
**When** the change is saved
**Then** the remaining budget recalculates immediately
**And** historical data is not affected

**Technical Notes:**
- Creates: `SettingsScreen`, navigation integration
- Covers: FR42, FR43, UX-15

---

## Epic 4: Notifications & Engagement

L'utilisateur reçoit des alertes préventives et est motivé par le système de streaks.

### Story 4.1: Streak Tracking Database & Logic

As a **developer**,
I want **the streak tracking system implemented**,
So that **user engagement can be measured and rewarded**.

**Acceptance Criteria:**

**Given** the database exists
**When** streak tracking is implemented
**Then** `user_streaks` table stores: current_streak, longest_streak, last_activity_date
**And** `StreakService` calculates streak based on transaction activity
**And** a day counts if at least 1 transaction was logged
**And** streak resets to 0 after 1 day of inactivity

**Given** the app opens on a new day
**When** the user has a transaction from yesterday
**Then** the streak continues
**And** `current_streak` increments by 1 when first transaction today

**Technical Notes:**
- Creates: `user_streaks` table, `StreakService`, `StreakRepository`
- Covers: FR52, ARCH-9

---

### Story 4.2: Streak Display with StreakBadge

As a **user**,
I want **to see my current streak count on the home screen**,
So that **I'm motivated to maintain my daily logging habit**.

**Acceptance Criteria:**

**Given** the user has an active streak
**When** the home screen loads
**Then** `StreakBadge` displays "🔥 X jours" near the top
**And** the badge has a subtle pulse animation when streak > 0
**And** tapping the badge shows streak details (current, longest)

**Given** the streak is 0
**When** the home screen loads
**Then** the badge shows "🔥 0 jour" in muted color
**And** a tooltip suggests "Ajoute une dépense pour démarrer"

**Given** the streak reaches a milestone (7, 14, 30 days)
**When** the user opens the app
**Then** a celebration animation plays (confetti/scale)
**And** a congratulatory message appears

**Technical Notes:**
- Creates: `StreakBadge` widget, milestone animations
- Covers: FR53, FR54, UX-8

---

### Story 4.3: WorkManager Background Tasks Setup

As a **developer**,
I want **WorkManager configured for background tasks**,
So that **notifications and streak checks work even when app is closed**.

**Acceptance Criteria:**

**Given** the app is installed
**When** WorkManager initializes
**Then** a periodic task runs every 15 minutes (minimum Android allows)
**And** tasks include: streak check, budget threshold check, subscription reminders
**And** battery optimization is respected (no aggressive wake)

**Given** the device reboots
**When** Android restarts
**Then** WorkManager tasks are automatically re-scheduled
**And** no user action is required

**Technical Notes:**
- Creates: `BackgroundTaskManager`, WorkManager configuration
- Covers: ARCH-9, NFR7

---

### Story 4.4: Budget Warning & Alert Notifications

As a **user**,
I want **to receive notifications when my budget is running low**,
So that **I can adjust my spending before it's too late**.

**Acceptance Criteria:**

**Given** the user's remaining budget drops below 30%
**When** the threshold is first crossed
**Then** a local notification is sent: "⚠️ Budget attention - Il te reste X FCFA"
**And** the notification is marked as "warning" type
**And** no duplicate notification for same threshold crossing

**Given** the remaining budget drops below 10%
**When** the threshold is first crossed
**Then** a high-priority notification is sent: "🚨 Budget critique - Il te reste X FCFA"
**And** the notification uses a different icon/color (red)

**Given** the budget recovers above threshold
**When** it drops again later
**Then** a new notification is triggered (threshold reset)

**Technical Notes:**
- Creates: `BudgetNotificationService`, threshold tracking
- Covers: FR35, FR36

---

### Story 4.5: Subscription Reminder Notifications

As a **user**,
I want **reminders before my subscriptions are due**,
So that **I can prepare for upcoming payments**.

**Acceptance Criteria:**

**Given** a subscription has due_day = 15
**When** it's the 13th of the month (2 days before)
**Then** a notification is sent: "📅 [Subscription Name] - X FCFA dans 2 jours"
**And** the reminder respects the user's notification preferences

**Given** a subscription is due today
**When** the day starts
**Then** a notification is sent: "📅 [Subscription Name] - X FCFA aujourd'hui"
**And** tapping the notification opens the app to subscriptions

**Given** multiple subscriptions are due on the same day
**When** notifications are generated
**Then** they are grouped: "📅 3 abonnements - Total X FCFA"

**Technical Notes:**
- Creates: `SubscriptionReminderService`
- Covers: FR29, FR37

---

### Story 4.6: Streak Celebration Notification

As a **user**,
I want **to be congratulated when I achieve streak milestones**,
So that **I feel rewarded for consistent tracking**.

**Acceptance Criteria:**

**Given** the user reaches 7-day streak
**When** the milestone is achieved
**Then** a celebration notification is sent: "🎉 7 jours de suite! Tu gères!"
**And** the in-app celebration triggers on next app open

**Given** the user reaches 14-day streak
**When** the milestone is achieved
**Then** notification: "🔥 14 jours! Tu deviens un pro!"

**Given** the user reaches 30-day streak
**When** the milestone is achieved
**Then** notification: "👑 30 jours! Maître du budget!"
**And** a special badge is unlocked

**Technical Notes:**
- Creates: `StreakCelebrationService`, milestone definitions
- Covers: FR38, FR54

---

### Story 4.7: Notification Preferences Screen

As a **user**,
I want **to configure which notifications I receive**,
So that **I'm not overwhelmed by unwanted alerts**.

**Acceptance Criteria:**

**Given** the user navigates to Settings > Notifications
**When** the screen loads
**Then** toggle switches appear for: Budget warnings, Subscription reminders, Streak celebrations
**And** each toggle has a description of what it controls
**And** all toggles default to ON for new users

**Given** the user disables "Budget warnings"
**When** the toggle is turned OFF
**Then** the preference is saved immediately
**And** no budget threshold notifications are sent
**And** the daily notification limit doesn't apply to disabled types

**Technical Notes:**
- Creates: `NotificationPreferencesScreen`, preferences storage
- Covers: FR39

---

### Story 4.8: Notification Frequency Limiter

As a **user**,
I want **the app to limit notifications to maximum 2 per day**,
So that **I'm not spammed with alerts**.

**Acceptance Criteria:**

**Given** 2 notifications have been sent today
**When** a 3rd notification trigger occurs
**Then** it's queued for the next day (priority queue)
**And** the user is never bothered with >2 notifications/day

**Given** a high-priority alert (budget <10%)
**When** it triggers after the limit is reached
**Then** it bypasses the limit (safety override)
**And** a maximum of 3 notifications can occur in this edge case

**Given** it's a new calendar day
**When** midnight passes
**Then** the notification count resets to 0
**And** queued notifications from yesterday are processed (up to limit)

**Technical Notes:**
- Creates: `NotificationLimiter`, daily counter
- Covers: FR40

---

### Story 4.9: Month-End Summary

As a **user**,
I want **to see a month-end summary of my finances**,
So that **I can reflect on my spending patterns**.

**Acceptance Criteria:**

**Given** it's the last day of the month
**When** the user opens the app
**Then** a summary card appears on the home screen
**And** it shows: final budget balance, total spent, total income, top category

**Given** the summary is displayed
**When** the user taps "Voir détails"
**Then** navigation goes to the Patterns screen (pre-filtered to this month)

**Given** the user taps "Fermer"
**When** dismissed
**Then** the summary doesn't reappear for this month
**And** it's stored in history for future reference

**Technical Notes:**
- Creates: `MonthEndSummaryCard`, `MonthSummaryService`
- Covers: FR55

---

## Epic 5: Pattern Analysis ("Tes Patterns")

Après 30 jours, l'utilisateur découvre ses habitudes de dépenses cachées.

### Story 5.1: Pattern Feature Unlock Logic

As a **user**,
I want **the Patterns feature to unlock after 30 days of data**,
So that **I see meaningful insights based on real usage**.

**Acceptance Criteria:**

**Given** the user has <30 days of transaction history
**When** they navigate to the Patterns tab
**Then** a locked state screen appears
**And** it shows progress: "Encore X jours avant de débloquer tes patterns"
**And** a progress bar visualizes 0-30 days
**And** an encouraging message explains the value of waiting

**Given** the user has ≥30 days of transaction history
**When** they navigate to the Patterns tab
**Then** the full patterns screen is unlocked
**And** a one-time celebration animation plays ("🎉 Tes patterns sont prêts!")

**Given** the unlock criteria is met
**When** the user returns to Patterns later
**Then** no celebration replays (one-time only)
**And** the screen loads directly with insights

**Technical Notes:**
- Creates: `PatternUnlockService`, `PatternsLockedScreen`
- Covers: FR18

---

### Story 5.2: Category Spending Analysis

As a **user**,
I want **to see my average spending by category**,
So that **I understand where my money goes**.

**Acceptance Criteria:**

**Given** the Patterns feature is unlocked
**When** the user views the Category section
**Then** a pie chart (or donut) shows spending distribution by category
**And** each category shows: name, icon, total amount, percentage
**And** categories are sorted by amount (highest first)

**Given** a category has 0 spending
**When** the chart is rendered
**Then** it's excluded from the visualization
**And** only categories with spending appear

**Given** the user taps a category in the chart
**When** the detail view opens
**Then** it shows average per month and trend (↑↓→)

**Technical Notes:**
- Creates: `CategoryBreakdownChart`, `PatternAnalysisService`
- Covers: FR19, UX-9

---

### Story 5.3: Top 3 Expense Categories

As a **user**,
I want **to see my top 3 spending categories highlighted**,
So that **I quickly identify my biggest expenses**.

**Acceptance Criteria:**

**Given** the Patterns feature is unlocked
**When** the user views the Patterns screen
**Then** a "Top 3" section appears prominently
**And** it shows: 🥇 #1 category (X FCFA), 🥈 #2, 🥉 #3
**And** each entry shows category icon, name, and total

**Given** the user has spending in only 2 categories
**When** the Top 3 is displayed
**Then** only 2 entries appear (no empty placeholders)

**Given** the user taps a top category
**When** interaction occurs
**Then** navigation goes to History filtered by that category

**Technical Notes:**
- Creates: `TopCategoriesCard` widget
- Covers: FR20

---

### Story 5.4: Month-over-Month Comparison

As a **user**,
I want **to compare my current month spending vs previous month**,
So that **I can track if I'm improving**.

**Acceptance Criteria:**

**Given** the user has 2+ months of data
**When** they view the Comparison section
**Then** it shows: "Ce mois: X FCFA vs Mois dernier: Y FCFA"
**And** a percentage change is displayed (+15% or -10%)
**And** color indicates direction (green = less spending, red = more)

**Given** the current month spending is lower
**When** the comparison is displayed
**Then** an encouraging message appears ("Tu dépenses moins ce mois! 👏")

**Given** only 1 month of data exists
**When** the Comparison section renders
**Then** it shows "Pas encore assez de données pour comparer"
**And** a subtle prompt to keep tracking

**Technical Notes:**
- Creates: `MonthComparisonCard`
- Covers: FR21

---

### Story 5.5: Income vs Expenses Overview

As a **user**,
I want **to see total income vs total expenses for the current month**,
So that **I understand my net cash flow**.

**Acceptance Criteria:**

**Given** the Patterns feature is unlocked
**When** the user views the Overview section
**Then** it shows: "Revenus: +X FCFA" and "Dépenses: -Y FCFA"
**And** a net balance is calculated: "Solde: ±Z FCFA"
**And** positive balance shows in green, negative in red

**Given** the user has no income this month
**When** the Overview displays
**Then** income shows as "0 FCFA"
**And** a tip suggests "Ajoute tes revenus pour un suivi complet"

**Given** expenses exceed income
**When** the net balance is negative
**Then** a warning message appears: "Attention: Tu dépenses plus que tu gagnes"

**Technical Notes:**
- Creates: `IncomeExpenseOverviewCard`
- Covers: FR22

---

### Story 5.6: Day-of-Week Spending Distribution

As a **user**,
I want **to see which days I spend the most**,
So that **I can identify behavioral patterns**.

**Acceptance Criteria:**

**Given** the Patterns feature is unlocked
**When** the user views the Day Analysis section
**Then** a bar chart shows spending by day of week (Lun-Dim)
**And** the highest day is highlighted
**And** an insight message appears: "Tu dépenses 2x plus le [jour]"

**Given** the user taps a day bar
**When** the detail appears
**Then** it shows: average spending, transaction count, top category for that day

**Given** spending is evenly distributed
**When** no clear pattern exists
**Then** the insight says "Tes dépenses sont bien réparties dans la semaine"

**Technical Notes:**
- Creates: `DayOfWeekChart`, `PatternInsightsGenerator`
- Covers: FR23
