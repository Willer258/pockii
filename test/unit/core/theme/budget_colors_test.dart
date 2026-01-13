import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pockii/core/theme/budget_colors.dart';

void main() {
  group('BudgetColors', () {
    group('Color Constants', () {
      test('ok is correct green (#4CAF50)', () {
        expect(BudgetColors.ok, const Color(0xFF4CAF50));
      });

      test('warning is correct orange (#FF9800)', () {
        expect(BudgetColors.warning, const Color(0xFFFF9800));
      });

      test('danger is correct red (#F44336)', () {
        expect(BudgetColors.danger, const Color(0xFFF44336));
      });
    });

    group('Threshold Constants', () {
      test('okThreshold is 30%', () {
        expect(BudgetColors.okThreshold, 0.30);
      });

      test('warningThreshold is 10%', () {
        expect(BudgetColors.warningThreshold, 0.10);
      });
    });

    group('forPercentage', () {
      test('returns ok for percentage > 30%', () {
        expect(BudgetColors.forPercentage(0.31), BudgetColors.ok);
        expect(BudgetColors.forPercentage(0.50), BudgetColors.ok);
        expect(BudgetColors.forPercentage(0.75), BudgetColors.ok);
        expect(BudgetColors.forPercentage(1.0), BudgetColors.ok);
      });

      test('returns warning for percentage between 10% and 30%', () {
        expect(BudgetColors.forPercentage(0.11), BudgetColors.warning);
        expect(BudgetColors.forPercentage(0.20), BudgetColors.warning);
        expect(BudgetColors.forPercentage(0.30), BudgetColors.warning);
      });

      test('returns danger for percentage <= 10%', () {
        expect(BudgetColors.forPercentage(0.10), BudgetColors.danger);
        expect(BudgetColors.forPercentage(0.05), BudgetColors.danger);
        expect(BudgetColors.forPercentage(0.0), BudgetColors.danger);
      });

      test('returns danger for negative percentage', () {
        expect(BudgetColors.forPercentage(-0.1), BudgetColors.danger);
        expect(BudgetColors.forPercentage(-0.5), BudgetColors.danger);
      });

      test('returns ok for percentage > 100% (overfunded)', () {
        expect(BudgetColors.forPercentage(1.5), BudgetColors.ok);
        expect(BudgetColors.forPercentage(2.0), BudgetColors.ok);
      });

      test('boundary at exactly 30%', () {
        // 30% is the boundary, should return warning (not ok)
        expect(BudgetColors.forPercentage(0.30), BudgetColors.warning);
        // Just above 30% should be ok
        expect(BudgetColors.forPercentage(0.301), BudgetColors.ok);
      });

      test('boundary at exactly 10%', () {
        // 10% is the boundary, should return danger (not warning)
        expect(BudgetColors.forPercentage(0.10), BudgetColors.danger);
        // Just above 10% should be warning
        expect(BudgetColors.forPercentage(0.101), BudgetColors.warning);
      });
    });

    group('forRemaining', () {
      test('returns ok for remaining > 30% of total', () {
        // 100000/300000 = 33.3% > 30% → ok
        expect(BudgetColors.forRemaining(100000, 300000), BudgetColors.ok);
        expect(BudgetColors.forRemaining(150000, 300000), BudgetColors.ok);
        expect(BudgetColors.forRemaining(200000, 300000), BudgetColors.ok);
      });

      test('returns warning for remaining between 10% and 30%', () {
        expect(BudgetColors.forRemaining(60000, 300000), BudgetColors.warning);
        expect(BudgetColors.forRemaining(75000, 300000), BudgetColors.warning);
        expect(BudgetColors.forRemaining(90000, 300000), BudgetColors.warning);
      });

      test('returns danger for remaining <= 10%', () {
        expect(BudgetColors.forRemaining(30000, 300000), BudgetColors.danger);
        expect(BudgetColors.forRemaining(15000, 300000), BudgetColors.danger);
        expect(BudgetColors.forRemaining(0, 300000), BudgetColors.danger);
      });

      test('returns danger for negative remaining (overspent)', () {
        expect(BudgetColors.forRemaining(-10000, 300000), BudgetColors.danger);
        expect(BudgetColors.forRemaining(-50000, 300000), BudgetColors.danger);
      });

      test('returns danger when total is zero', () {
        expect(BudgetColors.forRemaining(0, 0), BudgetColors.danger);
        expect(BudgetColors.forRemaining(100, 0), BudgetColors.danger);
      });

      test('returns danger when total is negative', () {
        expect(BudgetColors.forRemaining(100, -100), BudgetColors.danger);
        expect(BudgetColors.forRemaining(-50, -100), BudgetColors.danger);
      });

      test('handles typical FCFA budget amounts', () {
        // 350,000 FCFA budget scenarios
        const budget = 350000;

        // 200,000 remaining (57%) - OK
        expect(BudgetColors.forRemaining(200000, budget), BudgetColors.ok);

        // 100,000 remaining (28.5%) - Warning
        expect(BudgetColors.forRemaining(100000, budget), BudgetColors.warning);

        // 30,000 remaining (8.5%) - Danger
        expect(BudgetColors.forRemaining(30000, budget), BudgetColors.danger);
      });
    });

    group('statusName', () {
      test('returns correct status names', () {
        expect(BudgetColors.statusName(0.50), 'ok');
        expect(BudgetColors.statusName(0.25), 'warning');
        expect(BudgetColors.statusName(0.05), 'danger');
      });

      test('returns danger for negative percentage', () {
        expect(BudgetColors.statusName(-0.1), 'danger');
      });
    });

    group('accessibilityLabel', () {
      test('returns correct French labels', () {
        expect(BudgetColors.accessibilityLabel(0.50), 'Budget en bonne santé');
        expect(BudgetColors.accessibilityLabel(0.25), 'Budget à surveiller');
        expect(BudgetColors.accessibilityLabel(0.05), 'Budget critique');
      });

      test('returns danger label for negative percentage', () {
        expect(BudgetColors.accessibilityLabel(-0.1), 'Budget critique');
      });
    });
  });
}
