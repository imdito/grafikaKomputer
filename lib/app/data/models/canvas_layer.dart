import 'package:get/get.dart';
import 'canvas_models.dart';

class CanvasLayer {
  CanvasLayer({
    required this.id,
    required this.name,
    this.isVisible = true,
    this.isLocked = false,
  });

  final int id;
  String name;
  bool isVisible;
  bool isLocked;

  // The isolated lists of objects for this layer
  final points = <GrafkomPoint>[].obs;
  final lines = <GrafkomLine>[].obs;
  final shapes = <GrafkomShape>[].obs;
  final freehands = <GrafkomFreehand>[].obs;
  final fills = <GrafkomFillRegion>[].obs;
  final curves = <GrafkomCurve>[].obs;
}
