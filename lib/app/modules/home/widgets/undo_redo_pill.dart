import 'package:flutter/material.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import '../controllers/home_controller.dart';
import 'glass/glass_container.dart';
import 'glass/glass_icon_button.dart';

/// A small glassmorphic pill at the top-left of the screen containing
/// Undo and Redo buttons separated by a vertical divider.
///
/// Matches the Stitch design: `blur(20)`, `rounded-full`, glass surface
/// with a thin white border.
class UndoRedoPill extends StatelessWidget {
  const UndoRedoPill({super.key, required this.controller});

  /// Reference to the [HomeController].
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    // Use SafeArea to respect the status bar
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + GrafkomTheme.marginMobile,
      left: GrafkomTheme.marginMobile,
      child: GlassContainer(
        blurSigma: GrafkomTheme.blurDock,
        borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassIconButton(
              icon: Icons.undo_rounded,
              tooltip: 'Undo',
              size: 40,
              iconSize: 20,
              onPressed: controller.undoLast,
            ),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: GrafkomTheme.glassBorder,
            ),
            GlassIconButton(
              icon: Icons.redo_rounded,
              tooltip: 'Redo',
              size: 40,
              iconSize: 20,
              dimmed: true, // Redo not yet implemented
              onPressed: () {}, // Placeholder
            ),
          ],
        ),
      ),
    );
  }
}
