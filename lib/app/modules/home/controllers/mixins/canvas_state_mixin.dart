import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/canvas_models.dart';
import '../../../../data/models/canvas_layer.dart';

/// Mixin dasar yang menyimpan seluruh status (state) dan variabel reaktif untuk Canvas.
mixin CanvasStateMixin on GetxController {
  /// Daftar layer yang ada pada canvas
  final layers = <CanvasLayer>[CanvasLayer(id: 1, name: 'Background')].obs;

  /// Index layer yang sedang aktif untuk diedit
  final activeLayerIndex = 0.obs;

  /// Helper untuk mendapatkan layer yang sedang aktif
  CanvasLayer get activeLayer => layers[activeLayerIndex.value];

  /// Status visibilitas navbar melayang
  final isNavbarVisible = true.obs;

  /// Status visibilitas panel layer melayang
  final isLayerPanelVisible = false.obs;

  /// Riwayat ID objek berdasar urutan penambahannya ke canvas
  final objectHistory = <CanvasObjectRef>[];

  /// Alat gambar (tool) yang sedang aktif dipilih pengguna
  final selectedTool = DrawingTool.primitives.obs;

  /// Algoritma garis yang akan digunakan saat membuat garis baru
  final selectedAlgorithm = LineAlgorithm.dda.obs;

  /// Warna primer yang saat ini dipilih
  final selectedColor = Rx<Color>(Colors.indigo);

  /// Titik mula saat menggambar garis dengan mode sentuh
  final pendingLineStart = Rx<Offset?>(null);

  /// Titik P0 (Start) untuk pembuatan Kurva Bezier Kuadratik
  final pendingCurveStart = Rx<Offset?>(null);

  /// Titik P2 (End) untuk pembuatan Kurva Bezier Kuadratik
  final pendingCurveEnd = Rx<Offset?>(null);

  /// Referensi objek yang saat ini sedang disorot/dipilih
  final selectedObject = Rxn<CanvasObjectRef>();

  /// Posisi mouse saat ini ketika melayang (hover) di atas canvas
  final hoverPosition = Rxn<Offset>();

  /// Memperbarui posisi kursor melayang di atas canvas
  void updateHoverPosition(Offset position) {
    hoverPosition.value = position;
  }

  /// Menghapus posisi kursor saat kursor keluar dari batas canvas
  void clearHoverPosition() {
    hoverPosition.value = null;
  }

  // Controller input teks untuk posisi dan dimensi
  final xController = TextEditingController();
  final yController = TextEditingController();
  final radiusController = TextEditingController(text: '6');

  final x1Controller = TextEditingController();
  final y1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final y2Controller = TextEditingController();

  /// Ketebalan standar objek garis/titik/coretan bebas yang sedang aktif
  final strokeWidth = 4.0.obs;

  /// Opasitas garis/coretan bebas
  final lineOpacity = 1.0.obs;

  /// Gaya garis (solid, dashed, dotted) untuk objek aktif
  final lineStyle = StrokeStyle.solid.obs;

  /// Ketebalan garis luar untuk bentuk 2D
  final shapeStrokeWidth = 3.0.obs;

  /// Opasitas area bentuk 2D atau isi fill
  final shapeOpacity = 1.0.obs;

  int _nextObjectId = 1;

  /// Menghasilkan ID unik untuk objek baru yang dibuat di canvas
  int nextId() => _nextObjectId++;

  /// Mereset seluruh progres canvas dan struktur layer kembali ke awal
  void clearAllProgress() {
    layers.value = [CanvasLayer(id: 1, name: 'Background')];
    activeLayerIndex.value = 0;
    objectHistory.clear();
    selectedObject.value = null;
    pendingLineStart.value = null;
    _nextObjectId = 1;
  }

  /// Kunci (Key) global yang mengikat komponen canvas untuk keperluan Export gambar
  final GlobalKey canvasKey = GlobalKey();

  /// Mendapatkan titik pusat/koordinat tengah dari objek yang sedang dipilih
  Offset? get selectedObjectCenter {
    final ref = selectedObject.value;
    if (ref == null) return null;

    for (final layer in layers) {
      switch (ref.type) {
        case CanvasObjectType.point:
          final index = layer.points.indexWhere((point) => point.id == ref.id);
          if (index != -1) return layer.points[index].position;
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((line) => line.id == ref.id);
          if (index != -1) return layer.lines[index].center;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((shape) => shape.id == ref.id);
          if (index != -1) return layer.shapes[index].center;
        case CanvasObjectType.fill:
          final index = layer.fills.indexWhere((fill) => fill.id == ref.id);
          if (index != -1) {
            return layer.fills[index].offsets.isNotEmpty
                ? layer.fills[index].offsets.first
                : null;
          }
        case CanvasObjectType.freehand:
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) return layer.freehands[index].center;
        case CanvasObjectType.curve:
          final index = layer.curves.indexWhere((c) => c.id == ref.id);
          if (index != -1) return layer.curves[index].center;
      }
    }
    return null;
  }

  /// Menghasilkan label nama objek untuk ditampilkan di UI panel Editor Objek
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
    final options = <CanvasObjectOption>[];
    for (int l = 0; l < layers.length; l++) {
      final layer = layers[l];
      final prefix = 'L${l + 1} - ';
      for (var i = 0; i < layer.points.length; i++) {
        options.add(
          CanvasObjectOption(
            ref: CanvasObjectRef(
              type: CanvasObjectType.point,
              id: layer.points[i].id,
            ),
            label: '${prefix}Titik #${i + 1}  (id: ${layer.points[i].id})',
          ),
        );
      }
      for (var i = 0; i < layer.lines.length; i++) {
        options.add(
          CanvasObjectOption(
            ref: CanvasObjectRef(
              type: CanvasObjectType.line,
              id: layer.lines[i].id,
            ),
            label: '${prefix}Garis #${i + 1}  (id: ${layer.lines[i].id})',
          ),
        );
      }
      for (var i = 0; i < layer.shapes.length; i++) {
        options.add(
          CanvasObjectOption(
            ref: CanvasObjectRef(
              type: CanvasObjectType.shape,
              id: layer.shapes[i].id,
            ),
            label:
                '${prefix}${shapeTypeName(layer.shapes[i].type)} #${i + 1}  (id: ${layer.shapes[i].id})',
          ),
        );
      }
      for (var i = 0; i < layer.fills.length; i++) {
        options.add(
          CanvasObjectOption(
            ref: CanvasObjectRef(
              type: CanvasObjectType.fill,
              id: layer.fills[i].id,
            ),
            label: '${prefix}Fill Warna #${i + 1}  (id: ${layer.fills[i].id})',
          ),
        );
      }
      for (var i = 0; i < layer.freehands.length; i++) {
        options.add(
          CanvasObjectOption(
            ref: CanvasObjectRef(
              type: CanvasObjectType.freehand,
              id: layer.freehands[i].id,
            ),
            label: '${prefix}Coretan #${i + 1}  (id: ${layer.freehands[i].id})',
          ),
        );
      }
    }
    return options;
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

  @override
  void onClose() {
    xController.dispose();
    yController.dispose();
    radiusController.dispose();
    x1Controller.dispose();
    y1Controller.dispose();
    x2Controller.dispose();
    y2Controller.dispose();

    super.onClose();
  }
}
