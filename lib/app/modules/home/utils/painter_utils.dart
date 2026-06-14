import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../data/models/canvas_models.dart';

/// Ekstensi pada Canvas untuk menyederhanakan kode menggambar elemen-elemen grafika komputer.
extension GrafkomCanvasExtension on Canvas {
  /// Menggambar latar belakang putih dengan batas tepi (border)
  void drawCanvasBackground(Size size) {
    final backgroundPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Offset.zero & size;
    drawRect(rect, backgroundPaint);
    drawRect(rect, borderPaint);
  }

  /// Menggambar grid / kotak-kotak latar belakang
  void drawGrid(Size size, {double spacing = 25.0}) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += spacing) {
      drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  /// Menggambar sumbu X dan Y di tengah canvas
  void drawAxis(Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5;

    drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  /// Menerapkan matriks transformasi (Translasi, Rotasi, Skala, Shear, Flip) pada canvas 
  /// sebelum menggambar suatu bentuk, lalu mengembalikan canvas ke state semula setelah selesai.
  void withShapeTransform(GrafkomShape shape, VoidCallback draw) {
    save();
    translate(shape.center.dx, shape.center.dy);
    rotate(shape.rotationRadians);
    transform(
      Float64List.fromList([
        shape.flipX, shape.shearY, 0, 0,
        shape.shearX, shape.flipY, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]),
    );
    draw();
    restore();
  }
}

/// Kelas helper untuk utilitas penggambaran seperti path shapes dan dash patterns
class PainterUtils {
  PainterUtils._();

  /// Membuat path/garis berdasar gaya (dashed/dotted)
  static Path applyDashPattern(Path source, StrokeStyle style, double strokeWidth) {
    if (style == StrokeStyle.solid) return source;
    if (style == StrokeStyle.dashed) {
      final dashLen = (strokeWidth * 3).clamp(8.0, 28.0);
      final gapLen = (strokeWidth * 2).clamp(5.0, 18.0);
      return dashPath(source, dashArray: CircularIntervalList<double>([dashLen, gapLen]));
    }
    if (style == StrokeStyle.dotted) {
      final gapLen = (strokeWidth * 2.5).clamp(6.0, 20.0);
      return dashPath(source, dashArray: CircularIntervalList<double>([1.0, gapLen]));
    }
    return source;
  }

  /// Mengecek apakah sebuah piksel pada index tertentu harus digambar
  /// berdasarkan gaya garis (digunakan saat merasterisasi piksel manual)
  static bool isStrokeVisible(int index, double strokeWidth, StrokeStyle style) {
    if (style == StrokeStyle.solid) return true;
    if (style == StrokeStyle.dashed) {
      final dashLength = (strokeWidth * 3).clamp(8, 28).round();
      final gapLength = (strokeWidth * 2).clamp(5, 18).round();
      final patternLength = dashLength + gapLength;
      return index % patternLength < dashLength;
    }
    if (style == StrokeStyle.dotted) {
      final gapLength = (strokeWidth * 2.5).clamp(6, 20).round();
      return index % (1 + gapLength) == 0;
    }
    return true;
  }

  /// Mendapatkan batas kotak lokal dari sebuah shape
  static Rect localShapeRect(GrafkomShape shape) {
    return Rect.fromCenter(
      center: Offset.zero,
      width: shape.width,
      height: shape.height,
    );
  }

  /// Membuat path untuk bentuk Segitiga
  static Path trianglePath(GrafkomShape shape) {
    final halfWidth = shape.width / 2;
    final halfHeight = shape.height / 2;
    return Path()
      ..moveTo(0, -halfHeight)
      ..lineTo(-halfWidth, halfHeight)
      ..lineTo(halfWidth, halfHeight)
      ..close();
  }

  /// Membuat path untuk bentuk Belah Ketupat (Diamond)
  static Path diamondPath(GrafkomShape shape) {
    final halfWidth = shape.width / 2;
    final halfHeight = shape.height / 2;
    return Path()
      ..moveTo(0, -halfHeight)
      ..lineTo(halfWidth, 0)
      ..lineTo(0, halfHeight)
      ..lineTo(-halfWidth, 0)
      ..close();
  }

  /// Membuat path untuk bentuk Trapesium
  static Path trapezoidPath(GrafkomShape shape) {
    final halfTop = shape.width * 0.3;
    final halfBottom = shape.width / 2;
    final halfHeight = shape.height / 2;
    return Path()
      ..moveTo(-halfTop, -halfHeight)
      ..lineTo(halfTop, -halfHeight)
      ..lineTo(halfBottom, halfHeight)
      ..lineTo(-halfBottom, halfHeight)
      ..close();
  }
}
