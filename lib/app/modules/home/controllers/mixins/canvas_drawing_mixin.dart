import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../data/models/canvas_models.dart';
import '../../utils/canvas_rasterizer.dart';
import '../../utils/line_algorithms.dart';
import 'canvas_state_mixin.dart';

mixin CanvasDrawingMixin on CanvasStateMixin {
  void handleCanvasTap(Offset position) {
    switch (selectedTool.value) {
      case DrawingTool.point:
        addPointFromTap(position);
      case DrawingTool.line:
        addLineFromTap(position);
      case DrawingTool.shape:
        addShapeFromTap(position);
      case DrawingTool.fill:
        _performFloodFill(position);
      case DrawingTool.pen:
        pendingFreehandPoints.add(position);
        handlePanEnd();
    }
  }

  void handlePanStart(Offset position) {
    if (selectedTool.value != DrawingTool.pen) return;
    pendingFreehandPoints.clear();
    pendingFreehandPoints.add(position);
  }

  void handlePanUpdate(Offset position) {
    if (selectedTool.value != DrawingTool.pen) return;
    pendingFreehandPoints.add(position);
  }

  void handlePanEnd() {
    if (selectedTool.value != DrawingTool.pen) return;
    if (pendingFreehandPoints.isEmpty) return;

    final fh = GrafkomFreehand(
      id: nextId(),
      points: pendingFreehandPoints.toList(),
      strokeWidth: strokeWidth.value,
      strokeStyle: lineStyle.value,
      opacity: lineOpacity.value,
      color: selectedColor.value,
    );
    freehands.add(fh);
    registerObject(CanvasObjectType.freehand, fh.id);
    pendingFreehandPoints.clear();
  }

  void addPointFromTap(Offset position) {
    final point = GrafkomPoint(
      id: nextId(),
      position: position,
      radius: safeRadius(),
      color: selectedColor.value,
    );
    points.add(point);
    registerObject(CanvasObjectType.point, point.id);
  }

  void addPointFromInput() {
    final x = double.tryParse(xController.text);
    final y = double.tryParse(yController.text);

    if (x == null || y == null) {
      showInvalidInput('Masukkan nilai X dan Y titik berupa angka.');
      return;
    }

    final point = GrafkomPoint(
      id: nextId(),
      position: Offset(x, y),
      radius: safeRadius(),
      color: selectedColor.value,
    );
    points.add(point);
    registerObject(CanvasObjectType.point, point.id);

    xController.clear();
    yController.clear();
  }

  void addLineFromTap(Offset position) {
    final start = pendingLineStart.value;

    if (start == null) {
      pendingLineStart.value = position;
      return;
    }

    _addLine(start: start, end: position);
    pendingLineStart.value = null;
  }

  void addLineFromInput() {
    final x1 = double.tryParse(x1Controller.text);
    final y1 = double.tryParse(y1Controller.text);
    final x2 = double.tryParse(x2Controller.text);
    final y2 = double.tryParse(y2Controller.text);

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      showInvalidInput('Masukkan nilai X1, Y1, X2, dan Y2 berupa angka.');
      return;
    }

    _addLine(start: Offset(x1, y1), end: Offset(x2, y2));

    x1Controller.clear();
    y1Controller.clear();
    x2Controller.clear();
    y2Controller.clear();
  }

  void addShapeFromTap(Offset center) {
    _addShape(
      center: center,
      width: safeShapeWidth(),
      height: safeShapeHeight(),
    );
  }

  void addShapeFromInput() {
    final x = double.tryParse(shapeXController.text);
    final y = double.tryParse(shapeYController.text);

    if (x == null || y == null) {
      showInvalidInput('Masukkan nilai X dan Y pusat benda 2D berupa angka.');
      return;
    }

    _addShape(
      center: Offset(x, y),
      width: safeShapeWidth(),
      height: safeShapeHeight(),
    );

    shapeXController.clear();
    shapeYController.clear();
  }

  void cancelPendingLine() {
    pendingLineStart.value = null;
  }

  void _addLine({required Offset start, required Offset end}) {
    final algorithm = selectedAlgorithm.value;
    final line = GrafkomLine(
      id: nextId(),
      start: start,
      end: end,
      algorithm: algorithm,
      strokeWidth: strokeWidth.value,
      strokeStyle: lineStyle.value,
      opacity: lineOpacity.value,
      color: selectedColor.value,
      rasterPoints: LineAlgorithms.generateLinePoints(algorithm, start, end),
    );

    lines.add(line);
    registerObject(CanvasObjectType.line, line.id);
  }

  void _addShape({
    required Offset center,
    required double width,
    required double height,
  }) {
    final type = selectedShapeType.value;
    final adjustedSize = _adjustSizeForShape(type, width, height);
    final shape = GrafkomShape(
      id: nextId(),
      type: type,
      center: center,
      width: adjustedSize.width,
      height: adjustedSize.height,
      strokeWidth: shapeStrokeWidth.value,
      opacity: shapeOpacity.value,
      isFilled: isFilledShape.value,
      color: selectedColor.value,
    );

    shapes.add(shape);
    registerObject(CanvasObjectType.shape, shape.id);
  }

  Size _adjustSizeForShape(ShapeType type, double width, double height) {
    return switch (type) {
      ShapeType.circle ||
      ShapeType.square => Size.square(math.min(width, height)),
      _ => Size(width, height),
    };
  }

  void _performFloodFill(Offset tapPos) {
    final grid = CanvasRasterizer.rasterizeCanvas(
      points: points.toList(growable: false),
      lines: lines.toList(growable: false),
      shapes: shapes.toList(growable: false),
      freehands: freehands.toList(growable: false),
    );

    final filledOffsets = CanvasRasterizer.computeFloodFillOffsets(tapPos, grid);

    if (filledOffsets.isNotEmpty) {
      final fillRegion = GrafkomFillRegion(
        id: nextId(),
        offsets: filledOffsets,
        color: selectedColor.value,
        opacity: shapeOpacity.value,
      );

      fills.add(fillRegion);
      registerObject(CanvasObjectType.fill, fillRegion.id);
    }
  }
}
