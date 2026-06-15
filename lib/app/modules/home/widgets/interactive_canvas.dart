import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/canvas_models.dart';
import '../controllers/home_controller.dart';
import '../../../../features/output_primitives/pen_tool/pen_controller.dart';
import '../../../../features/output_primitives/shape_tool/shape_controller.dart';
import '../controllers/dock_controller.dart';
import 'grafkom_canvas_painter.dart';

/// Widget utama yang menangani Interaksi pengguna (Tap, Pan, Hover)
/// dan rendering canvas melalui CustomPaint.
class InteractiveCanvas extends StatelessWidget {
  const InteractiveCanvas({
    super.key,
    required this.controller,
    required this.canvasSize,
  });

  /// Referensi ke HomeController
  final HomeController controller;
  
  /// Ukuran area gambar
  final Size canvasSize;

  @override
  Widget build(BuildContext context) {
    final penController = Get.isRegistered<PenController>() ? Get.find<PenController>() : null;

    return Obx(() {
      return InteractiveViewer(
        onInteractionStart: (details) {
          if (Get.isRegistered<DockController>()) {
            Get.find<DockController>().isToolPanelVisible.value = false;
          }
        },
        panEnabled: controller.selectedTool.value == DrawingTool.hand,
        scaleEnabled: true,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(900),
        minScale: 0.25,
      maxScale: 4,
      child: SizedBox(
        width: canvasSize.width,
        height: canvasSize.height,
        child: Obx(() {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: MouseRegion(
                  cursor: controller.selectedTool.value == DrawingTool.fill
                      ? SystemMouseCursors.none
                      : MouseCursor.defer,
                  onHover: (event) {
                    controller.updateHoverPosition(event.localPosition);
                  },
                  onExit: (event) {
                    controller.clearHoverPosition();
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      controller.handleCanvasTap(details.localPosition);
                    },
                    onPanStart: (controller.selectedTool.value == DrawingTool.pen || controller.selectedTool.value == DrawingTool.shape)
                        ? (details) {
                            if (Get.isRegistered<DockController>()) {
                              final dockCtrl = Get.find<DockController>();
                              dockCtrl.wasPanelVisibleBeforeDrag = dockCtrl.isToolPanelVisible.value;
                              dockCtrl.isToolPanelVisible.value = false;
                            }
                            if (controller.selectedTool.value == DrawingTool.pen) {
                              penController?.handlePanStart(details.localPosition);
                            } else {
                              if (Get.isRegistered<ShapeController>()) {
                                Get.find<ShapeController>().handlePanStart(details.localPosition);
                              }
                            }
                          }
                        : null,
                    onPanUpdate: (controller.selectedTool.value == DrawingTool.pen || controller.selectedTool.value == DrawingTool.shape)
                        ? (details) {
                            if (controller.selectedTool.value == DrawingTool.pen) {
                              penController?.handlePanUpdate(details.localPosition);
                            } else {
                              if (Get.isRegistered<ShapeController>()) {
                                Get.find<ShapeController>().handlePanUpdate(details.localPosition);
                              }
                            }
                          }
                        : null,
                    onPanEnd: (controller.selectedTool.value == DrawingTool.pen || controller.selectedTool.value == DrawingTool.shape)
                        ? (details) {
                            if (controller.selectedTool.value == DrawingTool.pen) {
                              penController?.handlePanEnd();
                            } else {
                              if (Get.isRegistered<ShapeController>()) {
                                Get.find<ShapeController>().handlePanEnd();
                              }
                            }
                            if (Get.isRegistered<DockController>()) {
                              final dockCtrl = Get.find<DockController>();
                              if (dockCtrl.wasPanelVisibleBeforeDrag) {
                                dockCtrl.isToolPanelVisible.value = true;
                                dockCtrl.wasPanelVisibleBeforeDrag = false;
                              }
                            }
                          }
                        : null,
                    child: RepaintBoundary(
                      key: controller.canvasKey,
                      child: CustomPaint(
                        size: canvasSize,
                        painter: GrafkomCanvasPainter(
                          layers: controller.layers.toList(growable: false),
                          pendingLineStart: controller.pendingLineStart.value,
                          pendingFreehandPoints: penController?.pendingFreehandPoints.toList(growable: false) ?? [],
                          selectedObject: controller.selectedObject.value,
                          pendingCurveStart: controller.pendingCurveStart.value,
                          pendingCurveEnd: controller.pendingCurveEnd.value,
                          pendingShape: Get.isRegistered<ShapeController>()
                              ? Get.find<ShapeController>().pendingShape.value
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Kursor Custom untuk mode Fill
              if (controller.selectedTool.value == DrawingTool.fill && controller.hoverPosition.value != null)
                Positioned(
                  left: controller.hoverPosition.value!.dx,
                  top: controller.hoverPosition.value!.dy - 24,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.format_color_fill,
                      color: controller.selectedColor.value,
                      shadows: const [
                        Shadow(blurRadius: 2, color: Colors.white)
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      );
    });
  }
}
