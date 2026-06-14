import 'package:flutter/material.dart';
import 'enums.dart';

/// Kelas model untuk objek Garis (Line) pada canvas.
class GrafkomLine {
  const GrafkomLine({
    required this.id,
    required this.start,
    required this.end,
    required this.algorithm,
    required this.strokeWidth,
    this.strokeStyle = StrokeStyle.solid,
    required this.opacity,
    required this.color,
    required this.rasterPoints,
  });

  /// ID unik garis
  final int id;
  
  /// Titik awal garis
  final Offset start;
  
  /// Titik akhir garis
  final Offset end;
  
  /// Algoritma pembuatan garis (DDA atau Bresenham)
  final LineAlgorithm algorithm;
  
  /// Ketebalan garis
  final double strokeWidth;
  
  /// Gaya garis (solid, putus-putus, titik)
  final StrokeStyle strokeStyle;
  
  /// Transparansi warna (0.0 - 1.0)
  final double opacity;
  
  /// Warna garis
  final Color color;
  
  /// Titik-titik piksel aktual hasil dari algoritma rasterisasi
  final List<Offset> rasterPoints;

  /// Mengambil titik tengah dari garis ini
  Offset get center => Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

  /// Membuat salinan objek ini dengan beberapa nilai yang dapat diubah
  GrafkomLine copyWith({
    Offset? start,
    Offset? end,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    double? opacity,
    Color? color,
    List<Offset>? rasterPoints,
  }) {
    return GrafkomLine(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
      algorithm: algorithm,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      rasterPoints: rasterPoints ?? this.rasterPoints,
    );
  }
}
