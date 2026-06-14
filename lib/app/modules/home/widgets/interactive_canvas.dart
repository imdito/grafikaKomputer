import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/canvas_models.dart';
import '../controllers/home_controller.dart';
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
    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(900),
      minScale: 0.25,
      maxScale: 4,
      child: Obx(() {
        return SizedBox(
          width: canvasSize.width,
          height: canvasSize.height,
          child: Stack(
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
                    onPanStart: controller.selectedTool.value == DrawingTool.pen
                        ? (details) {
                            controller.handlePanStart(details.localPosition);
                          }
                        : null,
                    onPanUpdate: controller.selectedTool.value == DrawingTool.pen
                        ? (details) {
                            controller.handlePanUpdate(details.localPosition);
                          }
                        : null,
                    onPanEnd: controller.selectedTool.value == DrawingTool.pen
                        ? (details) {
                            controller.handlePanEnd();
                          }
                        : null,
                    child: RepaintBoundary(
                      key: controller.canvasKey,
                      child: CustomPaint(
                        size: canvasSize,
                        painter: GrafkomCanvasPainter(
                          points: controller.points.toList(growable: false),
                          lines: controller.lines.toList(growable: false),
                          shapes: controller.shapes.toList(growable: false),
                          fills: controller.fills.toList(growable: false),
                          freehands: controller.freehands.toList(growable: false),
                          pendingLineStart: controller.pendingLineStart.value,
                          pendingFreehandPoints: controller.pendingFreehandPoints.toList(growable: false),
                          selectedObject: controller.selectedObject.value,
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
          ),
        );
      }),
    );
  }
}
