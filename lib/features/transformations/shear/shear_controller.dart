import 'package:flutter/material.dart' hide MatrixUtils;
import 'package:get/get.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';
import '../../../../../app/data/models/canvas_models.dart';
import '../../output_primitives/math/line_algorithms.dart';
import '../../output_primitives/math/bezier_algorithms.dart';
import '../math/matrix_utils.dart';

class ShearController extends GetxController {
  final shearXController = TextEditingController(text: '0.2');
  final shearYController = TextEditingController(text: '0.0');

  @override
  void onClose() {
    shearXController.dispose();
    shearYController.dispose();
    super.onClose();
  }

  void applyShear() {
    final shx = double.tryParse(shearXController.text);
    final shy = double.tryParse(shearYController.text);

    if (shx == null || shy == null) {
      Get.snackbar('Input tidak valid', 'Masukkan nilai shear X dan Y berupa angka.');
      return;
    }

    final center = Get.find<HomeController>().selectedObjectCenter;
    if (center == null) return;

    _transformSelected(
      point: (point) => point,
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => MatrixUtils.shearAround(offset, center, shx, shy),
      ),
      shape: (shape) => shape.copyWith(shearX: shape.shearX + shx, shearY: shape.shearY + shy),
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => MatrixUtils.shearAround(offset, center, shx, shy),
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
