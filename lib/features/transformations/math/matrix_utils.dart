import 'dart:math' as math;
import 'package:flutter/material.dart' hide MatrixUtils;
import 'package:flutter/material.dart' as flutter_math;

/// Pure static mathematical utility for matrix and rotation calculations.
/// This file maintains strict separation of concerns with zero UI or GetX dependencies.
class MatrixUtils {
  /// Converts degrees to radians.
  static double degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }

  /// Rotates a given [offset] around a [center] point by [radians]
  /// using standard 2D rotation matrix formulas.
  static Offset rotateAround(Offset offset, Offset center, double radians) {
    final cosTheta = math.cos(radians);
    final sinTheta = math.sin(radians);

    final dx = offset.dx - center.dx;
    final dy = offset.dy - center.dy;

    final rotatedX = dx * cosTheta - dy * sinTheta;
    final rotatedY = dx * sinTheta + dy * cosTheta;

    return Offset(rotatedX + center.dx, rotatedY + center.dy);
  }

  static Offset scaleAround(Offset point, Offset center, double sx, double sy) {
    final matrix = Matrix4.identity()
      ..multiply(Matrix4.translationValues(center.dx, center.dy, 0))
      ..multiply(Matrix4.diagonal3Values(sx, sy, 1))
      ..multiply(Matrix4.translationValues(-center.dx, -center.dy, 0));
    return flutter_math.MatrixUtils.transformPoint(matrix, point);
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
    return flutter_math.MatrixUtils.transformPoint(matrix, point);
  }
}
