import 'package:flutter/material.dart';
import 'enums.dart';

/// Kelas model untuk coretan bebas (Freehand) pada canvas
class GrafkomFreehand {
  const GrafkomFreehand({
    required this.id,
    required this.points,
    required this.strokeWidth,
    this.strokeStyle = StrokeStyle.solid,
    required this.opacity,
    required this.color,
  });

  /// ID unik objek coretan bebas
  final int id;

  /// Titik-titik yang membentuk goresan
  final List<Offset> points;

  /// Ketebalan garis
  final double strokeWidth;

  /// Gaya garis (solid, dashed, dll)
  final StrokeStyle strokeStyle;

  /// Transparansi warna (0.0 - 1.0)
  final double opacity;

  /// Warna garis
  final Color color;

  /// Mengambil perkiraan titik tengah dari kumpulan goresan ini
  Offset get center {
    if (points.isEmpty) return Offset.zero;
    double sumX = 0;
    double sumY = 0;
    for (final p in points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }

  /// Membuat salinan objek ini dengan beberapa nilai yang dapat diubah
  GrafkomFreehand copyWith({
    List<Offset>? points,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    double? opacity,
    Color? color,
  }) {
    return GrafkomFreehand(
      id: id,
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
    );
  }
}
