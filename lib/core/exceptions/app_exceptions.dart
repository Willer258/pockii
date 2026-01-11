/// Base class for all application exceptions.
///
/// Uses sealed class pattern to ensure exhaustive handling.
/// NEVER catch generic Exception - always use specific exception types.
sealed class AppException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional stack trace for debugging.
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Exception thrown when database operations fail.
///
/// Examples:
/// - Failed to open encrypted database
/// - Query execution error
/// - Migration failure
class DatabaseException extends AppException {
  /// Optional database error code.
  final int? errorCode;

  const DatabaseException(
    super.message, [
    super.stackTrace,
    this.errorCode,
  ]);

  @override
  String toString() {
    final codeStr = errorCode != null ? ' (code: $errorCode)' : '';
    return 'DatabaseException: $message$codeStr';
  }
}

/// Exception thrown when input validation fails.
///
/// Examples:
/// - Invalid FCFA amount (negative for expense input)
/// - Missing required field
/// - Date range invalid (end before start)
class ValidationException extends AppException {
  /// Name of the field that failed validation.
  final String? fieldName;

  const ValidationException(
    super.message, [
    super.stackTrace,
    this.fieldName,
  ]);

  @override
  String toString() {
    final fieldStr = fieldName != null ? ' [field: $fieldName]' : '';
    return 'ValidationException: $message$fieldStr';
  }
}

/// Exception thrown when secure storage operations fail.
///
/// Examples:
/// - Failed to read encryption key from Keystore
/// - Failed to write to secure storage
/// - Keystore not available
class StorageException extends AppException {
  const StorageException(super.message, [super.stackTrace]);
}

/// Exception thrown when a requested resource is not found.
///
/// Examples:
/// - Budget period not found
/// - Transaction not found by ID
/// - Setting key not found
class NotFoundException extends AppException {
  /// Type of resource that was not found.
  final String resourceType;

  /// Identifier used in the search.
  final String? identifier;

  const NotFoundException(
    this.resourceType, [
    this.identifier,
    StackTrace? stackTrace,
  ]) : super('$resourceType not found${identifier != null ? ': $identifier' : ''}', stackTrace);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when a business rule is violated.
///
/// Examples:
/// - Cannot delete the only budget period
/// - Cannot set budget to zero
/// - Cannot have overlapping budget periods
class BusinessRuleException extends AppException {
  /// Identifier for the business rule that was violated.
  final String ruleCode;

  const BusinessRuleException(
    super.message,
    this.ruleCode, [
    super.stackTrace,
  ]);

  @override
  String toString() => 'BusinessRuleException [$ruleCode]: $message';
}

/// Exception thrown when parsing fails.
///
/// Examples:
/// - Failed to parse SMS message format
/// - Invalid date format in user input
/// - Malformed JSON response
class ParseException extends AppException {
  /// The input that failed to parse.
  final String? input;

  /// The expected format or pattern.
  final String? expectedFormat;

  const ParseException(
    super.message, [
    super.stackTrace,
    this.input,
    this.expectedFormat,
  ]);

  @override
  String toString() {
    final inputStr = input != null ? ' (input: "$input")' : '';
    final formatStr = expectedFormat != null ? ' [expected: $expectedFormat]' : '';
    return 'ParseException: $message$inputStr$formatStr';
  }
}
