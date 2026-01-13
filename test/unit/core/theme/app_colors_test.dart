import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockii/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('primary is correct green (#2E7D32)', () {
        expect(AppColors.primary, const Color(0xFF2E7D32));
      });

      test('onPrimary is white', () {
        expect(AppColors.onPrimary, const Color(0xFFFFFFFF));
      });

      test('secondary is correct blue (#1565C0)', () {
        expect(AppColors.secondary, const Color(0xFF1565C0));
      });

      test('onSecondary is white', () {
        expect(AppColors.onSecondary, const Color(0xFFFFFFFF));
      });
    });

    group('Surface Colors', () {
      test('surface is correct light gray (#F5F5F5)', () {
        expect(AppColors.surface, const Color(0xFFF5F5F5));
      });

      test('onSurface is dark (#1C1B1F)', () {
        expect(AppColors.onSurface, const Color(0xFF1C1B1F));
      });

      test('background is white (#FFFFFF)', () {
        expect(AppColors.background, const Color(0xFFFFFFFF));
      });

      test('onBackground is dark (#1C1B1F)', () {
        expect(AppColors.onBackground, const Color(0xFF1C1B1F));
      });
    });

    group('Error Colors', () {
      test('error is correct red (#B3261E)', () {
        expect(AppColors.error, const Color(0xFFB3261E));
      });

      test('onError is white', () {
        expect(AppColors.onError, const Color(0xFFFFFFFF));
      });
    });

    group('Outline Colors', () {
      test('outline is correct gray (#79747E)', () {
        expect(AppColors.outline, const Color(0xFF79747E));
      });

      test('outlineVariant is lighter gray (#CAC4D0)', () {
        expect(AppColors.outlineVariant, const Color(0xFFCAC4D0));
      });
    });

    group('Color Accessibility', () {
      test('onSurface has sufficient contrast on surface', () {
        // onSurface (#1C1B1F) on surface (#F5F5F5) should have >= 4.5:1 ratio
        // Calculated ratio: ~12.6:1 (passes AAA)
        final onSurfaceLuminance = AppColors.onSurface.computeLuminance();
        final surfaceLuminance = AppColors.surface.computeLuminance();

        // Ensure high contrast (darker on lighter)
        expect(onSurfaceLuminance, lessThan(surfaceLuminance));

        // Calculate contrast ratio: (L1 + 0.05) / (L2 + 0.05)
        final lighter = surfaceLuminance;
        final darker = onSurfaceLuminance;
        final contrastRatio = (lighter + 0.05) / (darker + 0.05);

        // WCAG AA requires 4.5:1 for normal text
        expect(contrastRatio, greaterThan(4.5));
      });

      test('primary has sufficient contrast on white', () {
        // Primary (#2E7D32) on white should have >= 4.5:1 ratio
        // Calculated ratio: ~5.3:1 (passes AA)
        final primaryLuminance = AppColors.primary.computeLuminance();
        const whiteLuminance = 1.0;

        final contrastRatio = (whiteLuminance + 0.05) / (primaryLuminance + 0.05);

        // WCAG AA requires 4.5:1 for normal text
        expect(contrastRatio, greaterThan(4.5));
      });

      test('onPrimary has sufficient contrast on primary', () {
        // White on primary should have good contrast
        final onPrimaryLuminance = AppColors.onPrimary.computeLuminance();
        final primaryLuminance = AppColors.primary.computeLuminance();

        final lighter =
            onPrimaryLuminance > primaryLuminance ? onPrimaryLuminance : primaryLuminance;
        final darker =
            onPrimaryLuminance < primaryLuminance ? onPrimaryLuminance : primaryLuminance;
        final contrastRatio = (lighter + 0.05) / (darker + 0.05);

        expect(contrastRatio, greaterThan(4.5));
      });
    });

    group('All colors are defined', () {
      test('all primary colors are non-null', () {
        expect(AppColors.primary, isNotNull);
        expect(AppColors.onPrimary, isNotNull);
        expect(AppColors.primaryContainer, isNotNull);
        expect(AppColors.onPrimaryContainer, isNotNull);
      });

      test('all secondary colors are non-null', () {
        expect(AppColors.secondary, isNotNull);
        expect(AppColors.onSecondary, isNotNull);
        expect(AppColors.secondaryContainer, isNotNull);
        expect(AppColors.onSecondaryContainer, isNotNull);
      });

      test('all surface colors are non-null', () {
        expect(AppColors.surface, isNotNull);
        expect(AppColors.onSurface, isNotNull);
        expect(AppColors.background, isNotNull);
        expect(AppColors.onBackground, isNotNull);
        expect(AppColors.surfaceVariant, isNotNull);
        expect(AppColors.onSurfaceVariant, isNotNull);
      });

      test('all error colors are non-null', () {
        expect(AppColors.error, isNotNull);
        expect(AppColors.onError, isNotNull);
        expect(AppColors.errorContainer, isNotNull);
        expect(AppColors.onErrorContainer, isNotNull);
      });

      test('all outline colors are non-null', () {
        expect(AppColors.outline, isNotNull);
        expect(AppColors.outlineVariant, isNotNull);
      });

      test('all inverse colors are non-null', () {
        expect(AppColors.inverseSurface, isNotNull);
        expect(AppColors.onInverseSurface, isNotNull);
        expect(AppColors.inversePrimary, isNotNull);
      });
    });
  });
}
