import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import '../../../data/models/canvas_models.dart';
import '../controllers/home_controller.dart';
import '../controllers/dock_controller.dart';
import 'glass/glass_container.dart';
import 'glass/glass_icon_button.dart';

/// A pill-shaped floating dock pinned to the bottom of the screen.
///
/// Contains the five primary drawing tools plus optional action buttons.
/// Replaces the old `ToolSelector` that lived inside the BottomSheet.
class FloatingToolDock extends StatelessWidget {
  const FloatingToolDock({super.key, required this.controller});

  /// Reference to the [HomeController].
  final HomeController controller;

  /// Maps each [DrawingTool] to its Material icon.
  static const _toolIcons = <DrawingTool, IconData>{
    DrawingTool.hand: Icons.pan_tool_outlined,
    DrawingTool.attributes: Icons.palette_outlined,
    DrawingTool.pen: Icons.gesture_rounded,
    DrawingTool.primitives: Icons.category_rounded,
    DrawingTool.curve: Icons.polyline_rounded,
    DrawingTool.shape: Icons.pentagon_outlined,
    DrawingTool.fill: Icons.format_color_fill_rounded,
    DrawingTool.transformations: Icons.transform_rounded,
  };

  /// Tooltip labels for each tool.
  static const _toolLabels = <DrawingTool, String>{
    DrawingTool.hand: 'Pan Mode',
    DrawingTool.attributes: 'Attributes',
    DrawingTool.pen: 'Freehand',
    DrawingTool.primitives: 'Primitives',
    DrawingTool.curve: 'Bezier Curve',
    DrawingTool.shape: 'Shape',
    DrawingTool.fill: 'Fill',
    DrawingTool.transformations: 'Transform',
  };

  String _getTooltip(DrawingTool tool, HomeController controller) {
    final hasPendingLine = controller.pendingLineStart.value != null;
    final hasPendingCurve = controller.pendingCurveStart.value != null;
    return switch (tool) {
      DrawingTool.hand => 'Pan Mode: Sentuh dan geser untuk navigasi canvas',
      DrawingTool.attributes =>
        'Attributes: Ubah warna, ketebalan, gaya garis, atau pilih objek',
      DrawingTool.primitives =>
        hasPendingLine
            ? 'Primitives: Tap titik akhir atau tekan batal'
            : 'Primitives: Pilih jenis primitif di menu dan tap canvas',
      DrawingTool.curve =>
        hasPendingCurve
            ? 'Curve: Tap untuk menentukan titik akhir/kontrol'
            : 'Curve: Buat kurva Bezier dengan 3 ketukan di canvas',
      DrawingTool.shape => 'Shape: Tap canvas untuk membuat benda 2D',
      DrawingTool.fill =>
        'Fill Area: Tap di dalam area tertutup untuk mengisi warna',
      DrawingTool.pen => 'Freehand: Sentuh dan tarik (drag) pada canvas',
      DrawingTool.transformations =>
        'Transformations: Modifikasi posisi, rotasi, skala, dan shear objek',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: GrafkomTheme.marginMobile,
      left: GrafkomTheme.marginMobile,
      right: GrafkomTheme.marginMobile,
      child: Center(
        child: Obx(() {
          final activeTool = controller.selectedTool.value;
          // Read pending state values here so the Obx triggers when they change
          final _ = controller.pendingLineStart.value;
          final __ = controller.pendingCurveStart.value;

          return GlassContainer(
            blurSigma: GrafkomTheme.blurDock,
            borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
            // Remove horizontal padding so scroll spans the full width and clips with the curve
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              // Removed extra horizontal padding here to balance left/right edge spacing
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Drawing tools ──
                  ..._toolIcons.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ), // Reduced padding to tighten spacing
                      child: GlassIconButton(
                        size:
                            42, // Make the icons slightly smaller for a slimmer dock
                        icon: entry.value,
                        tooltip: _getTooltip(entry.key, controller),
                        isActive: activeTool == entry.key,
                        onPressed: () {
                          controller.selectedTool.value = entry.key;
                          if (Get.isRegistered<DockController>()) {
                            Get.find<DockController>().isToolPanelVisible.value =
                                (entry.key != DrawingTool.shape);
                          }
                        },
                      ),
                    );
                  }),

                  // ── Divider ──
                  Container(
                    width: 1,
                    height:
                        28, // Slightly shorter divider to match slimmer dock
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    color: GrafkomTheme.glassBorder,
                  ),

                  // ── Layers button ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GlassIconButton(
                      size: 42,
                      icon: Icons.layers_rounded,
                      tooltip: 'Layers',
                      isActive: controller.isLayerPanelVisible.value,
                      onPressed: () {
                        controller.isLayerPanelVisible.value =
                            !controller.isLayerPanelVisible.value;
                      },
                    ),
                  ),

                  // Removed settings button as per new architecture
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
