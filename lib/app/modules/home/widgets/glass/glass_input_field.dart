import 'package:flutter/material.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';

/// A styled numeric input field for the Obsidian Glass design system.
///
/// Matches the Transformation Panel design from Stitch:
/// - Dark `white/5` background with `glassBorder` outline.
/// - Left-aligned axis label (e.g. "X", "Y", "Deg").
/// - Right-aligned numeric value in white.
class GlassInputField extends StatelessWidget {
  const GlassInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    this.textAlign = TextAlign.right,
  });

  /// The text editing controller for this field.
  final TextEditingController controller;

  /// A short prefix label (e.g. "X", "Y", "Deg") displayed at the start.
  final String? label;

  /// Hint text displayed when the field is empty.
  final String? hint;

  /// Keyboard type. Defaults to numeric.
  final TextInputType keyboardType;

  /// Alignment of the input text. Defaults to right-aligned.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(GrafkomTheme.radiusMd),
        border: Border.all(color: GrafkomTheme.glassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: GrafkomTheme.labelMd.copyWith(
                color: GrafkomTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: textAlign,
              style: GrafkomTheme.bodyMd.copyWith(
                color: GrafkomTheme.primary,
              ),
              decoration: InputDecoration.collapsed(
                hintText: hint ?? '0',
                hintStyle: GrafkomTheme.bodyMd.copyWith(
                  color: GrafkomTheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
