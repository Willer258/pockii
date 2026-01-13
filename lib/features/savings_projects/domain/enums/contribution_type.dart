/// Types of contributions to savings projects.
enum ContributionType {
  deposit('deposit', 'Dépôt'),
  withdrawal('withdrawal', 'Retrait'),
  autoDeposit('auto_deposit', 'Dépôt automatique'),
  autoFailed('auto_failed', 'Échec automatique');

  const ContributionType(this.value, this.displayName);

  /// Database value.
  final String value;

  /// Localized display name.
  final String displayName;

  /// Get type from database value.
  static ContributionType fromValue(String value) {
    return ContributionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ContributionType.deposit,
    );
  }

  /// Whether this is a deposit (adds money).
  bool get isDeposit =>
      this == ContributionType.deposit || this == ContributionType.autoDeposit;

  /// Whether this is automatic.
  bool get isAutomatic =>
      this == ContributionType.autoDeposit || this == ContributionType.autoFailed;
}
