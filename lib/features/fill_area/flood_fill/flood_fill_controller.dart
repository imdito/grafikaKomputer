import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/data/models/canvas_models.dart';
import '../../../../app/modules/home/controllers/home_controller.dart';
import '../math/canvas_rasterizer.dart';

class FloodFillController extends GetxController {
  final isSampleAllLayersActive = true.obs;

  void performFloodFill(Offset tapPos) {
    final homeController = Get.find<HomeController>();

    final List<GrafkomPoint> rasterPoints = [];
    final List<GrafkomLine> rasterLines = [];
    final List<GrafkomShape> rasterShapes = [];
    final List<GrafkomFreehand> rasterFreehands = [];

    final bool sampleAllLayers = isSampleAllLayersActive.value; 

    if (sampleAllLayers) {
      for (final layer in homeController.layers) {
        if (layer.isVisible) {
          rasterPoints.addAll(layer.points);
          rasterLines.addAll(layer.lines);
          rasterShapes.addAll(layer.shapes);
          rasterFreehands.addAll(layer.freehands);
        }
      }
    } else {
      final layer = homeController.activeLayer;
      if (layer.isVisible) {
        rasterPoints.addAll(layer.points);
        rasterLines.addAll(layer.lines);
        rasterShapes.addAll(layer.shapes);
        rasterFreehands.addAll(layer.freehands);
      }
    }

    final grid = CanvasRasterizer.rasterizeCanvas(
      points: rasterPoints,
      lines: rasterLines,
      shapes: rasterShapes,
      freehands: rasterFreehands,
    );

    final filledOffsets = CanvasRasterizer.computeFloodFillOffsets(tapPos, grid);

    if (filledOffsets.isNotEmpty) {
      final fillRegion = GrafkomFillRegion(
        id: homeController.nextId(),
        offsets: filledOffsets,
        color: homeController.selectedColor.value,
        opacity: homeController.shapeOpacity.value,
      );

      homeController.activeLayer.fills.add(fillRegion);
      homeController.registerObject(CanvasObjectType.fill, fillRegion.id);
    }
  }
}
