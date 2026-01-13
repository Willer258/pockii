import 'package:flutter_test/flutter_test.dart';
import 'package:pockii/shared/utils/fcfa_formatter.dart';

void main() {
  group('FcfaFormatter', () {
    group('format', () {
      test('formats zero correctly', () {
        expect(FcfaFormatter.format(0), '0 FCFA');
      });

      test('formats small numbers without separators', () {
        expect(FcfaFormatter.format(1), '1 FCFA');
        expect(FcfaFormatter.format(100), '100 FCFA');
        expect(FcfaFormatter.format(999), '999 FCFA');
      });

      test('formats thousands with space separator', () {
        expect(FcfaFormatter.format(1000), '1 000 FCFA');
        expect(FcfaFormatter.format(9999), '9 999 FCFA');
      });

      test('formats tens of thousands', () {
        expect(FcfaFormatter.format(10000), '10 000 FCFA');
        expect(FcfaFormatter.format(50000), '50 000 FCFA');
        expect(FcfaFormatter.format(99999), '99 999 FCFA');
      });

      test('formats hundreds of thousands', () {
        expect(FcfaFormatter.format(100000), '100 000 FCFA');
        expect(FcfaFormatter.format(350000), '350 000 FCFA');
        expect(FcfaFormatter.format(999999), '999 999 FCFA');
      });

      test('formats millions', () {
        expect(FcfaFormatter.format(1000000), '1 000 000 FCFA');
        expect(FcfaFormatter.format(5500000), '5 500 000 FCFA');
      });

      test('formats very large numbers', () {
        expect(FcfaFormatter.format(999999999), '999 999 999 FCFA');
      });

      test('formats negative numbers with minus sign', () {
        expect(FcfaFormatter.format(-1000), '-1 000 FCFA');
        expect(FcfaFormatter.format(-350000), '-350 000 FCFA');
      });
    });

    group('formatCompact', () {
      test('formats without FCFA suffix', () {
        expect(FcfaFormatter.formatCompact(0), '0');
        expect(FcfaFormatter.formatCompact(1000), '1 000');
        expect(FcfaFormatter.formatCompact(350000), '350 000');
      });

      test('handles negative numbers', () {
        expect(FcfaFormatter.formatCompact(-5000), '-5 000');
      });
    });

    group('parse', () {
      test('parses formatted FCFA string', () {
        expect(FcfaFormatter.parse('350 000 FCFA'), 350000);
        expect(FcfaFormatter.parse('1 000 000 FCFA'), 1000000);
      });

      test('parses plain number string', () {
        expect(FcfaFormatter.parse('350000'), 350000);
        expect(FcfaFormatter.parse('1000'), 1000);
      });

      test('parses string with spaces only', () {
        expect(FcfaFormatter.parse('1 000 000'), 1000000);
        expect(FcfaFormatter.parse('350 000'), 350000);
      });

      test('returns 0 for empty string', () {
        expect(FcfaFormatter.parse(''), 0);
      });

      test('returns 0 for invalid string', () {
        expect(FcfaFormatter.parse('invalid'), 0);
        expect(FcfaFormatter.parse('abc'), 0);
        expect(FcfaFormatter.parse('FCFA'), 0);
      });

      test('extracts numbers from mixed content', () {
        expect(FcfaFormatter.parse('Budget: 50000 FCFA restant'), 50000);
        expect(FcfaFormatter.parse('abc123def'), 123);
      });

      test('parses negative numbers', () {
        expect(FcfaFormatter.parse('-5000'), -5000);
        expect(FcfaFormatter.parse('-5 000 FCFA'), -5000);
        expect(FcfaFormatter.parse('  -350 000'), -350000);
      });

      test('parses zero', () {
        expect(FcfaFormatter.parse('0'), 0);
        expect(FcfaFormatter.parse('0 FCFA'), 0);
      });
    });

    group('isValid', () {
      test('returns true for valid number strings', () {
        expect(FcfaFormatter.isValid('1000'), true);
        expect(FcfaFormatter.isValid('350 000 FCFA'), true);
        expect(FcfaFormatter.isValid('0'), true);
      });

      test('returns false for empty string', () {
        expect(FcfaFormatter.isValid(''), false);
      });

      test('returns false for non-numeric strings', () {
        expect(FcfaFormatter.isValid('abc'), false);
        expect(FcfaFormatter.isValid('FCFA'), false);
      });
    });

    group('formatWithSign', () {
      test('adds plus sign to positive amounts', () {
        expect(FcfaFormatter.formatWithSign(1000), '+1 000 FCFA');
        expect(FcfaFormatter.formatWithSign(350000), '+350 000 FCFA');
      });

      test('keeps minus sign for negative amounts', () {
        expect(FcfaFormatter.formatWithSign(-1000), '-1 000 FCFA');
        expect(FcfaFormatter.formatWithSign(-350000), '-350 000 FCFA');
      });

      test('formats zero without sign', () {
        expect(FcfaFormatter.formatWithSign(0), '0 FCFA');
      });
    });

    group('round-trip consistency', () {
      test('format then parse returns original value', () {
        const testValues = [0, 1, 100, 1000, 50000, 350000, 999999999];
        for (final value in testValues) {
          final formatted = FcfaFormatter.format(value);
          final parsed = FcfaFormatter.parse(formatted);
          expect(parsed, value, reason: 'Failed for $value');
        }
      });
    });
  });
}
