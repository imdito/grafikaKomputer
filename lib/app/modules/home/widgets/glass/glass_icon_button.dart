import 'package:flutter/material.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';

/// A circular icon button styled for the Obsidian Glass design system.
///
/// - **Default**: Transparent background, white icon.
/// - **Active**: `white/20` background, slight scale-up, filled icon.
/// - Includes hover state with `white/10` overlay.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
    this.size = 48,
    this.iconSize = 24,
    this.dimmed = false,
  });

  /// The Material icon to display.
  final IconData icon;

  /// Callback when the button is tapped.
  final VoidCallback onPressed;

  /// Whether this button is in its "active/selected" state.
  final bool isActive;

  /// Optional tooltip text shown on long-press/hover.
  final String? tooltip;

  /// Outer diameter of the button.
  final double size;

  /// Size of the icon inside the button.
  final double iconSize;

  /// When `true`, renders at 50% opacity (e.g. disabled redo).
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size * 1.2,
      height: size * 1.2,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isActive ? size * 1.15 : size,
          height: isActive ? size * 1.15 : size,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              hoverColor: Colors.white.withValues(alpha: 0.1),
              splashColor: Colors.white.withValues(alpha: 0.15),
              customBorder: const CircleBorder(),
              child: Center(
                child: Opacity(
                  opacity: dimmed ? 0.5 : 1.0,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: isActive
                        ? GrafkomTheme.primary
                        : GrafkomTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }
    return button;
  }
}
