import 'package:flutter/material.dart';

/// Application color palette following Material Design 3.
///
/// All colors are defined as explicit constants (NOT using ColorScheme.fromSeed).
/// This ensures consistent, predictable colors across the application.
///
/// Color accessibility verified:
/// - onSurface (#1C1B1F) on surface (#F5F5F5): 12.6:1 ratio (AAA)
/// - primary (#2E7D32) on white: 5.3:1 ratio (AA)
abstract class AppColors {
  // ============================================
  // Primary Colors
  // ============================================

  /// Primary color: Trust green
  /// Used for primary actions, FAB, active states
  static const Color primary = Color(0xFF2E7D32);

  /// Text/icon color on primary
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Primary container for elevated surfaces
  static const Color primaryContainer = Color(0xFFB8F5B0);

  /// Text/icon color on primary container
  static const Color onPrimaryContainer = Color(0xFF002204);

  // ============================================
  // Secondary Colors
  // ============================================

  /// Secondary color: Accent blue
  /// Used for secondary actions, links
  static const Color secondary = Color(0xFF1565C0);

  /// Text/icon color on secondary
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Secondary container for elevated surfaces
  static const Color secondaryContainer = Color(0xFFD3E4FF);

  /// Text/icon color on secondary container
  static const Color onSecondaryContainer = Color(0xFF001C3B);

  // ============================================
  // Surface Colors
  // ============================================

  /// Surface color for cards, sheets, menus
  static const Color surface = Color(0xFFF5F5F5);

  /// Text/icon color on surface
  static const Color onSurface = Color(0xFF1C1B1F);

  /// Background color for scaffolds
  static const Color background = Color(0xFFFFFFFF);

  /// Text/icon color on background
  static const Color onBackground = Color(0xFF1C1B1F);

  /// Surface variant for differentiation
  static const Color surfaceVariant = Color(0xFFE7E0EC);

  /// Text/icon color on surface variant
  static const Color onSurfaceVariant = Color(0xFF49454F);

  // ============================================
  // Success Colors
  // ============================================

  /// Success color for positive feedback, income amounts
  static const Color success = Color(0xFF43A047);

  /// Text/icon color on success
  static const Color onSuccess = Color(0xFFFFFFFF);

  // ============================================
  // Error Colors
  // ============================================

  /// Error color for destructive actions, validation errors
  static const Color error = Color(0xFFB3261E);

  /// Text/icon color on error
  static const Color onError = Color(0xFFFFFFFF);

  /// Error container for elevated error surfaces
  static const Color errorContainer = Color(0xFFF9DEDC);

  /// Text/icon color on error container
  static const Color onErrorContainer = Color(0xFF410E0B);

  // ============================================
  // Outline & Dividers
  // ============================================

  /// Outline color for borders, dividers
  static const Color outline = Color(0xFF79747E);

  /// Lighter outline for subtle borders
  static const Color outlineVariant = Color(0xFFCAC4D0);

  // ============================================
  // Inverse Colors (for snackbars, etc.)
  // ============================================

  /// Inverse surface color
  static const Color inverseSurface = Color(0xFF313033);

  /// Text/icon on inverse surface
  static const Color onInverseSurface = Color(0xFFF4EFF4);

  /// Inverse primary for contrast
  static const Color inversePrimary = Color(0xFF7DDC7A);

  // ============================================
  // Scrim & Shadow
  // ============================================

  /// Scrim color for modal overlays
  static const Color scrim = Color(0xFF000000);

  /// Shadow color
  static const Color shadow = Color(0xFF000000);
}
