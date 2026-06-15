import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/modules/home/controllers/home_controller.dart';
import '../../../../../app/data/models/canvas_models.dart';
import '../../output_primitives/math/line_algorithms.dart';
import '../../output_primitives/math/bezier_algorithms.dart';

class TranslateController extends GetxController {
  final translateXController = TextEditingController(text: '20');
  final translateYController = TextEditingController(text: '20');

  @override
  void onClose() {
    translateXController.dispose();
    translateYController.dispose();
    super.onClose();
  }

  void applyTranslation() {
    final dx = double.tryParse(translateXController.text);
    final dy = double.tryParse(translateYController.text);

    if (dx == null || dy == null) {
      Get.snackbar('Input tidak valid', 'Masukkan nilai translasi X dan Y berupa angka.');
      return;
    }

    _transformSelected(
      point: (point) => point.copyWith(position: point.position + Offset(dx, dy)),
      line: (line) => _copyLineWithTransformedEndpoints(
        line,
        (offset) => offset + Offset(dx, dy),
      ),
      shape: (shape) => shape.copyWith(center: shape.center + Offset(dx, dy)),
      curve: (curve) => _copyCurveWithTransformedEndpoints(
        curve,
        (offset) => offset + Offset(dx, dy),
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
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) {
            final old = layer.freehands[index];
            layer.freehands[index] = old.copyWith(
              points: old.points.map((p) => p + Offset(20, 20)).toList(),
            );
          }
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
