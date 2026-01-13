import 'package:pockii/core/database/app_database.dart';
import 'package:drift/drift.dart';

import '../../../budget_rules/domain/enums/expense_category.dart';
import 'transaction_type.dart';

/// Domain model representing a financial transaction.
///
/// This is the presentation-layer representation of a transaction,
/// using typed enums instead of raw strings for the type field.
/// Uses int for FCFA amounts (ARCH-7).
class TransactionModel {
  /// Creates a new TransactionModel.
  const TransactionModel({
    required this.id,
    required this.amountFcfa,
    required this.category,
    required this.type,
    required this.date,
    required this.createdAt,
    this.note,
  });

  /// Creates a TransactionModel from a drift Transaction entity.
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel(
      id: entity.id,
      amountFcfa: entity.amountFcfa,
      category: entity.category,
      type: TransactionTypeParser.fromDbValue(entity.type),
      date: entity.date,
      createdAt: entity.createdAt,
      note: entity.note,
    );
  }

  /// Unique identifier for this transaction.
  final int id;

  /// Transaction amount in FCFA (integer only, never double).
  final int amountFcfa;

  /// Transaction category (e.g., 'transport', 'food', 'salary').
  final String category;

  /// Type of transaction (expense or income).
  final TransactionType type;

  /// Optional note/description for the transaction.
  final String? note;

  /// Date when the transaction occurred.
  final DateTime date;

  /// Timestamp when this record was created.
  final DateTime createdAt;

  /// Returns the budget category (Besoins/Envies/Épargne) for 50/30/20 rule.
  ///
  /// Uses intelligent mapping based on transaction category and note.
  /// Only applies to expense transactions.
  ExpenseCategory get budgetCategory {
    if (type == TransactionType.income) {
      // Income doesn't count towards spending categories
      return ExpenseCategory.savings;
    }
    // Use category first, then note for more context
    final textToAnalyze = '$category ${note ?? ''}'.toLowerCase();
    return DefaultCategoryMappings.guessCategory(textToAnalyze);
  }

  /// Converts this model to a drift TransactionsCompanion for insertion.
  ///
  /// The [id] is not included as it's auto-generated.
  TransactionsCompanion toCompanion() {
    return TransactionsCompanion.insert(
      amountFcfa: amountFcfa,
      category: category,
      type: type.toDbValue(),
      note: Value.absentIfNull(note),
      date: date,
    );
  }

  /// Creates a copy of this TransactionModel with the given fields replaced.
  ///
  /// To explicitly clear the note, set [clearNote] to true.
  TransactionModel copyWith({
    int? id,
    int? amountFcfa,
    String? category,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
    String? note,
    bool clearNote = false,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amountFcfa: amountFcfa ?? this.amountFcfa,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.amountFcfa == amountFcfa &&
        other.category == category &&
        other.type == type &&
        other.note == note &&
        other.date == date &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amountFcfa,
      category,
      type,
      note,
      date,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amountFcfa: $amountFcfa, '
        'category: $category, type: $type, note: $note, '
        'date: $date, createdAt: $createdAt)';
  }
}
