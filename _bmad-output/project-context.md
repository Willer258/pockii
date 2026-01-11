---
project_name: accountapp
user_name: Wilfriedhouinlindjonon
date: 2026-01-07
sections_completed: [technology_stack, language_rules, framework_rules, testing_rules, code_quality, workflow_rules, critical_rules, architecture_patterns]
existing_patterns_found: 0
status: complete
updated_from: architecture.md
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

### Core Technologies
- **Framework:** Flutter 3.19+ (Dart 3.3+)
- **Target Platforms:** Android 6.0+ (API 23), iOS 12.0+
- **Local Database:** SQLite via drift 2.x + SQLCipher (encrypted)
- **State Management:** Riverpod 2.x
- **Secure Storage:** flutter_secure_storage (SQLCipher key in Keystore)

### Key Dependencies (MVP)
- **Background Processing:** workmanager 0.5.x (15min minimum interval)
- **SMS Reading:** telephony 0.2.x (Android ONLY - iOS = manual entry)
- **Local Notifications:** flutter_local_notifications 16.x

### Version Constraints
- Dart minimum: 3.0 (for records & pattern matching)
- Commit `pubspec.lock` - no caret (^) versions
- Minimum Android SDK: 23 (Android 6.0 Marshmallow)
- Target devices: Low-end Android (Tecno, Infinix, Samsung A series)
- App size budget: < 30MB APK (SQLCipher adds ~4MB)

### Currency: FCFA (XOF)
- **CRITICAL:** Use `int` type, NEVER `double`
- Format: "350 000 FCFA" (space thousands separator)
- Range: 0 to 999,999,999 FCFA

### SMS Parsing Constraints
- MVP: Wave + Orange Money (Ivory Coast format only)
- Regex patterns MUST be documented with real SMS examples
- Each operator/country = separate regex + test fixtures
- SMS formats are NOT stable - version all regex patterns

### Testing Environment
- Primary: Developer's personal Android device
- Fixtures: Real anonymized SMS from Wave/Orange Money
- Stack: flutter_test, mocktail, integration_test

---

## Language-Specific Rules (Dart)

### Null Safety
- **STRICT null safety:** No `!` operator unless absolutely necessary
- Prefer `??` and `?.` over null checks
- Use `required` for mandatory named parameters
- Never use `dynamic` - always specify types

### Async Patterns
- Use `async/await` over raw Futures
- Handle all errors with try/catch in async functions
- Use `FutureOr<T>` for functions that may be sync or async
- Cancel streams and subscriptions in `dispose()`

### Naming Conventions
- Files: `snake_case.dart` (e.g., `expense_repository.dart`)
- Classes: `PascalCase` (e.g., `ExpenseRepository`)
- Variables/functions: `camelCase` (e.g., `calculateRemainingBudget`)
- Constants: `camelCase` (e.g., `defaultCurrency`)
- Private: prefix with `_` (e.g., `_internalState`)

### Import Organization
```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter SDK
import 'package:flutter/material.dart';

// 3. External packages (alphabetical)
import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

// 4. Internal packages (relative)
import '../models/expense.dart';
import 'expense_repository.dart';
```

### Error Handling
- Create custom exception classes in `lib/core/exceptions/`
- Never catch `Exception` generically - be specific
- Log errors before rethrowing
- Use `Result<T, E>` pattern for expected failures (e.g., SMS parsing)

### Documentation
- Document all public APIs with `///` doc comments
- Include `@param` and `@return` for complex functions
- No comments for self-explanatory code
- French comments allowed for business logic explanations

---

## Framework-Specific Rules (Flutter)

### Widget Structure
- **Stateless by default** - use StatefulWidget only when necessary
- Extract widgets to separate files when > 100 lines
- Use `const` constructors wherever possible
- Avoid `BuildContext` in business logic - pass data explicitly

### Riverpod Patterns
- One provider per file in `lib/providers/`
- Use `ref.watch()` in build methods, `ref.read()` in callbacks
- Prefer `StateNotifierProvider` for complex state
- Use `FutureProvider` for async data loading
- Name providers: `<feature>Provider` (e.g., `expensesProvider`)

```dart
// GOOD: Provider in dedicated file
// lib/providers/remaining_budget_provider.dart
final remainingBudgetProvider = StateNotifierProvider<RemainingBudgetNotifier, int>((ref) {
  return RemainingBudgetNotifier(ref.watch(expenseRepositoryProvider));
});

// BAD: Provider defined inline in widget
```

### Navigation
- Use `go_router` for declarative routing
- Define routes in `lib/core/router/app_router.dart`
- Use named routes, never hardcoded strings
- Handle deep links for future notification taps

### Performance (Low-End Devices)
- Use `ListView.builder` for lists, NEVER `ListView` with children
- Implement `const` widgets aggressively
- Use `RepaintBoundary` for complex animations
- Lazy load images with `cached_network_image`
- Avoid `Opacity` widget - use `FadeTransition` instead
- Profile on real Tecno/Infinix device, not emulator

### Offline-First Architecture
```
User Action -> Local DB (drift) -> UI Update -> Background Sync (if online)
                    |
              Immediate feedback
```
- ALWAYS write to local DB first
- UI reads from local DB only (single source of truth)
- Sync happens in background via WorkManager
- Handle sync conflicts with "last write wins" for MVP

### Form Handling
- Use `TextEditingController` with proper disposal
- Validate on submit, not on every keystroke (performance)
- Use `Form` widget with `GlobalKey<FormState>`
- Show errors inline, not in dialogs

---

## Testing Rules

### Test Organization
```
test/
├── unit/
│   ├── models/
│   ├── providers/
│   └── services/
├── widget/
│   └── features/
├── integration/
│   └── flows/
└── fixtures/
    └── sms_samples/      # Real anonymized SMS
```

### Test File Naming
- Unit tests: `<class_name>_test.dart`
- Widget tests: `<widget_name>_widget_test.dart`
- Integration tests: `<flow_name>_flow_test.dart`

### Coverage Requirements (MVP)
- **Critical paths:** 80%+ coverage
  - `RemainingBudget` calculation
  - SMS parsing (Wave, Orange Money)
  - Expense CRUD operations
- **UI widgets:** 40%+ coverage (golden tests later)
- **Edge cases:** 100% coverage for currency handling

### SMS Parsing Tests (CRITICAL)
```dart
// test/fixtures/sms_samples/wave_ci.dart
const waveSendSms = '''
Wave: Vous avez envoye 5 000 F a 07XXXXXXXX.
Frais: 50 F. Solde: 45 000 F. Ref: WV123456
''';

// test/unit/services/sms_parser_test.dart
test('should parse Wave CI send SMS', () {
  final result = SmsParser.parse(waveSendSms, SmsProvider.waveCi);
  expect(result.amount, 5000);  // int, not double!
  expect(result.type, TransactionType.send);
  expect(result.balance, 45000);
});
```

### Mocking Rules
- Use `mocktail` for all mocks
- Mock at repository level, not database level
- Never mock drift database in unit tests - use in-memory DB
- Create mock factories in `test/mocks/`

### Test Data
- Use realistic FCFA amounts (not 100, use 1500, 25000, 350000)
- Include edge cases: 0 FCFA, max int, negative (should reject)
- Test French special characters in descriptions (e, e, a, c)

### What NOT to Test
- Flutter framework internals
- Third-party package behavior
- Trivial getters/setters
- Generated drift code

---

## Code Quality & Style Rules

### Linting Configuration
- Use `flutter_lints` package (strict mode)
- Zero warnings policy - fix all before commit
- Add to `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    require_trailing_commas: true
    prefer_single_quotes: true

analyzer:
  errors:
    missing_required_param: error
    missing_return: error
  exclude:
    - "**/*.g.dart"      # Generated drift code
    - "**/*.freezed.dart"
```

### Code Formatting
- Use `dart format` (default 80 char line limit)
- Run before every commit: `dart format .`
- Trailing commas on multi-line structures (auto-formatting friendly)

### File Structure
```
lib/
├── core/
│   ├── constants/       # App-wide constants
│   ├── database/        # drift schemas & DAOs
│   ├── exceptions/      # Custom exception classes
│   ├── router/          # go_router configuration
│   └── theme/           # Colors, typography, themes
├── features/
│   ├── remaining_budget/ # "Reste a vivre" feature
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── expenses/
│   ├── patterns/
│   └── subscriptions/   # "Cotisations" feature
├── shared/
│   ├── widgets/         # Reusable UI components
│   └── utils/           # Helper functions
└── main.dart
```

### Naming Rules
| Type | Convention | Example |
|------|------------|---------|
| Feature folders | `snake_case` (EN) | `remaining_budget/` |
| Widget files | `snake_case` (EN) | `expense_card.dart` |
| Model files | `snake_case` (EN) | `expense_model.dart` |
| Provider files | `snake_case` (EN) | `expenses_provider.dart` |
| Variables | `camelCase` (EN) | `remainingBudget` |
| Classes | `PascalCase` (EN) | `RemainingBudgetNotifier` |

### Language Policy
- **Code:** 100% English (files, classes, variables, functions)
- **UI strings:** French (displayed to user)
- **Comments:** English preferred, French allowed for complex business logic
- **Commits:** English

### Comments Policy
- **DO:** Document WHY, not WHAT
- **DO:** Use `// TODO(wilfried):` format for todos
- **DO:** Add French comments for complex business logic
- **DON'T:** Comment obvious code
- **DON'T:** Leave commented-out code (delete it)

### Git Hygiene
- No generated files in git (except `pubspec.lock`)
- Add to `.gitignore`: `*.g.dart`, `*.freezed.dart`, `.dart_tool/`
- Commit `pubspec.lock` for reproducible builds

---

## Development Workflow Rules

### Branch Strategy
- `main` - Production-ready code only
- `develop` - Integration branch
- `feature/<name>` - New features (e.g., `feature/sms-parsing`)
- `fix/<name>` - Bug fixes (e.g., `fix/amount-overflow`)
- `refactor/<name>` - Code refactoring

### Commit Message Format
```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `test`: Adding tests
- `docs`: Documentation
- `chore`: Maintenance

**Examples:**
```
feat(expenses): add manual expense entry form
fix(sms): handle Wave SMS without balance field
refactor(database): migrate to drift 2.x syntax
test(parser): add Orange Money CI fixtures
```

### PR Requirements (Solo Dev)
- Self-review checklist before merge:
  - [ ] Tests pass locally
  - [ ] No lint warnings
  - [ ] FCFA amounts use `int` (not `double`)
  - [ ] New SMS patterns have test fixtures
  - [ ] No hardcoded strings in UI

### Pre-Commit Checklist
```bash
# Run before every commit
dart format .
dart analyze
flutter test
```

### Release Versioning
- Follow SemVer: `MAJOR.MINOR.PATCH`
- MVP starts at `0.1.0`
- Increment:
  - `PATCH`: Bug fixes (0.1.0 -> 0.1.1)
  - `MINOR`: New features (0.1.1 -> 0.2.0)
  - `MAJOR`: Breaking changes (0.x.x -> 1.0.0 at public launch)

### Build Commands
```bash
# Development
flutter run

# Release APK (Android)
flutter build apk --release

# Check APK size (must be < 30MB)
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Run all tests
flutter test --coverage
```

### Environment Setup
- Flutter SDK: 3.19+
- Dart SDK: 3.3+
- Android Studio / VS Code with Flutter extension
- Physical Android device for testing

---

## Critical Don't-Miss Rules

### ABSOLUTE RULES (Never Break)

1. **FCFA = Integer ONLY**
   ```dart
   // CORRECT
   final int amount = 350000;

   // FATAL ERROR - NEVER DO THIS
   final double amount = 350000.0;
   ```

2. **Offline-First = Local DB First**
   - ALWAYS write to drift DB before any network call
   - UI MUST work with zero connectivity
   - Never block UI waiting for sync

3. **SMS Parsing = Fragile**
   - NEVER assume SMS format is stable
   - ALWAYS have a fallback to manual entry
   - EVERY regex pattern needs a test fixture with REAL SMS

4. **No Cloud Dependencies for MVP**
   - No Firebase, no Supabase, no backend
   - 100% local storage
   - User data never leaves the device

### Common AI Agent Mistakes

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Using `double` for money | FCFA has no decimals | Use `int` everywhere |
| Fetching data from API | MVP is offline-only | Read from local drift DB |
| Generic SMS regex | Formats vary by operator | Separate regex per operator |
| `ListView(children: [...])` | Performance killer | `ListView.builder()` |
| Storing SQLCipher key in code | Security vulnerability | Use `flutter_secure_storage` |
| Testing on emulator only | Misses real device issues | Test on Tecno/Infinix |
| French variable names | Code must be English | `remainingBudget` not `resteAVivre` |

### Security Rules

- **SQLCipher key:** Generated once, stored in Android Keystore
- **SMS permissions:** Request at runtime, explain why to user
- **No analytics for MVP:** No tracking, no telemetry
- **No data export:** User data stays on device only

### Platform-Specific Gotchas

**Android:**
- `telephony` package requires `READ_SMS` + `RECEIVE_SMS` permissions
- WorkManager minimum interval = 15 minutes
- Test on API 23 (oldest supported) AND latest

**iOS:**
- NO SMS access - Apple forbids it
- All transactions = manual entry only
- Plan for this in UI/UX

### Business Logic Rules

**"Remaining Budget" Calculation:**
```dart
int calculateRemainingBudget({
  required int monthlyIncome,
  required int fixedExpenses,
  required int variableExpenses,
}) {
  return monthlyIncome - fixedExpenses - variableExpenses;
}
// Returns negative if overspent - this is valid!
```

**Transaction Categories (MVP):**
```dart
enum ExpenseCategory {
  transport,
  food,
  leisure,
  family,
  subscriptions, // cotisations
  other,
}
```

### Definition of Done (Story Completion)

A story is DONE when:
- [ ] All acceptance criteria met
- [ ] Unit tests pass (80%+ coverage for critical paths)
- [ ] No lint warnings
- [ ] Tested on real Android device
- [ ] FCFA amounts verified as `int`
- [ ] Works offline
- [ ] French UI strings are correct

---

## Architecture Patterns (From Architecture Document)

_These patterns were added from the architecture decision document to ensure AI agent consistency._

### Time Handling (CRITICAL)

**Injectable Clock Pattern:**
- **NEVER** use `DateTime.now()` directly in code
- **ALWAYS** use `clockProvider` for current time
- Enables time-travel testing for month boundaries, streaks, etc.

```dart
// CORRECT - Testable
final now = ref.read(clockProvider).now();

// WRONG - Untestable
final now = DateTime.now();
```

**Clock Provider:**
```dart
// lib/core/services/clock_service.dart
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  @override
  DateTime now() => DateTime.now();
}

final clockProvider = Provider<Clock>((ref) => SystemClock());
```

### Error Recovery Strategy

| Error Type | Detection | Recovery |
|------------|-----------|----------|
| SQLCipher key corrupted | Keystore access failure | Re-generate key, user data lost (warn user) |
| Database corrupted | drift integrity check | Delete and recreate, warn user |
| Storage full | IOException on write | Show warning, prevent new entries |
| Background task failure | WorkManager callback | Retry with exponential backoff (max 3) |

### Month Transition Logic

| Scenario | Handling |
|----------|----------|
| App opened on 1st | Check last reset date, trigger reset if needed |
| Midnight transition | WorkManager triggers reset check |
| Timezone change | Use device local time, store as UTC internally |
| Clock manipulation | Detect backward time jumps, warn user |

### Database Patterns (drift)

**Table Naming:**
- Tables: `snake_case` plural (`transactions`, `budget_periods`)
- Columns: `snake_case` (`amount_fcfa`, `created_at`)
- Foreign keys: `{table}_id` (`budget_period_id`)
- Money columns: `_fcfa` suffix (`amount_fcfa`, `balance_fcfa`)

**Swappable Database Interface:**
```dart
// Production: SQLCipher encrypted
final databaseProvider = Provider<AppDatabase>((ref) {
  final key = ref.read(encryptionKeyProvider);
  return AppDatabase(encrypted: true, key: key);
});

// Tests: In-memory unencrypted
final testDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.inMemory();
});
```

### Feature Communication Rules

- Features communicate **ONLY** via Riverpod providers
- **NO** direct imports between `features/` folders
- Shared code goes in `shared/` or `core/`
- Cross-feature dependencies via provider injection

```dart
// CORRECT - Via provider
final budget = ref.watch(remainingBudgetProvider);

// WRONG - Direct import
import '../transactions/data/transaction_repository.dart';
```

### Custom Exception Types

```dart
// lib/core/exceptions/app_exceptions.dart
sealed class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  AppException(this.message, [this.stackTrace]);
}

class DatabaseException extends AppException {
  DatabaseException(super.message, [super.stackTrace]);
}

class ValidationException extends AppException {
  ValidationException(super.message, [super.stackTrace]);
}

class StorageException extends AppException {
  StorageException(super.message, [super.stackTrace]);
}

class ParseException extends AppException {
  ParseException(super.message, [super.stackTrace]);
}
```

**Rule:** Never catch generic `Exception` - always specific types.

### Additional AI Agent Mistakes (From Architecture)

| Mistake | Why It's Wrong | Correct Approach |
|---------|----------------|------------------|
| Using `DateTime.now()` | Untestable time logic | Use `clockProvider` |
| Direct feature imports | Breaks boundaries | Use providers only |
| Generic exception catch | Hides error types | Use sealed exceptions |
| Hardcoded DB in tests | Can't test encryption | Use swappable interface |
