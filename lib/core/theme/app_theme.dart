import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_border_radius.dart';

/// Application theme configuration using Material Design 3.
///
/// Provides both light and dark themes with explicit ColorScheme
/// (NOT using ColorScheme.fromSeed for predictable colors).
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light(),
///   darkTheme: AppTheme.dark(), // Post-MVP
/// )
/// ```
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme for the application (MVP default).
  ///
  /// Uses explicit colors from [AppColors] for consistent,
  /// predictable appearance across all devices.
  static ThemeData light() => _buildTheme(Brightness.light);

  /// Dark theme for the application (prepared for post-MVP).
  ///
  /// Structure is in place but not fully implemented.
  /// Colors will need adjustment for dark mode accessibility.
  static ThemeData dark() => _buildTheme(Brightness.dark);

  /// Internal theme builder.
  ///
  /// Creates a complete ThemeData with all component themes configured
  /// for consistent appearance throughout the app.
  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Build explicit ColorScheme (NOT fromSeed)
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      // Primary
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      // Secondary
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      // Error
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      // Surface (adjusted for dark mode)
      surface: isDark ? const Color(0xFF1C1B1F) : AppColors.surface,
      onSurface: isDark ? const Color(0xFFE6E1E5) : AppColors.onSurface,
      surfaceContainerHighest:
          isDark ? const Color(0xFF49454F) : AppColors.surfaceVariant,
      onSurfaceVariant:
          isDark ? const Color(0xFFCAC4D0) : AppColors.onSurfaceVariant,
      // Outline
      outline: isDark ? const Color(0xFF938F99) : AppColors.outline,
      outlineVariant:
          isDark ? const Color(0xFF49454F) : AppColors.outlineVariant,
      // Inverse
      inverseSurface: isDark ? AppColors.surface : AppColors.inverseSurface,
      onInverseSurface:
          isDark ? AppColors.onSurface : AppColors.onInverseSurface,
      inversePrimary: AppColors.inversePrimary,
      // Scrim & Shadow
      scrim: AppColors.scrim,
      shadow: AppColors.shadow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,

      // ============================================
      // Scaffold
      // ============================================
      scaffoldBackgroundColor:
          isDark ? colorScheme.surface : AppColors.background,

      // ============================================
      // App Bar
      // ============================================
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.title.copyWith(
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurface,
          size: AppSpacing.iconSize,
        ),
      ),

      // ============================================
      // Card
      // ============================================
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.cardRadius,
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      // ============================================
      // Elevated Button
      // ============================================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          shadowColor: colorScheme.shadow.withOpacity(0.15),
          minimumSize: Size(double.infinity, AppSpacing.touchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTypography.label,
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
        ),
      ),

      // ============================================
      // Text Button
      // ============================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: Size(AppSpacing.touchTarget, AppSpacing.touchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          textStyle: AppTypography.label,
          foregroundColor: colorScheme.primary,
        ),
      ),

      // ============================================
      // Outlined Button
      // ============================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, AppSpacing.touchTarget),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.buttonRadius,
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.label,
          foregroundColor: colorScheme.primary,
        ),
      ),

      // ============================================
      // Floating Action Button
      // ============================================
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        highlightElevation: 8,
        shape: const CircleBorder(),
        sizeConstraints: BoxConstraints.tight(
          Size(AppSpacing.fabSize, AppSpacing.fabSize),
        ),
      ),

      // ============================================
      // Bottom Navigation Bar
      // ============================================
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        elevation: 8,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        selectedLabelStyle: AppTypography.caption.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: AppTypography.caption,
        showUnselectedLabels: true,
      ),

      // ============================================
      // Navigation Bar (Material 3)
      // ============================================
      navigationBarTheme: NavigationBarThemeData(
        height: AppSpacing.bottomNavHeight,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            );
          }
          return AppTypography.caption.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: colorScheme.onPrimaryContainer,
              size: AppSpacing.iconSize,
            );
          }
          return IconThemeData(
            color: colorScheme.onSurface.withOpacity(0.6),
            size: AppSpacing.iconSize,
          );
        }),
      ),

      // ============================================
      // Chip
      // ============================================
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surface.withOpacity(0.38),
        labelStyle: AppTypography.label,
        secondaryLabelStyle: AppTypography.label,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chipRadius,
          side: BorderSide(color: colorScheme.outline),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),

      // ============================================
      // Snackbar
      // ============================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTypography.body.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chipRadius,
        ),
        elevation: 6,
        actionTextColor: colorScheme.inversePrimary,
      ),

      // ============================================
      // Bottom Sheet
      // ============================================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.bottomSheetRadius,
        ),
        elevation: 8,
        modalElevation: 16,
        showDragHandle: true,
        dragHandleColor: colorScheme.onSurface.withOpacity(0.4),
        dragHandleSize: const Size(32, 4),
      ),

      // ============================================
      // Dialog
      // ============================================
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.dialogRadius,
        ),
        titleTextStyle: AppTypography.title.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTypography.body.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // ============================================
      // Input Decoration
      // ============================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.chipRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.chipRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.chipRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.chipRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.chipRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: AppTypography.body.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        hintStyle: AppTypography.body.copyWith(
          color: colorScheme.onSurface.withOpacity(0.4),
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: colorScheme.error,
        ),
      ),

      // ============================================
      // Divider
      // ============================================
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ============================================
      // Icon
      // ============================================
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSpacing.iconSize,
      ),

      // ============================================
      // List Tile
      // ============================================
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        minVerticalPadding: AppSpacing.sm,
        shape: RoundedRectangleBorder(
          borderRadius: AppBorderRadius.chipRadius,
        ),
        titleTextStyle: AppTypography.body.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTypography.caption.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
        ),
        leadingAndTrailingTextStyle: AppTypography.label.copyWith(
          color: colorScheme.onSurface,
        ),
        iconColor: colorScheme.onSurface.withOpacity(0.6),
      ),

      // ============================================
      // Progress Indicator
      // ============================================
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withOpacity(0.2),
        circularTrackColor: colorScheme.primary.withOpacity(0.2),
      ),
    );
  }
}
