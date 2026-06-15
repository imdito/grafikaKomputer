import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';

/// A reusable glassmorphic container — the building block for every
/// floating panel, dock, and modal in the Obsidian Glass design system.
///
/// Renders a semi-transparent dark surface with a backdrop blur and a
/// thin white border to simulate frosted-glass depth.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = GrafkomTheme.blurDock,
    this.borderRadius,
    this.padding,
    this.fillColor,
    this.borderColor,
    this.showTopGradient = false,
  });

  /// The content inside the glass container.
  final Widget child;

  /// Backdrop blur intensity. Defaults to [GrafkomTheme.blurDock] (20).
  final double blurSigma;

  /// Corner rounding. Defaults to `radius2xl` (24px) when null.
  final BorderRadius? borderRadius;

  /// Inner padding. Defaults to [GrafkomTheme.panelPadding] (16) when null.
  final EdgeInsetsGeometry? padding;

  /// Override the glass fill color.
  final Color? fillColor;

  /// Override the border color.
  final Color? borderColor;

  /// When `true`, draws a subtle gradient line at the top of the panel
  /// (matches the Transformation Panel design from Stitch).
  final bool showTopGradient;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(GrafkomTheme.radius2xl);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor ?? GrafkomTheme.glassSurface,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? GrafkomTheme.glassBorder,
            ),
          ),
          child: Stack(
            children: [
              // Subtle top gradient line
              if (showTopGradient)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          GrafkomTheme.primary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding ??
                    const EdgeInsets.all(GrafkomTheme.panelPadding),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
