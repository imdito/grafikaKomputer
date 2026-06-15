import 'package:flutter/material.dart';

/// Pure static math for generating circle coordinates using Midpoint Algorithm
class CircleAlgorithms {
  static List<Offset> generateMidpointCircle(Offset center, double radius) {
    final result = <Offset>[];
    int x = radius.round();
    int y = 0;
    int err = 0;

    while (x >= y) {
      result.add(Offset(center.dx + x, center.dy + y));
      result.add(Offset(center.dx + y, center.dy + x));
      result.add(Offset(center.dx - y, center.dy + x));
      result.add(Offset(center.dx - x, center.dy + y));
      result.add(Offset(center.dx - x, center.dy - y));
      result.add(Offset(center.dx - y, center.dy - x));
      result.add(Offset(center.dx + y, center.dy - x));
      result.add(Offset(center.dx + x, center.dy - y));

      if (err <= 0) {
        y += 1;
        err += 2 * y + 1;
      }
      if (err > 0) {
        x -= 1;
        err -= 2 * x + 1;
      }
    }
    return result;
  }
}
