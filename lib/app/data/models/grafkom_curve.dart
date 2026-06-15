import 'package:flutter/material.dart';

/// Kelas model untuk objek Kurva Bezier Kuadratik (Curve) pada canvas.
class GrafkomCurve {
  const GrafkomCurve({
    required this.id,
    required this.start,
    required this.control,
    required this.end,
    required this.strokeWidth,
    required this.opacity,
    required this.color,
    required this.rasterPoints,
  });

  /// ID unik kurva
  final int id;

  /// Titik awal kurva (P0)
  final Offset start;

  /// Titik kontrol kurva (P1)
  final Offset control;

  /// Titik akhir kurva (P2)
  final Offset end;

  /// Ketebalan garis kurva
  final double strokeWidth;

  /// Transparansi warna (0.0 - 1.0)
  final double opacity;

  /// Warna kurva
  final Color color;

  /// Titik-titik piksel hasil rasterisasi kurva
  final List<Offset> rasterPoints;

  /// Mengambil titik kontrol sebagai representasi pusat kurva
  Offset get center => control;

  /// Membuat salinan objek ini dengan beberapa nilai yang dapat diubah
  GrafkomCurve copyWith({
    Offset? start,
    Offset? control,
    Offset? end,
    double? strokeWidth,
    double? opacity,
    Color? color,
    List<Offset>? rasterPoints,
  }) {
    return GrafkomCurve(
      id: id,
      start: start ?? this.start,
      control: control ?? this.control,
      end: end ?? this.end,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      rasterPoints: rasterPoints ?? this.rasterPoints,
    );
  }
}
