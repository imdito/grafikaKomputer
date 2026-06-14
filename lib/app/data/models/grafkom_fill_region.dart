import 'package:flutter/material.dart';

/// Kelas model untuk area yang diisi warna (Flood Fill) pada canvas.
class GrafkomFillRegion {
  const GrafkomFillRegion({
    required this.id,
    required this.offsets,
    required this.color,
    required this.opacity,
  });

  /// ID unik untuk objek fill
  final int id;
  
  /// Titik-titik piksel yang diwarnai oleh flood fill
  final List<Offset> offsets;
  
  /// Warna area
  final Color color;
  
  /// Transparansi warna area (0.0 - 1.0)
  final double opacity;
}
