/// Utility class for formatting and parsing FCFA (Franc CFA) amounts.
///
/// CRITICAL ARCHITECTURE RULE: All monetary values in this app are
/// stored and handled as integers. NEVER use double for money.
///
/// The FCFA has no decimal subdivisions (unlike EUR cents or USD cents),
/// so integer representation is both accurate and appropriate.
class FcfaFormatter {
  FcfaFormatter._(); // Private constructor - use static methods only

  /// Formats an integer amount as a readable FCFA string.
  ///
  /// Uses space as thousand separator (French locale convention).
  ///
  /// Examples:
  /// - format(0) => "0 FCFA"
  /// - format(1000) => "1 000 FCFA"
  /// - format(350000) => "350 000 FCFA"
  /// - format(999999999) => "999 999 999 FCFA"
  /// - format(-5000) => "-5 000 FCFA"
  static String format(int amountFcfa) {
    final isNegative = amountFcfa < 0;
    final absAmount = amountFcfa.abs();

    final formatted = absAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );

    final prefix = isNegative ? '-' : '';
    return '$prefix$formatted FCFA';
  }

  /// Formats an integer amount as a compact string (without "FCFA" suffix).
  ///
  /// Useful for input fields where the suffix is shown separately.
  ///
  /// Examples:
  /// - formatCompact(350000) => "350 000"
  static String formatCompact(int amountFcfa) {
    final isNegative = amountFcfa < 0;
    final absAmount = amountFcfa.abs();

    final formatted = absAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );

    return isNegative ? '-$formatted' : formatted;
  }

  /// Parses a string to extract the FCFA amount as an integer.
  ///
  /// Strips all non-digit characters (except leading minus sign) and parses.
  /// Returns 0 if the string cannot be parsed.
  ///
  /// Examples:
  /// - parse("350 000 FCFA") => 350000
  /// - parse("350000") => 350000
  /// - parse("1 000 000") => 1000000
  /// - parse("invalid") => 0
  /// - parse("") => 0
  /// - parse("-5000") => -5000
  /// - parse("-5 000 FCFA") => -5000
  static int parse(String input) {
    if (input.isEmpty) return 0;

    // Check for negative sign
    final isNegative = input.trimLeft().startsWith('-');

    // Strip all non-digits
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) return 0;

    final value = int.tryParse(digits) ?? 0;
    return isNegative ? -value : value;
  }

  /// Validates that the input string represents a valid FCFA amount.
  ///
  /// Returns true if the string can be parsed to a valid integer.
  static bool isValid(String input) {
    if (input.isEmpty) return false;
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    return digits.isNotEmpty && int.tryParse(digits) != null;
  }

  /// Formats amount with sign indicator for transaction display.
  ///
  /// Expenses (negative) show as "-350 000 FCFA"
  /// Income (positive) show as "+350 000 FCFA"
  static String formatWithSign(int amountFcfa) {
    if (amountFcfa == 0) return format(0);
    final prefix = amountFcfa > 0 ? '+' : '';
    return '$prefix${format(amountFcfa)}';
  }
}
