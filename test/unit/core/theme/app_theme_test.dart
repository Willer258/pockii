import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:accountapp/core/theme/theme.dart';

void main() {
  group('AppTheme', () {
    group('light()', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.light();
      });

      test('returns ThemeData with light brightness', () {
        expect(lightTheme.brightness, Brightness.light);
      });

      test('uses Material 3', () {
        expect(lightTheme.useMaterial3, true);
      });

      test('has explicit ColorScheme (not fromSeed)', () {
        // Verify that primary color is exactly our defined color
        expect(lightTheme.colorScheme.primary, AppColors.primary);
        expect(lightTheme.colorScheme.secondary, AppColors.secondary);
        expect(lightTheme.colorScheme.error, AppColors.error);
      });

      test('colorScheme has correct primary color (#2E7D32)', () {
        expect(lightTheme.colorScheme.primary, const Color(0xFF2E7D32));
      });

      test('colorScheme has correct secondary color (#1565C0)', () {
        expect(lightTheme.colorScheme.secondary, const Color(0xFF1565C0));
      });

      test('colorScheme has correct surface color (#F5F5F5)', () {
        expect(lightTheme.colorScheme.surface, const Color(0xFFF5F5F5));
      });

      test('colorScheme has correct error color (#B3261E)', () {
        expect(lightTheme.colorScheme.error, const Color(0xFFB3261E));
      });

      test('colorScheme has light brightness', () {
        expect(lightTheme.colorScheme.brightness, Brightness.light);
      });
    });

    group('dark()', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.dark();
      });

      test('returns ThemeData with dark brightness', () {
        expect(darkTheme.brightness, Brightness.dark);
      });

      test('uses Material 3', () {
        expect(darkTheme.useMaterial3, true);
      });

      test('colorScheme has dark brightness', () {
        expect(darkTheme.colorScheme.brightness, Brightness.dark);
      });

      test('dark surface is darker than light surface', () {
        final lightTheme = AppTheme.light();

        // Dark surface should have lower luminance
        final darkLuminance = darkTheme.colorScheme.surface.computeLuminance();
        final lightLuminance = lightTheme.colorScheme.surface.computeLuminance();

        expect(darkLuminance, lessThan(lightLuminance));
      });

      test('maintains primary color in dark mode', () {
        // Primary should be the same in both themes
        expect(darkTheme.colorScheme.primary, AppColors.primary);
      });
    });

    group('Card Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('has elevation of 2', () {
        expect(theme.cardTheme.elevation, 2);
      });

      test('has 16dp border radius', () {
        final shape = theme.cardTheme.shape as RoundedRectangleBorder;
        final radius = shape.borderRadius as BorderRadius;

        expect(radius.topLeft.x, AppBorderRadius.card);
        expect(radius.topRight.x, AppBorderRadius.card);
        expect(radius.bottomLeft.x, AppBorderRadius.card);
        expect(radius.bottomRight.x, AppBorderRadius.card);
      });
    });

    group('Button Themes', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('elevated button has 12dp border radius', () {
        final style = theme.elevatedButtonTheme.style!;
        final shape = style.shape!.resolve({}) as RoundedRectangleBorder;
        final radius = shape.borderRadius as BorderRadius;

        expect(radius.topLeft.x, AppBorderRadius.button);
      });

      test('elevated button has minimum touch target height (48dp)', () {
        final style = theme.elevatedButtonTheme.style!;
        final minSize = style.minimumSize!.resolve({});

        expect(minSize!.height, AppSpacing.touchTarget);
      });

      test('text button has minimum touch target size', () {
        final style = theme.textButtonTheme.style!;
        final minSize = style.minimumSize!.resolve({});

        expect(minSize!.height, AppSpacing.touchTarget);
        expect(minSize.width, AppSpacing.touchTarget);
      });
    });

    group('FAB Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('FAB uses primary color', () {
        expect(
          theme.floatingActionButtonTheme.backgroundColor,
          theme.colorScheme.primary,
        );
      });

      test('FAB uses onPrimary for foreground', () {
        expect(
          theme.floatingActionButtonTheme.foregroundColor,
          theme.colorScheme.onPrimary,
        );
      });

      test('FAB has elevation of 4', () {
        expect(theme.floatingActionButtonTheme.elevation, 4);
      });

      test('FAB is circular', () {
        expect(theme.floatingActionButtonTheme.shape, isA<CircleBorder>());
      });
    });

    group('Chip Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('has 8dp border radius', () {
        final shape = theme.chipTheme.shape as RoundedRectangleBorder;
        final radius = shape.borderRadius as BorderRadius;

        expect(radius.topLeft.x, AppBorderRadius.chip);
      });
    });

    group('Bottom Sheet Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('has rounded top corners', () {
        final shape = theme.bottomSheetTheme.shape as RoundedRectangleBorder;
        final radius = shape.borderRadius as BorderRadius;

        // Top corners should be rounded
        expect(radius.topLeft.x, AppBorderRadius.card);
        expect(radius.topRight.x, AppBorderRadius.card);

        // Bottom corners should not be rounded
        expect(radius.bottomLeft.x, 0);
        expect(radius.bottomRight.x, 0);
      });

      test('has elevation of 8', () {
        expect(theme.bottomSheetTheme.elevation, 8);
      });

      test('shows drag handle', () {
        expect(theme.bottomSheetTheme.showDragHandle, true);
      });
    });

    group('Input Decoration Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('uses filled style', () {
        expect(theme.inputDecorationTheme.filled, true);
      });

      test('has 8dp border radius', () {
        final border = theme.inputDecorationTheme.border as OutlineInputBorder;
        final radius = border.borderRadius;

        expect(radius.topLeft.x, AppBorderRadius.chip);
      });

      test('focused border uses primary color', () {
        final focusedBorder =
            theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
        expect(focusedBorder.borderSide.color, theme.colorScheme.primary);
      });

      test('error border uses error color', () {
        final errorBorder =
            theme.inputDecorationTheme.errorBorder as OutlineInputBorder;
        expect(errorBorder.borderSide.color, theme.colorScheme.error);
      });
    });

    group('App Bar Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('has zero elevation', () {
        expect(theme.appBarTheme.elevation, 0);
      });

      test('has centered title', () {
        expect(theme.appBarTheme.centerTitle, true);
      });

      test('uses surface color for background', () {
        expect(theme.appBarTheme.backgroundColor, theme.colorScheme.surface);
      });
    });

    group('Snackbar Theme', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('uses floating behavior', () {
        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      });

      test('uses inverse surface for background', () {
        expect(
          theme.snackBarTheme.backgroundColor,
          theme.colorScheme.inverseSurface,
        );
      });
    });

    group('Spacing Integration', () {
      late ThemeData theme;

      setUp(() {
        theme = AppTheme.light();
      });

      test('button minimum size uses AppSpacing.touchTarget', () {
        final style = theme.elevatedButtonTheme.style!;
        final minSize = style.minimumSize!.resolve({});

        expect(minSize!.height, 48.0); // AppSpacing.touchTarget
      });
    });

    group('Light vs Dark Comparison', () {
      test('both themes use same primary color', () {
        final light = AppTheme.light();
        final dark = AppTheme.dark();

        expect(light.colorScheme.primary, dark.colorScheme.primary);
      });

      test('both themes use same secondary color', () {
        final light = AppTheme.light();
        final dark = AppTheme.dark();

        expect(light.colorScheme.secondary, dark.colorScheme.secondary);
      });

      test('both themes use same error color', () {
        final light = AppTheme.light();
        final dark = AppTheme.dark();

        expect(light.colorScheme.error, dark.colorScheme.error);
      });

      test('themes have different brightness', () {
        final light = AppTheme.light();
        final dark = AppTheme.dark();

        expect(light.brightness, isNot(dark.brightness));
      });
    });
  });
}
