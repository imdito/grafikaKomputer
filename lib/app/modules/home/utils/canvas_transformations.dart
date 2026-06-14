import 'dart:math' as math;
import 'package:flutter/material.dart';

class CanvasTransformations {
  static Offset scaleAround(Offset point, Offset center, double sx, double sy) {
    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(center.dx, center.dy, 0))
      ..multiply(Matrix4.diagonal3Values(sx, sy, 1))
      ..multiply(Matrix4.translationValues(-center.dx, -center.dy, 0));
    return MatrixUtils.transformPoint(matrix, point);
  }

  static Offset rotateAround(Offset point, Offset center, double radians) {
    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(center.dx, center.dy, 0))
      ..multiply(Matrix4.rotationZ(radians))
      ..multiply(Matrix4.translationValues(-center.dx, -center.dy, 0));
    return MatrixUtils.transformPoint(matrix, point);
  }

  static Offset shearAround(
    Offset point,
    Offset center,
    double shearX,
    double shearY,
  ) {
    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(center.dx, center.dy, 0))
      ..multiply(Matrix4(
        1, shearY, 0, 0,
        shearX, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ))
      ..multiply(Matrix4.translationValues(-center.dx, -center.dy, 0));
    return MatrixUtils.transformPoint(matrix, point);
  }

  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
