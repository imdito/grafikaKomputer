import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/canvas_models.dart';
import '../../../../../features/output_primitives/pen_tool/pen_controller.dart';
import 'canvas_state_mixin.dart';

/// Mixin yang mengatur pengubahan properti (alat, gaya, warna) serta
/// manajemen objek (pilih, hapus, undo, export).
mixin CanvasPropertiesMixin on CanvasStateMixin {
  /// Mengganti alat (tool) yang sedang aktif dan me-reset status operasi yang menggantung.
  void changeTool(DrawingTool tool) {
    selectedTool.value = tool;
    pendingLineStart.value = null;
  }

  void changeAlgorithm(LineAlgorithm algorithm) {
    selectedAlgorithm.value = algorithm;
  }

  // shapeType properties moved to ShapeController

  void changeColor(Color color) {
    selectedColor.value = color;
  }

  /// Mengganti ketebalan garis/titik secara global
  void changeStrokeWidth(double value) {
    strokeWidth.value = value;
  }

  /// Mengganti opasitas (transparansi) garis secara global
  void changeLineOpacity(double value) {
    lineOpacity.value = value;
  }

  /// Mengganti gaya garis (solid, putus-putus) secara global
  void changeLineStyle(StrokeStyle style) {
    lineStyle.value = style;
  }

  /// Mengganti ketebalan garis pinggir bentuk 2D secara global
  void changeShapeStrokeWidth(double value) {
    shapeStrokeWidth.value = value;
  }

  /// Mengganti opasitas (transparansi) bentuk 2D secara global
  void changeShapeOpacity(double value) {
    shapeOpacity.value = value;
  }

  /// Mengganti mode isi/tidak pada bentuk 2D secara global
  // toggleFilledShape logic moved to ShapeController

  /// Memilih suatu objek di canvas berdasarkan referensi (ID dan tipe)
  void selectObject(CanvasObjectRef? ref) {
    selectedObject.value = ref;
  }

  /// Memperbarui ketebalan (stroke width) khusus untuk objek yang sedang dipilih
  void updateSelectedThickness(double thickness) {
    final ref = selectedObject.value;
    if (ref == null) return;
    for (final layer in layers) {
      switch (ref.type) {
        case CanvasObjectType.point:
          final index = layer.points.indexWhere((p) => p.id == ref.id);
          if (index != -1) layer.points[index] = layer.points[index].copyWith(radius: thickness);
          break;
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((l) => l.id == ref.id);
          if (index != -1) layer.lines[index] = layer.lines[index].copyWith(strokeWidth: thickness);
          break;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((s) => s.id == ref.id);
          if (index != -1) layer.shapes[index] = layer.shapes[index].copyWith(strokeWidth: thickness);
          break;
        case CanvasObjectType.freehand:
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) layer.freehands[index] = layer.freehands[index].copyWith(strokeWidth: thickness);
          break;
        case CanvasObjectType.curve:
          final index = layer.curves.indexWhere((c) => c.id == ref.id);
          if (index != -1) layer.curves[index] = layer.curves[index].copyWith(strokeWidth: thickness);
          break;
        case CanvasObjectType.fill:
          break;
      }
    }
  }

  /// Memperbarui gaya garis (stroke style) khusus untuk objek yang sedang dipilih
  void updateSelectedStrokeStyle(StrokeStyle style) {
    final ref = selectedObject.value;
    if (ref == null) return;
    for (final layer in layers) {
      switch (ref.type) {
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((l) => l.id == ref.id);
          if (index != -1) layer.lines[index] = layer.lines[index].copyWith(strokeStyle: style);
          break;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((s) => s.id == ref.id);
          if (index != -1) layer.shapes[index] = layer.shapes[index].copyWith(strokeStyle: style);
          break;
        case CanvasObjectType.freehand:
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) layer.freehands[index] = layer.freehands[index].copyWith(strokeStyle: style);
          break;
        default:
          break;
      }
    }
  }

  /// Menghapus objek yang saat ini sedang dipilih dari canvas
  void deleteSelectedObject() {
    final ref = selectedObject.value;
    if (ref == null) {
      showInvalidInput('Pilih objek terlebih dahulu.');
      return;
    }

    for (final layer in layers) {
      switch (ref.type) {
        case CanvasObjectType.point:
          layer.points.removeWhere((point) => point.id == ref.id);
          break;
        case CanvasObjectType.line:
          layer.lines.removeWhere((line) => line.id == ref.id);
          break;
        case CanvasObjectType.shape:
          layer.shapes.removeWhere((shape) => shape.id == ref.id);
          break;
        case CanvasObjectType.fill:
          layer.fills.removeWhere((fill) => fill.id == ref.id);
          break;
        case CanvasObjectType.freehand:
          layer.freehands.removeWhere((fh) => fh.id == ref.id);
          break;
        case CanvasObjectType.curve:
          layer.curves.removeWhere((curve) => curve.id == ref.id);
          break;
      }
    }

    objectHistory.removeWhere((historyRef) => historyRef == ref);
    selectedObject.value = null;
  }

  /// Membatalkan (undo) pembuatan objek terakhir di canvas
  void undoLast() {
    pendingLineStart.value = null;

    while (objectHistory.isNotEmpty) {
      final lastObject = objectHistory.removeLast();

      bool removed = false;
      for (final layer in layers) {
        switch (lastObject.type) {
          case CanvasObjectType.point:
            final index = layer.points.indexWhere((point) => point.id == lastObject.id);
            if (index != -1) { layer.points.removeAt(index); removed = true; }
            break;
          case CanvasObjectType.line:
            final index = layer.lines.indexWhere((line) => line.id == lastObject.id);
            if (index != -1) { layer.lines.removeAt(index); removed = true; }
            break;
          case CanvasObjectType.shape:
            final index = layer.shapes.indexWhere((shape) => shape.id == lastObject.id);
            if (index != -1) { layer.shapes.removeAt(index); removed = true; }
            break;
          case CanvasObjectType.fill:
            final index = layer.fills.indexWhere((fill) => fill.id == lastObject.id);
            if (index != -1) { layer.fills.removeAt(index); removed = true; }
            break;
          case CanvasObjectType.freehand:
            final index = layer.freehands.indexWhere((fh) => fh.id == lastObject.id);
            if (index != -1) { layer.freehands.removeAt(index); removed = true; }
            break;
          case CanvasObjectType.curve:
            final index = layer.curves.indexWhere((curve) => curve.id == lastObject.id);
            if (index != -1) { layer.curves.removeAt(index); removed = true; }
            break;
        }
        if (removed) {
          clearSelectionIfMatches(lastObject);
          return;
        }
      }
    }
  }

  /// Menghapus semua objek yang ada di canvas
  void clearCanvas() {
    for (final layer in layers) {
      layer.points.clear();
      layer.lines.clear();
      layer.shapes.clear();
      layer.fills.clear();
      layer.freehands.clear();
    }
    objectHistory.clear();
    selectedObject.value = null;
    pendingLineStart.value = null;
    if (Get.isRegistered<PenController>()) {
      Get.find<PenController>().pendingFreehandPoints.clear();
    }
  }

  /// Mengekspor tampilan canvas saat ini ke format gambar PNG dan membagikannya
  Future<void> exportCanvas() async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/grafkom_canvas.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        
        await Share.shareXFiles([XFile(filePath)], text: 'Hasil gambar Grafkom saya!');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengekspor gambar: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
