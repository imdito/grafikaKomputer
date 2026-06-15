import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/dock_controller.dart';
import '../../../data/models/canvas_models.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import 'glass/glass_container.dart';
import '../../../../features/output_primitives/line_tool/line_view.dart';
import '../../../../features/output_primitives/pen_tool/pen_view.dart';
import '../../../../features/output_primitives/shape_tool/shape_view.dart';
import '../../../../features/output_primitives/curve_tool/curve_view.dart';
import '../../../../features/fill_area/fill_area_hub_view.dart';
import '../../../../features/attributes/attributes_hub_view.dart';
import '../../../../features/transformations/transformations_hub_view.dart';

/// Contextual panel that pops out above the FloatingToolDock
/// Displays properties specific to the currently selected tool.
class ContextualToolPanel extends StatelessWidget {
  const ContextualToolPanel({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 380, // Slimmer profile like Procreate's pop-ups
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: GlassContainer(
          blurSigma: GrafkomTheme.blurModal,
          borderRadius: BorderRadius.circular(GrafkomTheme.radius2xl),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header Close Button ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Get.isRegistered<DockController>()) {
                        Get.find<DockController>().isToolPanelVisible.value = false;
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // ── Contextual Content ──
              Flexible(
                child: SingleChildScrollView(
                  child: Obx(() {
                    return switch (controller.selectedTool.value) {
                      DrawingTool.attributes => const AttributesHubView(),
                      DrawingTool.hand => const Center(
                        child: Text(
                          'Pan Mode Active',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      DrawingTool.primitives => const LineView(),
                      DrawingTool.shape => const ShapeView(),
                      DrawingTool.fill => const FillAreaHubView(),
                      DrawingTool.pen => const PenView(),
                      DrawingTool.curve => const CurveView(),
                      DrawingTool.transformations => TransformationsHubView(
                        controller: controller,
                        enabled: true,
                      ),
                    };
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
