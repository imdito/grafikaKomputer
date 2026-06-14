import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/models/canvas_models.dart';
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

  void changeShapeType(ShapeType type) {
    selectedShapeType.value = type;
  }

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
  void toggleFilledShape(bool value) {
    isFilledShape.value = value;
  }

  /// Memilih suatu objek di canvas berdasarkan referensi (ID dan tipe)
  void selectObject(CanvasObjectRef? ref) {
    selectedObject.value = ref;
  }

  /// Memperbarui ketebalan (stroke width) khusus untuk objek yang sedang dipilih
  void updateSelectedThickness(double thickness) {
    final ref = selectedObject.value;
    if (ref == null) return;
    switch (ref.type) {
      case CanvasObjectType.point:
        final index = points.indexWhere((p) => p.id == ref.id);
        if (index != -1) points[index] = points[index].copyWith(radius: thickness);
      case CanvasObjectType.line:
        final index = lines.indexWhere((l) => l.id == ref.id);
        if (index != -1) lines[index] = lines[index].copyWith(strokeWidth: thickness);
      case CanvasObjectType.shape:
        final index = shapes.indexWhere((s) => s.id == ref.id);
        if (index != -1) shapes[index] = shapes[index].copyWith(strokeWidth: thickness);
      case CanvasObjectType.freehand:
        final index = freehands.indexWhere((fh) => fh.id == ref.id);
        if (index != -1) freehands[index] = freehands[index].copyWith(strokeWidth: thickness);
      case CanvasObjectType.fill:
        break;
    }
  }

  /// Memperbarui gaya garis (stroke style) khusus untuk objek yang sedang dipilih
  void updateSelectedStrokeStyle(StrokeStyle style) {
    final ref = selectedObject.value;
    if (ref == null) return;
    switch (ref.type) {
      case CanvasObjectType.line:
        final index = lines.indexWhere((l) => l.id == ref.id);
        if (index != -1) lines[index] = lines[index].copyWith(strokeStyle: style);
      case CanvasObjectType.shape:
        final index = shapes.indexWhere((s) => s.id == ref.id);
        if (index != -1) shapes[index] = shapes[index].copyWith(strokeStyle: style);
      case CanvasObjectType.freehand:
        final index = freehands.indexWhere((fh) => fh.id == ref.id);
        if (index != -1) freehands[index] = freehands[index].copyWith(strokeStyle: style);
      default:
        break;
    }
  }

  /// Menghapus objek yang saat ini sedang dipilih dari canvas
  void deleteSelectedObject() {
    final ref = selectedObject.value;
    if (ref == null) {
      showInvalidInput('Pilih objek terlebih dahulu.');
      return;
    }

    switch (ref.type) {
      case CanvasObjectType.point:
        points.removeWhere((point) => point.id == ref.id);
      case CanvasObjectType.line:
        lines.removeWhere((line) => line.id == ref.id);
      case CanvasObjectType.shape:
        shapes.removeWhere((shape) => shape.id == ref.id);
      case CanvasObjectType.fill:
        fills.removeWhere((fill) => fill.id == ref.id);
      case CanvasObjectType.freehand:
        freehands.removeWhere((fh) => fh.id == ref.id);
    }

    objectHistory.removeWhere((historyRef) => historyRef == ref);
    selectedObject.value = null;
  }

  /// Membatalkan (undo) pembuatan objek terakhir di canvas
  void undoLast() {
    pendingLineStart.value = null;

    while (objectHistory.isNotEmpty) {
      final lastObject = objectHistory.removeLast();

      switch (lastObject.type) {
        case CanvasObjectType.point:
          final index = points.indexWhere((point) => point.id == lastObject.id);
          if (index != -1) {
            points.removeAt(index);
            clearSelectionIfMatches(lastObject);
            return;
          }
        case CanvasObjectType.line:
          final index = lines.indexWhere((line) => line.id == lastObject.id);
          if (index != -1) {
            lines.removeAt(index);
            clearSelectionIfMatches(lastObject);
            return;
          }
        case CanvasObjectType.shape:
          final index = shapes.indexWhere((shape) => shape.id == lastObject.id);
          if (index != -1) {
            shapes.removeAt(index);
            clearSelectionIfMatches(lastObject);
            return;
          }
        case CanvasObjectType.fill:
          final index = fills.indexWhere((fill) => fill.id == lastObject.id);
          if (index != -1) {
            fills.removeAt(index);
            clearSelectionIfMatches(lastObject);
            return;
          }
        case CanvasObjectType.freehand:
          final index = freehands.indexWhere((fh) => fh.id == lastObject.id);
          if (index != -1) {
            freehands.removeAt(index);
            clearSelectionIfMatches(lastObject);
            return;
          }
      }
    }
  }

  /// Menghapus semua objek yang ada di canvas
  void clearCanvas() {
    points.clear();
    lines.clear();
    shapes.clear();
    fills.clear();
    freehands.clear();
    objectHistory.clear();
    selectedObject.value = null;
    pendingLineStart.value = null;
    pendingFreehandPoints.clear();
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
