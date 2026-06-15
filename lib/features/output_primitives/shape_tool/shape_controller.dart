import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/data/models/canvas_models.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';
import 'dart:math' as math;

/// Controller managing the state and logic for the Shape Tool.
class ShapeController extends GetxController {
  final shapeXController = TextEditingController();
  final shapeYController = TextEditingController();
  final shapeWidthController = TextEditingController(text: '120');
  final shapeHeightController = TextEditingController(text: '80');

  final selectedShapeType = ShapeType.circle.obs;
  final isFilledShape = false.obs;

  final pendingShape = Rxn<GrafkomShape>();
  Offset? _startPosition;

  @override
  void onClose() {
    shapeXController.dispose();
    shapeYController.dispose();
    shapeWidthController.dispose();
    shapeHeightController.dispose();
    super.onClose();
  }

  double safeShapeWidth() {
    final width = double.tryParse(shapeWidthController.text) ?? 120;
    return width.clamp(10, 500).toDouble();
  }

  double safeShapeHeight() {
    final height = double.tryParse(shapeHeightController.text) ?? 80;
    return height.clamp(10, 500).toDouble();
  }

  Size adjustSizeForShape(ShapeType type, double width, double height) {
    return switch (type) {
      ShapeType.circle ||
      ShapeType.square => Size.square(math.min(width, height)),
      _ => Size(width, height),
    };
  }

  void addShapeFromInput() {
    final x = double.tryParse(shapeXController.text);
    final y = double.tryParse(shapeYController.text);

    if (x == null || y == null) {
      Get.snackbar(
        'Input tidak valid',
        'Masukkan nilai X dan Y pusat benda 2D berupa angka.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _dispatchShape(center: Offset(x, y));

    shapeXController.clear();
    shapeYController.clear();
  }

  void addShapeFromTap(Offset center) {
    _dispatchShape(center: center);
  }

  void _dispatchShape({required Offset center}) {
    final type = selectedShapeType.value;
    final adjustedSize = adjustSizeForShape(type, safeShapeWidth(), safeShapeHeight());
    
    Get.find<HomeController>().addShape(
      type: type,
      center: center,
      width: adjustedSize.width,
      height: adjustedSize.height,
      isFilled: isFilledShape.value,
    );
  }

  void handlePanStart(Offset position) {
    _startPosition = position;
    final homeController = Get.find<HomeController>();
    pendingShape.value = GrafkomShape(
      id: -1,
      type: selectedShapeType.value,
      center: position,
      width: 0,
      height: 0,
      strokeWidth: homeController.shapeStrokeWidth.value,
      opacity: homeController.shapeOpacity.value,
      isFilled: isFilledShape.value,
      color: homeController.selectedColor.value,
    );
  }

  void handlePanUpdate(Offset position) {
    final start = _startPosition;
    if (start == null) return;

    final type = selectedShapeType.value;
    double dx = position.dx - start.dx;
    double dy = position.dy - start.dy;
    double absX = dx.abs();
    double absY = dy.abs();

    if (type == ShapeType.circle || type == ShapeType.square) {
      double maxSide = math.max(absX, absY);
      dx = dx.sign * maxSide;
      dy = dy.sign * maxSide;
    }

    final rect = Rect.fromPoints(start, start + Offset(dx, dy));
    final center = rect.center;
    final width = rect.width;
    final height = rect.height;

    final homeController = Get.find<HomeController>();
    pendingShape.value = GrafkomShape(
      id: -1,
      type: type,
      center: center,
      width: width,
      height: height,
      strokeWidth: homeController.shapeStrokeWidth.value,
      opacity: homeController.shapeOpacity.value,
      isFilled: isFilledShape.value,
      color: homeController.selectedColor.value,
    );
  }

  void handlePanEnd() {
    final shape = pendingShape.value;
    if (shape != null && (shape.width > 2 || shape.height > 2)) {
      Get.find<HomeController>().addShape(
        type: shape.type,
        center: shape.center,
        width: shape.width,
        height: shape.height,
        isFilled: shape.isFilled,
      );
    }
    pendingShape.value = null;
    _startPosition = null;
  }
}
