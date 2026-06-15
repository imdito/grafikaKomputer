import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';
import 'canvas_hit_tester.dart';

class SelectController extends GetxController {
  void handleCanvasTap(Offset position) {
    final homeController = Get.find<HomeController>();

    for (int i = homeController.layers.length - 1; i >= 0; i--) {
      final layer = homeController.layers[i];
      if (!layer.isVisible) continue;
      final hitRef = CanvasHitTester.hitTest(
        tapPosition: position,
        points: layer.points,
        lines: layer.lines,
        shapes: layer.shapes,
        freehands: layer.freehands,
      );
      if (hitRef != null) {
        homeController.selectedObject.value = hitRef;
        homeController.activeLayerIndex.value = i;
        return;
      }
    }
    homeController.selectedObject.value = null;
  }
}
