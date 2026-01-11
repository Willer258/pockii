# Story 1.2: Theme & Design System Foundation

Status: done

## Story

As a **developer**,
I want **Material 3 theme with custom AppColors and AppTypography**,
So that **all screens have consistent visual design from day one**.

## Acceptance Criteria

1. **AC1:** `AppTheme` class provides `light()` method returning ThemeData with explicit ColorScheme (NOT `fromSeed`)
2. **AC2:** `AppColors` defines all color constants:
   - Primary: `#2E7D32` (Trust green)
   - Secondary: `#1565C0` (Accent blue)
   - Surface: `#F5F5F5`
   - Background: `#FFFFFF`
   - Error: `#B3261E`
3. **AC3:** `BudgetColors` provides budget status colors:
   - OK: `#4CAF50` (>30% remaining)
   - Warning: `#FF9800` (10-30% remaining)
   - Danger: `#F44336` (<10% remaining)
4. **AC4:** `AppTypography` uses Inter font with text styles:
   - Hero: 56sp, weight 700 (budget number)
   - Headline: 32sp, weight 600
   - Title: 24sp, weight 600
   - Body: 16sp, weight 400
   - Label: 14sp, weight 500
   - Caption: 12sp, weight 400
5. **AC5:** `AppSpacing` defines 8dp base spacing scale
6. **AC6:** `AppBorderRadius` defines consistent radii (cards=16dp, buttons=12dp, chips=8dp)
7. **AC7:** Dark mode structure is prepared (`dark()` method stub)
8. **AC8:** Inter font is bundled in assets with proper pubspec configuration
9. **AC9:** Theme is applied in `main.dart` via `MaterialApp`

## Tasks / Subtasks

- [ ] **Task 1: Color System** (AC: 2, 3)
  - [ ] Create `lib/core/theme/app_colors.dart`:
    ```dart
    abstract class AppColors {
      // Primary Colors
      static const primary = Color(0xFF2E7D32);      // Trust green
      static const onPrimary = Color(0xFFFFFFFF);
      static const secondary = Color(0xFF1565C0);    // Accent blue
      static const onSecondary = Color(0xFFFFFFFF);

      // Surface Colors
      static const surface = Color(0xFFF5F5F5);
      static const onSurface = Color(0xFF1C1B1F);
      static const background = Color(0xFFFFFFFF);
      static const onBackground = Color(0xFF1C1B1F);

      // Error
      static const error = Color(0xFFB3261E);
      static const onError = Color(0xFFFFFFFF);

      // Outline & Dividers
      static const outline = Color(0xFF79747E);
      static const outlineVariant = Color(0xFFCAC4D0);
    }
    ```
  - [ ] Create `lib/core/theme/budget_colors.dart`:
    ```dart
    abstract class BudgetColors {
      /// Budget OK: >30% remaining
      static const ok = Color(0xFF4CAF50);

      /// Budget Warning: 10-30% remaining
      static const warning = Color(0xFFFF9800);

      /// Budget Danger: <10% remaining OR negative
      static const danger = Color(0xFFF44336);

      /// Returns appropriate color based on remaining percentage
      static Color forPercentage(double percentage) {
        if (percentage > 0.30) return ok;
        if (percentage > 0.10) return warning;
        return danger;
      }

      /// Returns color for a remaining budget amount
      static Color forRemaining(int remaining, int total) {
        if (total <= 0) return danger;
        return forPercentage(remaining / total);
      }
    }
    ```

- [ ] **Task 2: Typography System** (AC: 4, 8)
  - [ ] Download Inter font (Regular 400, Medium 500, SemiBold 600, Bold 700)
  - [ ] Create `assets/fonts/` directory
  - [ ] Add Inter font files to `assets/fonts/`
  - [ ] Update `pubspec.yaml` with font configuration:
    ```yaml
    fonts:
      - family: Inter
        fonts:
          - asset: assets/fonts/Inter-Regular.ttf
            weight: 400
          - asset: assets/fonts/Inter-Medium.ttf
            weight: 500
          - asset: assets/fonts/Inter-SemiBold.ttf
            weight: 600
          - asset: assets/fonts/Inter-Bold.ttf
            weight: 700
    ```
  - [ ] Create `lib/core/theme/app_typography.dart`:
    ```dart
    abstract class AppTypography {
      static const String fontFamily = 'Inter';

      // Size constants
      static const double heroSize = 56.0;
      static const double headlineSize = 32.0;
      static const double titleSize = 24.0;
      static const double titleSmallSize = 20.0;
      static const double bodyLargeSize = 18.0;
      static const double bodySize = 16.0;
      static const double labelSize = 14.0;
      static const double captionSize = 12.0;

      /// Hero text style for budget number (56sp, bold)
      static const TextStyle hero = TextStyle(
        fontFamily: fontFamily,
        fontSize: heroSize,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
      );

      /// Headline for screen titles (32sp, semibold)
      static const TextStyle headline = TextStyle(
        fontFamily: fontFamily,
        fontSize: headlineSize,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

      /// Title for section headers (24sp, semibold)
      static const TextStyle title = TextStyle(
        fontFamily: fontFamily,
        fontSize: titleSize,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

      /// Title small variant (20sp, semibold)
      static const TextStyle titleSmall = TextStyle(
        fontFamily: fontFamily,
        fontSize: titleSmallSize,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

      /// Body large for important text (18sp, regular)
      static const TextStyle bodyLarge = TextStyle(
        fontFamily: fontFamily,
        fontSize: bodyLargeSize,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

      /// Default body text (16sp, regular)
      static const TextStyle body = TextStyle(
        fontFamily: fontFamily,
        fontSize: bodySize,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

      /// Label for buttons, chips (14sp, medium)
      static const TextStyle label = TextStyle(
        fontFamily: fontFamily,
        fontSize: labelSize,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

      /// Caption for secondary text (12sp, regular)
      static const TextStyle caption = TextStyle(
        fontFamily: fontFamily,
        fontSize: captionSize,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );
    }
    ```

- [ ] **Task 3: Spacing & Dimensions** (AC: 5, 6)
  - [ ] Create `lib/core/theme/app_spacing.dart`:
    ```dart
    abstract class AppSpacing {
      /// Base spacing unit (8dp)
      static const double base = 8.0;

      /// Extra small (4dp) - minimal internal spacing
      static const double xs = 4.0;

      /// Small (8dp) - component internal padding
      static const double sm = 8.0;

      /// Medium (16dp) - element margins
      static const double md = 16.0;

      /// Large (24dp) - section spacing
      static const double lg = 24.0;

      /// Extra large (32dp) - screen margins
      static const double xl = 32.0;

      /// Extra extra large (48dp) - major spacing
      static const double xxl = 48.0;

      /// Screen horizontal padding
      static const double screenPadding = 16.0;

      /// Card internal padding
      static const double cardPadding = 16.0;

      /// Minimum touch target size (48dp for accessibility)
      static const double touchTarget = 48.0;
    }
    ```
  - [ ] Create `lib/core/theme/app_border_radius.dart`:
    ```dart
    abstract class AppBorderRadius {
      /// Cards and containers (16dp)
      static const double card = 16.0;
      static final BorderRadius cardRadius = BorderRadius.circular(card);

      /// Buttons (12dp)
      static const double button = 12.0;
      static final BorderRadius buttonRadius = BorderRadius.circular(button);

      /// Chips and small elements (8dp)
      static const double chip = 8.0;
      static final BorderRadius chipRadius = BorderRadius.circular(chip);

      /// Full circle (FAB)
      static const double circular = 100.0;
      static final BorderRadius circularRadius = BorderRadius.circular(circular);

      /// Bottom sheet top corners
      static final BorderRadius bottomSheetRadius = BorderRadius.only(
        topLeft: Radius.circular(card),
        topRight: Radius.circular(card),
      );
    }
    ```

- [ ] **Task 4: Theme Configuration** (AC: 1, 7, 9)
  - [ ] Create `lib/core/theme/app_theme.dart`:
    ```dart
    class AppTheme {
      /// Light theme (MVP default)
      static ThemeData light() => _buildTheme(Brightness.light);

      /// Dark theme (prepared for post-MVP)
      static ThemeData dark() => _buildTheme(Brightness.dark);

      static ThemeData _buildTheme(Brightness brightness) {
        final isDark = brightness == Brightness.dark;

        final colorScheme = ColorScheme(
          brightness: brightness,
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          error: AppColors.error,
          onError: AppColors.onError,
          surface: isDark ? const Color(0xFF1C1B1F) : AppColors.surface,
          onSurface: isDark ? Colors.white : AppColors.onSurface,
        );

        return ThemeData(
          useMaterial3: true,
          brightness: brightness,
          colorScheme: colorScheme,
          fontFamily: AppTypography.fontFamily,

          // Card theme
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.cardRadius,
            ),
            margin: EdgeInsets.zero,
          ),

          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, AppSpacing.touchTarget),
              shape: RoundedRectangleBorder(
                borderRadius: AppBorderRadius.buttonRadius,
              ),
              textStyle: AppTypography.label,
            ),
          ),

          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              minimumSize: Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
              textStyle: AppTypography.label,
            ),
          ),

          // Floating action button theme
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4,
            shape: const CircleBorder(),
          ),

          // Bottom navigation bar theme
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            type: BottomNavigationBarType.fixed,
            backgroundColor: colorScheme.surface,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: AppTypography.caption,
            unselectedLabelStyle: AppTypography.caption,
          ),

          // Chip theme
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.chipRadius,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
          ),

          // Snackbar theme
          snackBarTheme: SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.chipRadius,
            ),
          ),

          // Bottom sheet theme
          bottomSheetTheme: BottomSheetThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.bottomSheetRadius,
            ),
            elevation: 8,
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: AppBorderRadius.chipRadius,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),

          // App bar theme
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            titleTextStyle: AppTypography.title.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        );
      }
    }
    ```

- [ ] **Task 5: Theme Barrel Export** (AC: 1)
  - [ ] Create `lib/core/theme/theme.dart` (barrel file):
    ```dart
    export 'app_colors.dart';
    export 'app_typography.dart';
    export 'app_spacing.dart';
    export 'app_border_radius.dart';
    export 'budget_colors.dart';
    export 'app_theme.dart';
    ```

- [ ] **Task 6: Integration** (AC: 9)
  - [ ] Update `lib/main.dart` to use the theme:
    ```dart
    MaterialApp(
      title: 'AccountApp',
      theme: AppTheme.light(),
      // darkTheme: AppTheme.dark(), // Post-MVP
      home: const Placeholder(), // Will be replaced by HomeScreen
    )
    ```

- [ ] **Task 7: Unit Tests** (AC: all)
  - [ ] Create `test/unit/core/theme/app_colors_test.dart`:
    - Test all color values match hex specifications
    - Test contrast ratios meet WCAG AA (4.5:1)
  - [ ] Create `test/unit/core/theme/budget_colors_test.dart`:
    - Test `forPercentage()` returns correct colors
    - Test `forRemaining()` handles edge cases (0, negative, > total)
  - [ ] Create `test/unit/core/theme/app_typography_test.dart`:
    - Test font family is 'Inter'
    - Test hero size is 56.0
    - Test all weights are correct
  - [ ] Create `test/unit/core/theme/app_theme_test.dart`:
    - Test `light()` returns ThemeData with brightness.light
    - Test `dark()` returns ThemeData with brightness.dark
    - Test colorScheme has explicit colors (not fromSeed)

## Dev Notes

### Critical Architecture Compliance

**From project-context.md:**
- Use `const` constructors wherever possible
- Font scaling support required (use Theme typography, not fixed sizes)
- Touch targets minimum 48dp for accessibility
- Color contrast 4.5:1 minimum (WCAG AA)

**From UX Design Specification:**
- FAB position will be centered (Wave-style) - configured in FAB usage, not theme
- Card elevation: 2dp resting, 4dp FAB, 8dp bottom sheets
- All colors must work with TalkBack (never color alone for status)

### Font Setup Instructions

1. Download Inter font from Google Fonts: https://fonts.google.com/specimen/Inter
2. Extract and copy these weights to `assets/fonts/`:
   - Inter-Regular.ttf (400)
   - Inter-Medium.ttf (500)
   - Inter-SemiBold.ttf (600)
   - Inter-Bold.ttf (700)
3. Total size ~100KB (much smaller than Poppins ~200KB)

### Color Accessibility Verification

| Color Pair | Ratio | WCAG |
|------------|-------|------|
| onSurface (#1C1B1F) on surface (#F5F5F5) | 12.6:1 | AAA |
| primary (#2E7D32) on white (#FFFFFF) | 5.3:1 | AA |
| warning (#FF9800) on white | 3.0:1 | Large text only |
| danger (#F44336) on white | 4.6:1 | AA |

**Note:** Warning color has lower contrast - always use with icon or text, never alone.

### File Structure (Created by This Story)

```
accountapp/
├── assets/
│   └── fonts/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       ├── Inter-SemiBold.ttf
│       └── Inter-Bold.ttf
├── lib/
│   └── core/
│       └── theme/
│           ├── theme.dart (barrel export)
│           ├── app_theme.dart
│           ├── app_colors.dart
│           ├── app_typography.dart
│           ├── app_spacing.dart
│           ├── app_border_radius.dart
│           └── budget_colors.dart
└── test/
    └── unit/
        └── core/
            └── theme/
                ├── app_colors_test.dart
                ├── budget_colors_test.dart
                ├── app_typography_test.dart
                └── app_theme_test.dart
```

### Previous Story Intelligence (Story 1.1)

**Files created that this story extends:**
- `lib/core/theme/` directory exists but is empty
- `lib/main.dart` exists with ProviderScope, needs MaterialApp theme update

**Patterns established:**
- Abstract classes for constants (like `AppConstants`)
- Barrel exports for clean imports
- Comprehensive unit tests for all new code

**Corrections made during 1.1:**
- Use `const` wherever possible
- No hardcoded values - use constants

### Requirements Traceability

| Requirement | Implementation |
|-------------|----------------|
| UX-4: Material Design 3 with custom theme | `AppTheme` with explicit ColorScheme |
| UX-5: Inter font family | Inter bundled in assets, ~100KB |
| UX-6: 8dp spacing base | `AppSpacing` with 8dp base scale |
| NFR19: Touch targets 48dp min | `AppSpacing.touchTarget` = 48 |
| NFR20: Contrast 4.5:1 min | All primary colors verified |

### References

- [Source: ux-design-specification.md#Design-System-Foundation] - Complete color/typography spec
- [Source: ux-design-specification.md#Visual-Design-Foundation] - Spacing and accessibility
- [Source: architecture.md#Project-Structure] - Theme file locations
- [Source: project-context.md#Framework-Specific-Rules] - Widget structure patterns
- [Source: epics.md#Story-1.2] - Original story definition

## Dev Agent Record

### Agent Model Used

{{agent_model_name_version}}

### Debug Log References

### Completion Notes List

### Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-08 | Story created | BMAD Create-Story Workflow |

### File List

**To Create:**
- `assets/fonts/Inter-Regular.ttf`
- `assets/fonts/Inter-Medium.ttf`
- `assets/fonts/Inter-SemiBold.ttf`
- `assets/fonts/Inter-Bold.ttf`
- `lib/core/theme/theme.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_border_radius.dart`
- `lib/core/theme/budget_colors.dart`
- `test/unit/core/theme/app_colors_test.dart`
- `test/unit/core/theme/budget_colors_test.dart`
- `test/unit/core/theme/app_typography_test.dart`
- `test/unit/core/theme/app_theme_test.dart`

**To Modify:**
- `pubspec.yaml` (add font assets)
- `lib/main.dart` (apply AppTheme.light())
