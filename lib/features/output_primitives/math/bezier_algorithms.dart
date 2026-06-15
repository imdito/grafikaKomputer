import 'package:flutter/material.dart';

/// Kelas utilitas untuk algoritma matematika Kurva Bezier.
class BezierAlgorithms {
  /// Menggenerasi titik-titik koordinat Kurva Bezier Kuadratik (3 titik kontrol).
  /// Rumus: B(t) = (1-t)^2 * P0 + 2(1-t)t * P1 + t^2 * P2, t di [0, 1]
  static List<Offset> generateBezierPoints(Offset p0, Offset p1, Offset p2) {
    final List<Offset> points = [];

    // Tentukan jumlah interpolasi sampel (steps) dinamis berdasarkan jarak antar titik
    final double totalDistance = (p1 - p0).distance + (p2 - p1).distance;
    final int steps = totalDistance.clamp(20, 1000).toInt();

    for (int i = 0; i <= steps; i++) {
      final double t = i / steps;
      final double mt = 1.0 - t;

      final double x = mt * mt * p0.dx + 2.0 * mt * t * p1.dx + t * t * p2.dx;
      final double y = mt * mt * p0.dy + 2.0 * mt * t * p1.dy + t * t * p2.dy;

      points.add(Offset(x.roundToDouble(), y.roundToDouble()));
    }

    // Menghilangkan duplikat titik berurutan untuk efisiensi rendering
    final List<Offset> optimized = [];
    for (final pt in points) {
      if (optimized.isEmpty || optimized.last != pt) {
        optimized.add(pt);
      }
    }

    return optimized;
  }
}
