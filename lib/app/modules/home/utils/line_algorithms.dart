import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../data/models/canvas_models.dart';

class LineAlgorithms {
  static List<Offset> generateLinePoints(
    LineAlgorithm algorithm,
    Offset start,
    Offset end,
  ) {
    return switch (algorithm) {
      LineAlgorithm.dda => generateDdaLine(start, end),
      LineAlgorithm.bresenham => generateBresenhamLine(start, end),
    };
  }

  static List<Offset> generateDdaLine(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final steps = math.max(dx.abs(), dy.abs()).round();

    if (steps == 0) {
      return [start];
    }

    final xIncrement = dx / steps;
    final yIncrement = dy / steps;
    var x = start.dx;
    var y = start.dy;
    final result = <Offset>[];

    for (var i = 0; i <= steps; i++) {
      result.add(Offset(x.roundToDouble(), y.roundToDouble()));
      x += xIncrement;
      y += yIncrement;
    }

    return result;
  }

  static List<Offset> generateBresenhamLine(Offset start, Offset end) {
    var x1 = start.dx.round();
    var y1 = start.dy.round();
    final x2 = end.dx.round();
    final y2 = end.dy.round();

    final dx = (x2 - x1).abs();
    final dy = (y2 - y1).abs();
    final sx = x1 < x2 ? 1 : -1;
    final sy = y1 < y2 ? 1 : -1;
    var error = dx - dy;
    final result = <Offset>[];

    while (true) {
      result.add(Offset(x1.toDouble(), y1.toDouble()));

      if (x1 == x2 && y1 == y2) {
        break;
      }

      final error2 = 2 * error;

      if (error2 > -dy) {
        error -= dy;
        x1 += sx;
      }

      if (error2 < dx) {
        error += dx;
        y1 += sy;
      }
    }

    return result;
  }
}
