import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/data/models/canvas_models.dart';
import '../../output_primitives/math/line_algorithms.dart';

class CanvasRasterizer {
  static List<List<bool>> rasterizeCanvas({
    required List<GrafkomPoint> points,
    required List<GrafkomLine> lines,
    required List<GrafkomShape> shapes,
    required List<GrafkomFreehand> freehands,
  }) {
    final grid = List.generate(1200, (_) => List.filled(900, false));

    // 1. Rasterize Points
    for (final point in points) {
      final rGrid = (point.radius / 2.0).round();
      final cx = (point.position.dx / 2.0).round();
      final cy = (point.position.dy / 2.0).round();

      for (int x = cx - rGrid; x <= cx + rGrid; x++) {
        for (int y = cy - rGrid; y <= cy + rGrid; y++) {
          if (x >= 0 && x < 1200 && y >= 0 && y < 900) {
            final dx = x - cx;
            final dy = y - cy;
            if (dx * dx + dy * dy <= rGrid * rGrid) {
              grid[x][y] = true;
            }
          }
        }
      }
    }

    // Helper to draw a global line on the grid
    void drawGridLine(Offset p1, Offset p2) {
      final pts = LineAlgorithms.generateLinePoints(LineAlgorithm.dda, p1, p2);
      for (final p in pts) {
        final gx = (p.dx / 2.0).round();
        final gy = (p.dy / 2.0).round();
        if (gx >= 0 && gx < 1200 && gy >= 0 && gy < 900) {
          grid[gx][gy] = true;
        }
      }
    }

    // 2. Rasterize Lines
    for (final line in lines) {
      for (final p in line.rasterPoints) {
        final gx = (p.dx / 2.0).round();
        final gy = (p.dy / 2.0).round();
        if (gx >= 0 && gx < 1200 && gy >= 0 && gy < 900) {
          grid[gx][gy] = true;
        }
      }
    }

    // 3. Rasterize Shapes
    for (final shape in shapes) {
      final w = shape.width;
      final h = shape.height;

      final transformMatrix = Matrix4.identity()
        ..multiply(Matrix4.translationValues(shape.center.dx, shape.center.dy, 0))
        ..multiply(Matrix4.rotationZ(shape.rotationRadians))
        ..multiply(Matrix4(
          1, shape.shearY, 0, 0,
          shape.shearX, 1, 0, 0,
          0, 0, 1, 0,
          0, 0, 0, 1,
        ))
        ..multiply(Matrix4.diagonal3Values(shape.flipX, shape.flipY, 1));

      Offset localToGlobal(Offset local) {
        return MatrixUtils.transformPoint(transformMatrix, local);
      }

      if (shape.type == ShapeType.circle || shape.type == ShapeType.ellipse) {
        final rx = shape.width / 2;
        final ry = shape.height / 2;
        final perimeter = 2 * math.pi * math.max(rx, ry);
        final numSteps = (perimeter / 2.0).round().clamp(30, 720);

        for (int i = 0; i <= numSteps; i++) {
          final theta = (i * 2 * math.pi) / numSteps;
          final local = Offset(math.cos(theta) * rx, math.sin(theta) * ry);
          final global = localToGlobal(local);
          final gx = (global.dx / 6.0).round();
          final gy = (global.dy / 6.0).round();
          if (gx >= 0 && gx < 400 && gy >= 0 && gy < 300) {
            grid[gx][gy] = true;
          }
        }
      } else {
        // Polygon shapes: generate corners
        final List<Offset> localCorners = switch (shape.type) {
          ShapeType.square || ShapeType.rectangle => [
            Offset(-w / 2, -h / 2),
            Offset(w / 2, -h / 2),
            Offset(w / 2, h / 2),
            Offset(-w / 2, h / 2),
          ],
          ShapeType.triangle => [
            Offset(0, -h / 2),
            Offset(-w / 2, h / 2),
            Offset(w / 2, h / 2),
          ],
          ShapeType.diamond => [
            Offset(0, -h / 2),
            Offset(w / 2, 0),
            Offset(0, h / 2),
            Offset(-w / 2, 0),
          ],
          ShapeType.trapezoid => [
            Offset(-w * 0.3, -h / 2),
            Offset(w * 0.3, -h / 2),
            Offset(w / 2, h / 2),
            Offset(-w / 2, h / 2),
          ],
          ShapeType.circle || ShapeType.ellipse => const [],
        };

        if (localCorners.isNotEmpty) {
          final globalCorners = localCorners.map(localToGlobal).toList();
          for (int i = 0; i < globalCorners.length; i++) {
            final p1 = globalCorners[i];
            final p2 = globalCorners[(i + 1) % globalCorners.length];
            drawGridLine(p1, p2);
          }
        }
      }
    }

    // 4. Rasterize Freehands
    for (final fh in freehands) {
      if (fh.points.length < 2) continue;
      for (int i = 0; i < fh.points.length - 1; i++) {
        drawGridLine(fh.points[i], fh.points[i + 1]);
      }
    }

    return grid;
  }

  static List<Offset> computeFloodFillOffsets(
    Offset tapPos,
    List<List<bool>> grid,
  ) {
    final startX = (tapPos.dx / 2.0).round().clamp(0, 1199);
    final startY = (tapPos.dy / 2.0).round().clamp(0, 899);

    if (grid[startX][startY]) {
      return [];
    }

    final filledOffsets = <Offset>[];
    final queue = <math.Point<int>>[];
    final visited = List.generate(1200, (_) => List.filled(900, false));

    queue.add(math.Point(startX, startY));
    visited[startX][startY] = true;

    final directions = const [
      math.Point(1, 0),
      math.Point(-1, 0),
      math.Point(0, 1),
      math.Point(0, -1),
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);

      filledOffsets.add(Offset(current.x * 2.0 + 1.0, current.y * 2.0 + 1.0));

      if (filledOffsets.length > 1080000) {
        break; // max 1200 * 900
      }

      for (final dir in directions) {
        final nx = current.x + dir.x;
        final ny = current.y + dir.y;

        if (nx >= 0 && nx < 1200 && ny >= 0 && ny < 900) {
          if (!visited[nx][ny] && !grid[nx][ny]) {
            visited[nx][ny] = true;
            queue.add(math.Point(nx, ny));
          }
        }
      }
    }

    return filledOffsets;
  }
}
