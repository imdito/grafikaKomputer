import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/data/models/canvas_models.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';

/// Controller managing the state and logic for the Pen (Freehand) Tool.
class PenController extends GetxController {
  /// Reactive list of points for the current stroke being drawn
  final pendingFreehandPoints = <Offset>[].obs;

  /// Handles the start of a freehand stroke
  void handlePanStart(Offset position) {
    final homeController = Get.find<HomeController>();
    if (homeController.selectedTool.value != DrawingTool.pen) return;

    pendingFreehandPoints.clear();
    pendingFreehandPoints.add(position);
  }

  /// Handles the movement of a freehand stroke
  void handlePanUpdate(Offset position) {
    final homeController = Get.find<HomeController>();
    if (homeController.selectedTool.value != DrawingTool.pen) return;

    pendingFreehandPoints.add(position);
  }

  /// Finalizes the freehand stroke and dispatches it to the canvas state
  void handlePanEnd() {
    final homeController = Get.find<HomeController>();
    if (homeController.selectedTool.value != DrawingTool.pen) return;
    if (pendingFreehandPoints.isEmpty) return;

    // Dispatch to the central state
    homeController.addFreehand(pendingFreehandPoints.toList());

    pendingFreehandPoints.clear();
  }
}
