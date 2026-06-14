import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/control_panel.dart';
import '../widgets/floating_object_editor.dart';
import '../widgets/selection_panel.dart';
import '../widgets/grafkom_canvas_painter.dart';
import '../widgets/canvas_overlays.dart';
import '../../../data/models/canvas_models.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  static const _canvasSize = Size(2400, 1800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafika Komputer'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Export Gambar',
            onPressed: controller.exportCanvas,
            icon: const Icon(Icons.ios_share),
          ),
          IconButton(
            tooltip: 'Undo objek terakhir',
            onPressed: controller.undoLast,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: 'Hapus canvas',
            onPressed: controller.clearCanvas,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(900),
                minScale: 0.25,
                maxScale: 4,
                child: Obx(() {
                  final selectedCenter = controller.selectedObjectCenter;

                  return SizedBox(
                    width: _canvasSize.width,
                    height: _canvasSize.height,
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
                                  size: _canvasSize,
                                  painter: GrafkomCanvasPainter(
                                    points: controller.points.toList(
                                      growable: false,
                                    ),
                                    lines: controller.lines.toList(growable: false),
                                    shapes: controller.shapes.toList(
                                      growable: false,
                                    ),
                                    fills: controller.fills.toList(growable: false),
                                    freehands: controller.freehands.toList(growable: false),
                                    pendingLineStart:
                                        controller.pendingLineStart.value,
                                    pendingFreehandPoints: controller.pendingFreehandPoints.toList(growable: false),
                                    selectedObject: controller.selectedObject.value,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (controller.selectedTool.value == DrawingTool.fill &&
                            controller.hoverPosition.value != null)
                          Positioned(
                            left: controller.hoverPosition.value!.dx,
                            top: controller.hoverPosition.value!.dy - 20,
                            child: IgnorePointer(
                              child: Icon(
                                Icons.format_color_fill,
                                color: controller.selectedColor.value,
                                size: 28,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(1.5, 1.5),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (selectedCenter != null)
                          Positioned(
                            left: _floatingEditorLeft(selectedCenter),
                            top: _floatingEditorTop(selectedCenter),
                            child: FloatingObjectEditor(
                              controller: controller,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Obx(
              () => CanvasHint(
                tool: controller.selectedTool.value,
                hasPendingLine: controller.pendingLineStart.value != null,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: Obx(
              () => ObjectCounter(
                totalPoints: controller.points.length,
                totalLines: controller.lines.length,
                totalShapes: controller.shapes.length,
                totalFills: controller.fills.length,
              ),
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 16,
            child: CanvasNavigationHint(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showControlMenu(context),
        icon: const Icon(Icons.tune),
        label: const Text('Menu'),
      ),
    );
  }

  void _showControlMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ControlPanel(controller: controller),
          ),
        );
      },
    );
  }

  double _floatingEditorLeft(Offset center) {
    return (center.dx + 28).clamp(16, _canvasSize.width - 380).toDouble();
  }

  double _floatingEditorTop(Offset center) {
    return (center.dy + 28).clamp(16, _canvasSize.height - 360).toDouble();
  }
}

