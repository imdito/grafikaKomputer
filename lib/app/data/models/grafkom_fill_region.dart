import 'package:flutter/material.dart';

/// Kelas model untuk area yang diisi warna (Flood Fill) pada canvas.
class GrafkomFillRegion {
  GrafkomFillRegion({
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

  // Cached path for fast GPU rendering
  Path? _cachedPath;

  /// Path hasil penyatuan pixel span horizontal untuk rendering cepat di GPU
  Path get path {
    if (_cachedPath != null) return _cachedPath!;

    final path = Path();
    if (offsets.isEmpty) {
      _cachedPath = path;
      return path;
    }

    // Group offsets by Y coordinate
    final Map<double, List<double>> rowMap = {};
    for (final offset in offsets) {
      rowMap.putIfAbsent(offset.dy, () => []).add(offset.dx);
    }

    // Process each row to create contiguous horizontal rect spans
    rowMap.forEach((dy, xList) {
      if (xList.isEmpty) return;
      xList.sort();

      double startX = xList.first;
      double lastX = xList.first;

      for (int i = 1; i < xList.length; i++) {
        final currentX = xList[i];
        // Contiguous check: each pixel center is spaced by 2.0 units
        if (currentX - lastX <= 2.1) {
          lastX = currentX;
        } else {
          path.addRect(Rect.fromLTRB(startX - 1.0, dy - 1.0, lastX + 1.0, dy + 1.0));
          startX = currentX;
          lastX = currentX;
        }
      }
      path.addRect(Rect.fromLTRB(startX - 1.0, dy - 1.0, lastX + 1.0, dy + 1.0));
    });

    _cachedPath = path;
    return path;
  }
}
