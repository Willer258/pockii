import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockii/core/theme/app_typography.dart';

void main() {
  group('AppTypography', () {
    group('Font Family', () {
      test('fontFamily is Inter', () {
        expect(AppTypography.fontFamily, 'Inter');
      });
    });

    group('Size Constants', () {
      test('heroSize is 56.0', () {
        expect(AppTypography.heroSize, 56.0);
      });

      test('headlineSize is 32.0', () {
        expect(AppTypography.headlineSize, 32.0);
      });

      test('titleSize is 24.0', () {
        expect(AppTypography.titleSize, 24.0);
      });

      test('titleSmallSize is 20.0', () {
        expect(AppTypography.titleSmallSize, 20.0);
      });

      test('bodyLargeSize is 18.0', () {
        expect(AppTypography.bodyLargeSize, 18.0);
      });

      test('bodySize is 16.0', () {
        expect(AppTypography.bodySize, 16.0);
      });

      test('labelSize is 14.0', () {
        expect(AppTypography.labelSize, 14.0);
      });

      test('captionSize is 12.0', () {
        expect(AppTypography.captionSize, 12.0);
      });
    });

    group('Hero Style', () {
      test('has correct font family', () {
        expect(AppTypography.hero.fontFamily, 'Inter');
      });

      test('has correct font size (56sp)', () {
        expect(AppTypography.hero.fontSize, 56.0);
      });

      test('has bold weight (700)', () {
        expect(AppTypography.hero.fontWeight, FontWeight.w700);
      });

      test('has tight line height', () {
        expect(AppTypography.hero.height, 1.1);
      });

      test('has negative letter spacing', () {
        expect(AppTypography.hero.letterSpacing, -0.5);
      });
    });

    group('Headline Style', () {
      test('has correct font family', () {
        expect(AppTypography.headline.fontFamily, 'Inter');
      });

      test('has correct font size (32sp)', () {
        expect(AppTypography.headline.fontSize, 32.0);
      });

      test('has semibold weight (600)', () {
        expect(AppTypography.headline.fontWeight, FontWeight.w600);
      });
    });

    group('Title Style', () {
      test('has correct font family', () {
        expect(AppTypography.title.fontFamily, 'Inter');
      });

      test('has correct font size (24sp)', () {
        expect(AppTypography.title.fontSize, 24.0);
      });

      test('has semibold weight (600)', () {
        expect(AppTypography.title.fontWeight, FontWeight.w600);
      });
    });

    group('Body Style', () {
      test('has correct font family', () {
        expect(AppTypography.body.fontFamily, 'Inter');
      });

      test('has correct font size (16sp)', () {
        expect(AppTypography.body.fontSize, 16.0);
      });

      test('has regular weight (400)', () {
        expect(AppTypography.body.fontWeight, FontWeight.w400);
      });

      test('has comfortable line height', () {
        expect(AppTypography.body.height, 1.5);
      });
    });

    group('Label Style', () {
      test('has correct font family', () {
        expect(AppTypography.label.fontFamily, 'Inter');
      });

      test('has correct font size (14sp)', () {
        expect(AppTypography.label.fontSize, 14.0);
      });

      test('has medium weight (500)', () {
        expect(AppTypography.label.fontWeight, FontWeight.w500);
      });
    });

    group('Caption Style', () {
      test('has correct font family', () {
        expect(AppTypography.caption.fontFamily, 'Inter');
      });

      test('has correct font size (12sp)', () {
        expect(AppTypography.caption.fontSize, 12.0);
      });

      test('has regular weight (400)', () {
        expect(AppTypography.caption.fontWeight, FontWeight.w400);
      });
    });

    group('All styles use Inter font', () {
      test('all styles have Inter as font family', () {
        expect(AppTypography.hero.fontFamily, 'Inter');
        expect(AppTypography.headline.fontFamily, 'Inter');
        expect(AppTypography.title.fontFamily, 'Inter');
        expect(AppTypography.titleSmall.fontFamily, 'Inter');
        expect(AppTypography.bodyLarge.fontFamily, 'Inter');
        expect(AppTypography.body.fontFamily, 'Inter');
        expect(AppTypography.bodyMedium.fontFamily, 'Inter');
        expect(AppTypography.label.fontFamily, 'Inter');
        expect(AppTypography.labelLarge.fontFamily, 'Inter');
        expect(AppTypography.caption.fontFamily, 'Inter');
        expect(AppTypography.captionMedium.fontFamily, 'Inter');
      });
    });

    group('Font weights are correct', () {
      test('hero and headline use appropriate weights', () {
        // Hero should be bold (700)
        expect(AppTypography.hero.fontWeight, FontWeight.w700);
        // Headline should be semibold (600)
        expect(AppTypography.headline.fontWeight, FontWeight.w600);
      });

      test('body styles use regular weight', () {
        expect(AppTypography.body.fontWeight, FontWeight.w400);
        expect(AppTypography.bodyLarge.fontWeight, FontWeight.w400);
        expect(AppTypography.caption.fontWeight, FontWeight.w400);
      });

      test('label styles use medium weight', () {
        expect(AppTypography.label.fontWeight, FontWeight.w500);
        expect(AppTypography.captionMedium.fontWeight, FontWeight.w500);
      });
    });

    group('withColor helper', () {
      test('creates new TextStyle with specified color', () {
        const testColor = Colors.red;
        final coloredStyle = AppTypography.withColor(AppTypography.body, testColor);

        expect(coloredStyle.color, testColor);
        expect(coloredStyle.fontSize, AppTypography.body.fontSize);
        expect(coloredStyle.fontWeight, AppTypography.body.fontWeight);
        expect(coloredStyle.fontFamily, AppTypography.body.fontFamily);
      });

      test('does not modify original style', () {
        const testColor = Colors.blue;
        AppTypography.withColor(AppTypography.hero, testColor);

        // Original should not have a color set
        expect(AppTypography.hero.color, isNull);
      });
    });

    group('Typography scale consistency', () {
      test('sizes decrease from hero to caption', () {
        expect(AppTypography.heroSize, greaterThan(AppTypography.headlineSize));
        expect(AppTypography.headlineSize, greaterThan(AppTypography.titleSize));
        expect(AppTypography.titleSize, greaterThan(AppTypography.titleSmallSize));
        expect(AppTypography.titleSmallSize, greaterThan(AppTypography.bodyLargeSize));
        expect(AppTypography.bodyLargeSize, greaterThan(AppTypography.bodySize));
        expect(AppTypography.bodySize, greaterThan(AppTypography.labelSize));
        expect(AppTypography.labelSize, greaterThan(AppTypography.captionSize));
      });
    });
  });
}
