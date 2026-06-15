import 'package:flutter/material.dart' hide MatrixUtils;
import 'package:get/get.dart';
import '../math/matrix_utils.dart';
import '../../output_primitives/math/line_algorithms.dart';
import '../../output_primitives/math/bezier_algorithms.dart';
import '../../../app/data/models/canvas_models.dart';
import '../../../app/modules/home/controllers/home_controller.dart';

class RotateController extends GetxController {
  final degreeController = TextEditingController(text: '45');
  TextEditingController get rotationInputController => degreeController;

  @override
  void onClose() {
    degreeController.dispose();
    super.onClose();
  }

  void applyRotation() {
    final deg = double.tryParse(degreeController.text);
    if (deg == null) {
      Get.snackbar('Input tidak valid', 'Masukkan nilai derajat berupa angka.');
      return;
    }

    final radians = deg * 3.141592653589793 / 180;
    final center = Get.find<HomeController>().selectedObjectCenter;
    if (center == null) {
      Get.snackbar('Input tidak valid', 'Pusat objek tidak ditemukan.');
      return;
    }

    _transformSelected(
      point: (point) => point.copyWith(position: MatrixUtils.rotateAround(point.position, center, radians)),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => MatrixUtils.rotateAround(offset, center, radians),
      ),
      shape: (shape) => shape.copyWith(rotationRadians: shape.rotationRadians + radians),
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => MatrixUtils.rotateAround(offset, center, radians),
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
