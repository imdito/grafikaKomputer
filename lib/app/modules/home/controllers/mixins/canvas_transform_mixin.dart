import 'package:flutter/material.dart';

import '../../../../data/models/canvas_models.dart';
import '../../utils/canvas_transformations.dart';
import '../../utils/line_algorithms.dart';
import 'canvas_state_mixin.dart';

mixin CanvasTransformMixin on CanvasStateMixin {
  void applyTranslation() {
    final dx = double.tryParse(translateXController.text);
    final dy = double.tryParse(translateYController.text);

    if (dx == null || dy == null) {
      showInvalidInput('Masukkan nilai translasi X dan Y berupa angka.');
      return;
    }

    _transformSelected(
      point: (point) =>
          point.copyWith(position: point.position + Offset(dx, dy)),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => offset + Offset(dx, dy),
      ),
      shape: (shape) => shape.copyWith(center: shape.center + Offset(dx, dy)),
    );
  }

  void applyScale() {
    final sx = double.tryParse(scaleXController.text);
    final sy = double.tryParse(scaleYController.text);

    if (sx == null || sy == null || sx == 0 || sy == 0) {
      showInvalidInput('Masukkan skala X dan Y berupa angka selain 0.');
      return;
    }

    _transformSelected(
      point: (point) => point.copyWith(
        radius: (point.radius * ((sx.abs() + sy.abs()) / 2))
            .clamp(1, 120)
            .toDouble(),
      ),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => CanvasTransformations.scaleAround(offset, line.center, sx, sy),
      ),
      shape: (shape) => shape.copyWith(
        width: (shape.width * sx.abs()).clamp(2, 2000).toDouble(),
        height: (shape.height * sy.abs()).clamp(2, 2000).toDouble(),
        flipX: sx.isNegative ? -shape.flipX : shape.flipX,
        flipY: sy.isNegative ? -shape.flipY : shape.flipY,
      ),
    );
  }

  void applyRotation() {
    final degrees = double.tryParse(rotateController.text);

    if (degrees == null) {
      showInvalidInput('Masukkan sudut rotasi berupa angka derajat.');
      return;
    }

    final radians = CanvasTransformations.degreesToRadians(degrees);

    _transformSelected(
      point: (point) => point,
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => CanvasTransformations.rotateAround(offset, line.center, radians),
      ),
      shape: (shape) =>
          shape.copyWith(rotationRadians: shape.rotationRadians + radians),
    );
  }

  void applyShear() {
    final shearX = double.tryParse(shearXController.text);
    final shearY = double.tryParse(shearYController.text);

    if (shearX == null || shearY == null) {
      showInvalidInput('Masukkan nilai shear X dan Y berupa angka.');
      return;
    }

    _transformSelected(
      point: (point) => point,
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => CanvasTransformations.shearAround(offset, line.center, shearX, shearY),
      ),
      shape: (shape) => shape.copyWith(
        shearX: shape.shearX + shearX,
        shearY: shape.shearY + shearY,
      ),
    );
  }

  void reflectHorizontal() {
    _transformSelected(
      point: (point) => point,
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => Offset(2 * line.center.dx - offset.dx, offset.dy),
      ),
      shape: (shape) => shape.copyWith(flipX: -shape.flipX),
    );
  }

  void reflectVertical() {
    _transformSelected(
      point: (point) => point,
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => Offset(offset.dx, 2 * line.center.dy - offset.dy),
      ),
      shape: (shape) => shape.copyWith(flipY: -shape.flipY),
    );
  }

  void mirrorGlobalX() {
    const globalY = 900.0; // Setengah dari tinggi canvas 1800
    _transformSelected(
      point: (point) => point.copyWith(
        position: Offset(point.position.dx, 2 * globalY - point.position.dy),
      ),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => Offset(offset.dx, 2 * globalY - offset.dy),
      ),
      shape: (shape) => shape.copyWith(
        center: Offset(shape.center.dx, 2 * globalY - shape.center.dy),
        flipY: -shape.flipY,
      ),
    );
  }

  void mirrorGlobalY() {
    const globalX = 1200.0; // Setengah dari lebar canvas 2400
    _transformSelected(
      point: (point) => point.copyWith(
        position: Offset(2 * globalX - point.position.dx, point.position.dy),
      ),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => Offset(2 * globalX - offset.dx, offset.dy),
      ),
      shape: (shape) => shape.copyWith(
        center: Offset(2 * globalX - shape.center.dx, shape.center.dy),
        flipX: -shape.flipX,
      ),
    );
  }

  void mirrorGlobalOrigin() {
    const globalX = 1200.0;
    const globalY = 900.0;
    _transformSelected(
      point: (point) => point.copyWith(
        position: Offset(
          2 * globalX - point.position.dx,
          2 * globalY - point.position.dy,
        ),
      ),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => Offset(2 * globalX - offset.dx, 2 * globalY - offset.dy),
      ),
      shape: (shape) => shape.copyWith(
        center: Offset(
          2 * globalX - shape.center.dx,
          2 * globalY - shape.center.dy,
        ),
        flipX: -shape.flipX,
        flipY: -shape.flipY,
      ),
    );
  }

  void _transformSelected({
    required GrafkomPoint Function(GrafkomPoint point) point,
    required GrafkomLine Function(GrafkomLine line) line,
    required GrafkomShape Function(GrafkomShape shape) shape,
  }) {
    final ref = selectedObject.value;
    if (ref == null) {
      showInvalidInput('Pilih objek terlebih dahulu dari Object Selection.');
      return;
    }

    switch (ref.type) {
      case CanvasObjectType.point:
        final index = points.indexWhere((item) => item.id == ref.id);
        if (index == -1) return;
        points[index] = point(points[index]);
      case CanvasObjectType.line:
        final index = lines.indexWhere((item) => item.id == ref.id);
        if (index == -1) return;
        lines[index] = line(lines[index]);
      case CanvasObjectType.shape:
        final index = shapes.indexWhere((item) => item.id == ref.id);
        if (index == -1) return;
        shapes[index] = shape(shapes[index]);
      case CanvasObjectType.fill:
        break;
      case CanvasObjectType.freehand:
        final index = freehands.indexWhere((fh) => fh.id == ref.id);
        if (index != -1) {
          final old = freehands[index];
          freehands[index] = old.copyWith(
            points: old.points.map((p) => p + Offset(20, 20)).toList(),
          );
        }
    }
  }

  GrafkomLine _copyLineWithTransformedEndpoints(
    GrafkomLine line,
    Offset Function(Offset offset) transform,
  ) {
    final start = transform(line.start);
    final end = transform(line.end);

    return line.copyWith(
      start: start,
      end: end,
      rasterPoints: LineAlgorithms.generateLinePoints(
        line.algorithm,
        start,
        end,
      ),
    );
  }
}
