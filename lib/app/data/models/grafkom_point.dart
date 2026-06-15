import 'package:flutter/material.dart';

/// Kelas model untuk objek Titik (Point) pada canvas.
class GrafkomPoint {
  const GrafkomPoint({
    required this.id,
    required this.position,
    required this.radius,
    required this.color,
  });

  /// ID unik titik
  final int id;

  /// Posisi titik di canvas
  final Offset position;

  /// Ukuran/radius titik
  final double radius;

  /// Warna titik
  final Color color;

  /// Membuat salinan dari objek ini dengan beberapa nilai yang dapat diubah
  GrafkomPoint copyWith({Offset? position, double? radius, Color? color}) {
    return GrafkomPoint(
      id: id,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      color: color ?? this.color,
    );
  }
}
