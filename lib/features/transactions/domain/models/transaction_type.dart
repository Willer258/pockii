/// Represents the type of a financial transaction.
///
/// Used to distinguish between money going out (expense) and money coming in (income).
enum TransactionType {
  /// Money spent - reduces remaining budget
  expense,

  /// Money received - increases remaining budget
  income,
}

/// Extension for converting TransactionType to/from database string values.
extension TransactionTypeExtension on TransactionType {
  /// Converts this TransactionType to its database string representation.
  String toDbValue() => name;
}

/// Helper class for parsing TransactionType from database values.
class TransactionTypeParser {
  TransactionTypeParser._();

  /// Parses a database string value to TransactionType.
  ///
  /// Returns [TransactionType.expense] as default if the value doesn't match.
  static TransactionType fromDbValue(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionType.expense,
    );
  }
}
