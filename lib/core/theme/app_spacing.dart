/// Application spacing constants based on 8dp base unit.
///
/// Consistent spacing throughout the app improves visual harmony
/// and makes the UI feel more polished and professional.
///
/// The spacing scale follows Material Design principles:
/// - xs (4dp): Minimal internal spacing
/// - sm (8dp): Component internal padding
/// - md (16dp): Element margins
/// - lg (24dp): Section spacing
/// - xl (32dp): Screen margins
/// - xxl (48dp): Major spacing
///
/// All values are in logical pixels (dp).
abstract class AppSpacing {
  // ============================================
  // Base Unit
  // ============================================

  /// Base spacing unit (8dp).
  /// All other spacing values are multiples of this.
  static const double base = 8.0;

  // ============================================
  // Spacing Scale
  // ============================================

  /// Extra small spacing (4dp).
  /// Use for: minimal internal spacing, icon-to-text gaps
  static const double xs = 4.0;

  /// Small spacing (8dp).
  /// Use for: component internal padding, tight list items
  static const double sm = 8.0;

  /// Medium spacing (16dp).
  /// Use for: element margins, card padding, list item spacing
  static const double md = 16.0;

  /// Large spacing (24dp).
  /// Use for: section spacing, dialog padding
  static const double lg = 24.0;

  /// Extra large spacing (32dp).
  /// Use for: screen margins, major section breaks
  static const double xl = 32.0;

  /// Extra extra large spacing (48dp).
  /// Use for: hero sections, major layout spacing
  static const double xxl = 48.0;

  // ============================================
  // Semantic Spacing
  // ============================================

  /// Horizontal padding for screen content.
  /// Applied to left and right edges of screens.
  static const double screenPadding = 16.0;

  /// Vertical padding for screen content.
  /// Applied to top and bottom of scrollable content.
  static const double screenPaddingVertical = 24.0;

  /// Internal padding for cards and containers.
  static const double cardPadding = 16.0;

  /// Spacing between list items.
  static const double listItemSpacing = 8.0;

  /// Spacing between sections on a screen.
  static const double sectionSpacing = 24.0;

  /// Gap between form fields.
  static const double formFieldGap = 16.0;

  /// Gap between buttons in a button row.
  static const double buttonGap = 8.0;

  // ============================================
  // Touch Targets (Accessibility)
  // ============================================

  /// Minimum touch target size (48dp).
  /// Required for WCAG accessibility compliance.
  /// All interactive elements must be at least this size.
  static const double touchTarget = 48.0;

  /// Minimum touch target for compact layouts (40dp).
  /// Use only when space is severely constrained.
  static const double touchTargetCompact = 40.0;

  // ============================================
  // Component-Specific Sizes
  // ============================================

  /// Height for standard text input fields.
  static const double inputHeight = 56.0;

  /// Height for bottom navigation bar.
  static const double bottomNavHeight = 80.0;

  /// Height for app bar.
  static const double appBarHeight = 56.0;

  /// Size for standard icons.
  static const double iconSize = 24.0;

  /// Size for small icons.
  static const double iconSizeSmall = 20.0;

  /// Size for large icons.
  static const double iconSizeLarge = 32.0;

  /// FAB size (standard).
  static const double fabSize = 56.0;

  /// FAB size (small).
  static const double fabSizeSmall = 40.0;
}
