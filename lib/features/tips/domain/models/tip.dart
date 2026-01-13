import '../enums/tip_category.dart';

/// A financial tip or advice.
class Tip {
  const Tip({
    required this.id,
    required this.content,
    required this.category,
    this.source,
  });

  /// Unique identifier.
  final String id;

  /// The tip content in French.
  final String content;

  /// Category of the tip.
  final TipCategory category;

  /// Optional source or attribution.
  final String? source;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tip && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
