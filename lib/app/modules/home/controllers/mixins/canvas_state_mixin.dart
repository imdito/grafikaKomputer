import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/canvas_models.dart';

mixin CanvasStateMixin on GetxController {
  final points = <GrafkomPoint>[].obs;
  final lines = <GrafkomLine>[].obs;
  final shapes = <GrafkomShape>[].obs;
  final fills = <GrafkomFillRegion>[].obs;
  final freehands = <GrafkomFreehand>[].obs;
  final objectHistory = <CanvasObjectRef>[];

  final selectedTool = DrawingTool.point.obs;
  final selectedAlgorithm = LineAlgorithm.dda.obs;
  final selectedShapeType = ShapeType.circle.obs;
  final selectedColor = Rx<Color>(Colors.indigo);
  final pendingLineStart = Rx<Offset?>(null);
  final pendingFreehandPoints = <Offset>[].obs;
  final selectedObject = Rxn<CanvasObjectRef>();
  final hoverPosition = Rxn<Offset>();

  void updateHoverPosition(Offset position) {
    hoverPosition.value = position;
  }

  void clearHoverPosition() {
    hoverPosition.value = null;
  }

  final xController = TextEditingController();
  final yController = TextEditingController();
  final radiusController = TextEditingController(text: '6');

  final x1Controller = TextEditingController();
  final y1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final y2Controller = TextEditingController();

  final shapeXController = TextEditingController();
  final shapeYController = TextEditingController();
  final shapeWidthController = TextEditingController(text: '120');
  final shapeHeightController = TextEditingController(text: '80');

  final translateXController = TextEditingController(text: '20');
  final translateYController = TextEditingController(text: '20');
  final scaleXController = TextEditingController(text: '1.2');
  final scaleYController = TextEditingController(text: '1.2');
  final rotateController = TextEditingController(text: '15');
  final shearXController = TextEditingController(text: '0.2');
  final shearYController = TextEditingController(text: '0');

  final strokeWidth = 4.0.obs;
  final lineOpacity = 1.0.obs;
  final lineStyle = StrokeStyle.solid.obs;

  final shapeStrokeWidth = 3.0.obs;
  final shapeOpacity = 1.0.obs;
  final isFilledShape = false.obs;

  int _nextObjectId = 1;
  int nextId() => _nextObjectId++;

  final GlobalKey canvasKey = GlobalKey();

  Offset? get selectedObjectCenter {
    final ref = selectedObject.value;
    if (ref == null) return null;

    switch (ref.type) {
      case CanvasObjectType.point:
        final index = points.indexWhere((point) => point.id == ref.id);
        return index == -1 ? null : points[index].position;
      case CanvasObjectType.line:
        final index = lines.indexWhere((line) => line.id == ref.id);
        return index == -1 ? null : lines[index].center;
      case CanvasObjectType.shape:
        final index = shapes.indexWhere((shape) => shape.id == ref.id);
        return index == -1 ? null : shapes[index].center;
      case CanvasObjectType.fill:
        final index = fills.indexWhere((fill) => fill.id == ref.id);
        return index == -1
            ? null
            : (fills[index].offsets.isNotEmpty
                ? fills[index].offsets.first
                : null);
      case CanvasObjectType.freehand:
        final index = freehands.indexWhere((fh) => fh.id == ref.id);
        return index == -1 ? null : freehands[index].center;
    }
  }

  String get selectedObjectLabel {
    final ref = selectedObject.value;
    if (ref == null) return 'Tidak ada objek dipilih';

    for (final option in objectOptions) {
      if (option.ref == ref) {
        return option.label;
      }
    }

    return 'Objek tidak ditemukan';
  }

  List<CanvasObjectOption> get objectOptions {
    return [
      for (var i = 0; i < points.length; i++)
        CanvasObjectOption(
          ref: CanvasObjectRef(type: CanvasObjectType.point, id: points[i].id),
          label: 'Titik #${i + 1}  (id: ${points[i].id})',
        ),
      for (var i = 0; i < lines.length; i++)
        CanvasObjectOption(
          ref: CanvasObjectRef(type: CanvasObjectType.line, id: lines[i].id),
          label: 'Garis #${i + 1}  (id: ${lines[i].id})',
        ),
      for (var i = 0; i < shapes.length; i++)
        CanvasObjectOption(
          ref: CanvasObjectRef(type: CanvasObjectType.shape, id: shapes[i].id),
          label:
              '${shapeTypeName(shapes[i].type)} #${i + 1}  (id: ${shapes[i].id})',
        ),
      for (var i = 0; i < fills.length; i++)
        CanvasObjectOption(
          ref: CanvasObjectRef(type: CanvasObjectType.fill, id: fills[i].id),
          label: 'Fill Warna #${i + 1}  (id: ${fills[i].id})',
        ),
      for (var i = 0; i < freehands.length; i++)
        CanvasObjectOption(
          ref: CanvasObjectRef(type: CanvasObjectType.freehand, id: freehands[i].id),
          label: 'Coretan #${i + 1}  (id: ${freehands[i].id})',
        ),
    ];
  }

  String shapeTypeName(ShapeType type) {
    return switch (type) {
      ShapeType.circle => 'Lingkaran',
      ShapeType.square => 'Persegi',
      ShapeType.rectangle => 'Persegi Panjang',
      ShapeType.triangle => 'Segitiga',
      ShapeType.ellipse => 'Elips',
      ShapeType.diamond => 'Belah Ketupat',
      ShapeType.trapezoid => 'Trapesium',
    };
  }

  void registerObject(CanvasObjectType type, int id) {
    final ref = CanvasObjectRef(type: type, id: id);
    objectHistory.add(ref);
    selectedObject.value = ref;
  }

  void clearSelectionIfMatches(CanvasObjectRef ref) {
    if (selectedObject.value == ref) {
      selectedObject.value = null;
    }
  }

  void showInvalidInput(String message) {
    Get.snackbar(
      'Input tidak valid',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  double safeRadius() {
    final radius = double.tryParse(radiusController.text) ?? 6;
    return radius.clamp(2, 30).toDouble();
  }

  double safeShapeWidth() {
    final width = double.tryParse(shapeWidthController.text) ?? 120;
    return width.clamp(10, 500).toDouble();
  }

  double safeShapeHeight() {
    final height = double.tryParse(shapeHeightController.text) ?? 80;
    return height.clamp(10, 500).toDouble();
  }

  @override
  void onClose() {
    xController.dispose();
    yController.dispose();
    radiusController.dispose();
    x1Controller.dispose();
    y1Controller.dispose();
    x2Controller.dispose();
    y2Controller.dispose();
    shapeXController.dispose();
    shapeYController.dispose();
    shapeWidthController.dispose();
    shapeHeightController.dispose();
    translateXController.dispose();
    translateYController.dispose();
    scaleXController.dispose();
    scaleYController.dispose();
    rotateController.dispose();
    shearXController.dispose();
    shearYController.dispose();
    super.onClose();
  }
}
