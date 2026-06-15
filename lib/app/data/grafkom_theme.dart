import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens extracted from the Stitch "Obsidian Glass" design system.
/// Centralized here so every widget references the same source of truth.
abstract final class GrafkomTheme {
  // ─── Colors ───────────────────────────────────────────────────────────
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF393939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1B1B1B);
  static const Color surfaceContainer = Color(0xFF1F1F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353535);
  static const Color surfaceVariant = Color(0xFF353535);

  static const Color onSurface = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFFC4C7C8);

  static const Color primary = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF2F3131);
  static const Color primaryContainer = Color(0xFFE2E2E2);

  static const Color secondary = Color(0xFFC7C6C6);
  static const Color secondaryContainer = Color(0xFF484949);

  static const Color outline = Color(0xFF8E9192);
  static const Color outlineVariant = Color(0xFF444748);

  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  // Glass-specific
  static const Color glassSurface = Color(0x99000000); // rgba(0,0,0,0.6)
  static const Color glassBorder = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  static const Color gridLine = Color(0x1AB1B1B1); // rgba(177,177,177,0.1)

  // ─── Blur Levels ──────────────────────────────────────────────────────
  /// Level 2: persistent docks (bottom bar, undo/redo pill)
  static const double blurDock = 20.0;

  /// Level 3: modals, contextual panels (transform panel, properties)
  static const double blurModal = 30.0;

  // ─── Spacing ──────────────────────────────────────────────────────────
  static const double unit = 4.0;
  static const double elementGap = 8.0;
  static const double panelPadding = 16.0;
  static const double gutter = 16.0;
  static const double marginMobile = 20.0;

  // ─── Border Radius ────────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 9999.0;

  // ─── Typography ───────────────────────────────────────────────────────
  static TextStyle get headlineLg => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        letterSpacing: -0.48, // -0.02em at 24px
        color: onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurface,
      );

  static TextStyle get labelLg => GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.14, // 0.01em at 14px
        color: onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 14 / 10,
        color: onSurfaceVariant,
      );

  // ─── ThemeData Builder ────────────────────────────────────────────────
  /// Produces the full dark [ThemeData] that matches the Obsidian Glass spec.
  static ThemeData buildTheme() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        error: error,
        errorContainer: errorContainer,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerHighest: surfaceContainerHighest,
        surfaceContainerHigh: surfaceContainerHigh,
        surfaceContainer: surfaceContainer,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerLowest: surfaceContainerLowest,
        surfaceBright: surfaceBright,
        surfaceDim: surfaceDim,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      cardTheme: CardThemeData(
        color: glassSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius2xl),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        labelStyle: labelMd.copyWith(color: onSurfaceVariant),
        hintStyle: bodyMd.copyWith(color: onSurfaceVariant),
        isDense: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceContainerHigh,
        contentTextStyle: bodyMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
