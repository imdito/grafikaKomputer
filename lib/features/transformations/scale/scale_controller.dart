import 'package:flutter/material.dart' hide MatrixUtils;
import 'package:get/get.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';
import '../../../../../app/data/models/canvas_models.dart';
import '../../output_primitives/math/line_algorithms.dart';
import '../../output_primitives/math/bezier_algorithms.dart';
import '../math/matrix_utils.dart';

class ScaleController extends GetxController {
  final scaleXController = TextEditingController(text: '1.2');
  final scaleYController = TextEditingController(text: '1.2');

  @override
  void onClose() {
    scaleXController.dispose();
    scaleYController.dispose();
    super.onClose();
  }

  void applyScale() {
    final sx = double.tryParse(scaleXController.text);
    final sy = double.tryParse(scaleYController.text);

    if (sx == null || sy == null || sx == 0 || sy == 0) {
      Get.snackbar('Input tidak valid', 'Masukkan skala X dan Y berupa angka selain 0.');
      return;
    }

    _transformSelected(
      point: (point) => point.copyWith(
        radius: (point.radius * ((sx.abs() + sy.abs()) / 2)).clamp(1, 120).toDouble(),
      ),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => MatrixUtils.scaleAround(offset, line.center, sx, sy),
      ),
      shape: (shape) => shape.copyWith(
        width: (shape.width * sx.abs()).clamp(2, 2000).toDouble(),
        height: (shape.height * sy.abs()).clamp(2, 2000).toDouble(),
        flipX: sx.isNegative ? -shape.flipX : shape.flipX,
        flipY: sy.isNegative ? -shape.flipY : shape.flipY,
      ),
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => MatrixUtils.scaleAround(offset, curve.center, sx, sy),
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
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => Offset(2 * curve.center.dx - offset.dx, offset.dy),
      ),
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
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => Offset(offset.dx, 2 * curve.center.dy - offset.dy),
      ),
    );
  }

  void mirrorGlobalX() {
    const globalY = 900.0;
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
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => Offset(offset.dx, 2 * globalY - offset.dy),
      ),
    );
  }

  void mirrorGlobalY() {
    const globalX = 1200.0;
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
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => Offset(2 * globalX - offset.dx, offset.dy),
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
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => Offset(2 * globalX - offset.dx, 2 * globalY - offset.dy),
      ),
    );
  }

  void _transformSelected({
    required GrafkomPoint Function(GrafkomPoint point) point,
    required GrafkomLine Function(GrafkomLine line) line,
    required GrafkomShape Function(GrafkomShape shape) shape,
    required GrafkomCurve Function(GrafkomCurve curve) curve,
  }) {
    final homeController = Get.find<HomeController>();
    final ref = homeController.selectedObject.value;
    if (ref == null) {
      Get.snackbar('Input tidak valid', 'Pilih objek terlebih dahulu dari Object Selection.');
      return;
    }

    for (final layer in homeController.layers) {
      switch (ref.type) {
        case CanvasObjectType.point:
          final index = layer.points.indexWhere((item) => item.id == ref.id);
          if (index != -1) layer.points[index] = point(layer.points[index]);
          break;
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((item) => item.id == ref.id);
          if (index != -1) layer.lines[index] = line(layer.lines[index]);
          break;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((item) => item.id == ref.id);
          if (index != -1) layer.shapes[index] = shape(layer.shapes[index]);
          break;
        case CanvasObjectType.curve:
          final index = layer.curves.indexWhere((item) => item.id == ref.id);
          if (index != -1) layer.curves[index] = curve(layer.curves[index]);
          break;
        case CanvasObjectType.fill:
          break;
        case CanvasObjectType.freehand:
          break;
      }
    }
    homeController.layers.refresh();
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

  GrafkomCurve _copyCurveWithTransformedEndpoints(
    GrafkomCurve curve,
    Offset Function(Offset offset) transform,
  ) {
    final start = transform(curve.start);
    final control = transform(curve.control);
    final end = transform(curve.end);

    return curve.copyWith(
      start: start,
      control: control,
      end: end,
      rasterPoints: BezierAlgorithms.generateBezierPoints(start, control, end),
    );
  }
}
