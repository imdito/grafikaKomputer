import 'package:flutter/material.dart';

import '../../../../data/models/canvas_models.dart';
import '../../../../../features/output_primitives/math/line_algorithms.dart';
import '../../../../../features/output_primitives/math/bezier_algorithms.dart';
import '../../../../../features/output_primitives/line_tool/line_controller.dart';
import '../../../../../features/output_primitives/shape_tool/shape_controller.dart';
import '../../../../../features/attributes/object_selection/select_controller.dart';
import '../../../../../features/fill_area/flood_fill/flood_fill_controller.dart';
import 'package:get/get.dart';
import 'canvas_state_mixin.dart';

/// Mixin yang bertanggung jawab untuk menangani logika menggambar pada canvas
/// (termasuk interaksi sentuh dan eksekusi algoritma garis).
mixin CanvasDrawingMixin on CanvasStateMixin {
  /// Menangani event ketukan (tap) pada canvas berdasarkan mode alat yang aktif.
  void handleCanvasTap(Offset position) {
    switch (selectedTool.value) {
      case DrawingTool.hand:
        break;
      case DrawingTool.attributes:
        if (Get.isRegistered<SelectController>()) {
          Get.find<SelectController>().handleCanvasTap(position);
        }
        break;
      case DrawingTool.transformations:
        if (Get.isRegistered<SelectController>()) {
          Get.find<SelectController>().handleCanvasTap(position);
        }
        break;
      case DrawingTool.primitives:
        addLineFromTap(position);
        break;
      case DrawingTool.curve:
        addCurveFromTap(position);
        break;
      case DrawingTool.shape:
        if (Get.isRegistered<ShapeController>()) {
          Get.find<ShapeController>().addShapeFromTap(position);
        }
        break;
      case DrawingTool.fill:
        if (Get.isRegistered<FloodFillController>()) {
          Get.find<FloodFillController>().performFloodFill(position);
        }
        break;
      case DrawingTool.pen:
        // Handled by PenController's pan events in InteractiveCanvas
        break;
    }
  }

  // Legacy freehand and shape methods moved to PenController and ShapeController
  // The logic is now encapsulated within the respective feature controllers.

  /// Menambahkan titik awal/akhir untuk mode garis dua-ketuk (two-tap line mode).
  void addLineFromTap(Offset position) {
    final start = pendingLineStart.value;

    if (start == null) {
      pendingLineStart.value = position;
      return;
    }

    // Get the algorithm from the new LineController via Get.find
    // Wait, to keep CanvasDrawingMixin independent or loosely coupled,
    // we can either inject LineController or pass the algorithm.
    // Let's use LineController's selected algorithm if available.
    // For now, if we use the central state, we just add line.
    // Actually, LineController handles the UI, so handleCanvasTap will read from LineController.
    // We'll pass the currently selected algorithm.
    final algo = Get.isRegistered<LineController>()
        ? Get.find<LineController>().selectedAlgorithm.value
        : LineAlgorithm.dda;

    addLine(start: start, end: position, algorithm: algo);
    pendingLineStart.value = null;
  }

  /// Menambahkan titik untuk mode kurva 3-ketukan (three-tap quadratic Bezier curve mode).
  void addCurveFromTap(Offset position) {
    final start = pendingCurveStart.value;
    final end = pendingCurveEnd.value;

    if (start == null) {
      pendingCurveStart.value = position;
      return;
    }

    if (end == null) {
      pendingCurveEnd.value = position;
      return;
    }

    // Ketukan ke-3 menetapkan Titik Kontrol (P1) dan menyelesaikan kurva
    addCurve(start: start, control: position, end: end);
    pendingCurveStart.value = null;
    pendingCurveEnd.value = null;
  }

  /// Menambahkan garis berdasarkan input koordinat manual.
  /// Moved to LineController, but keeping a wrapper here if needed.
  /// (Deprecated, use LineController directly)
  void addLineFromInput() {
    // Legacy method - functionality moved to LineController.
  }

  /// Membatalkan proses pembuatan garis yang masih menggantung (pending).
  void cancelPendingLine() {
    pendingLineStart.value = null;
  }

  /// Membatalkan proses pembuatan kurva yang masih menggantung (pending).
  void cancelPendingCurve() {
    pendingCurveStart.value = null;
    pendingCurveEnd.value = null;
  }

  void addLine({
    required Offset start,
    required Offset end,
    required LineAlgorithm algorithm,
  }) {
    List<Offset> points = LineAlgorithms.generateLinePoints(
      algorithm,
      start,
      end,
    );

    final line = GrafkomLine(
      id: nextId(),
      start: start,
      end: end,
      algorithm: algorithm,
      strokeWidth: strokeWidth.value,
      strokeStyle: lineStyle.value,
      opacity: lineOpacity.value,
      color: selectedColor.value,
      rasterPoints: points,
    );

    activeLayer.lines.add(line);
    registerObject(CanvasObjectType.line, line.id);
  }

  void addCurve({
    required Offset start,
    required Offset control,
    required Offset end,
  }) {
    final points = BezierAlgorithms.generateBezierPoints(start, control, end);

    final curve = GrafkomCurve(
      id: nextId(),
      start: start,
      control: control,
      end: end,
      strokeWidth: strokeWidth.value,
      opacity: lineOpacity.value,
      color: selectedColor.value,
      rasterPoints: points,
    );

    activeLayer.curves.add(curve);
    registerObject(CanvasObjectType.curve, curve.id);
  }

  void addPoint({required Offset position, required double radius}) {
    final point = GrafkomPoint(
      id: nextId(),
      position: position,
      radius: radius,
      color: selectedColor.value,
    );

    activeLayer.points.add(point);
    registerObject(CanvasObjectType.point, point.id);
  }

  void addShape({
    required ShapeType type,
    required Offset center,
    required double width,
    required double height,
    required bool isFilled,
  }) {
    final shape = GrafkomShape(
      id: nextId(),
      type: type,
      center: center,
      width: width,
      height: height,
      strokeWidth: shapeStrokeWidth.value,
      opacity: shapeOpacity.value,
      isFilled: isFilled,
      color: selectedColor.value,
    );

    activeLayer.shapes.add(shape);
    registerObject(CanvasObjectType.shape, shape.id);
  }

  void addFreehand(List<Offset> points) {
    final fh = GrafkomFreehand(
      id: nextId(),
      points: points,
      strokeWidth: strokeWidth.value,
      strokeStyle: lineStyle.value,
      opacity: lineOpacity.value,
      color: selectedColor.value,
    );
    activeLayer.freehands.add(fh);
    registerObject(CanvasObjectType.freehand, fh.id);
  }

  // Logic for _performFloodFill moved to FloodFillController.
}
