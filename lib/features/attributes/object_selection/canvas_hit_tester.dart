import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../app/data/models/canvas_models.dart';

class CanvasHitTester {
  /// Returns the CanvasObjectRef of the topmost object tapped, or null if empty space was tapped.
  static CanvasObjectRef? hitTest({
    required Offset tapPosition,
    required List<GrafkomPoint> points,
    required List<GrafkomLine> lines,
    required List<GrafkomShape> shapes,
    required List<GrafkomFreehand> freehands,
  }) {
    // 1. Check Points (Rendered Top-Most)
    for (int i = points.length - 1; i >= 0; i--) {
      final point = points[i];
      final distance = (point.position - tapPosition).distance;
      // Added a small 10px padding for easier finger tapping
      if (distance <= point.radius + 10.0) {
        return CanvasObjectRef(type: CanvasObjectType.point, id: point.id);
      }
    }

    // 2. Check Freehands
    for (int i = freehands.length - 1; i >= 0; i--) {
      final fh = freehands[i];
      final hitThreshold = fh.strokeWidth + 15.0; // Stroke width + tap padding

      for (final pt in fh.points) {
        if ((pt - tapPosition).distance <= hitThreshold) {
          return CanvasObjectRef(type: CanvasObjectType.freehand, id: fh.id);
        }
      }
    }

    // 3. Check Lines (Distance from point to line segment)
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i];
      final hitThreshold = line.strokeWidth + 15.0;

      final l2 =
          math.pow(line.start.dx - line.end.dx, 2) +
          math.pow(line.start.dy - line.end.dy, 2);

      double distance;
      if (l2 == 0.0) {
        distance = (tapPosition - line.start).distance;
      } else {
        // Calculate projection vector
        final t = math.max(
          0.0,
          math.min(
            1.0,
            ((tapPosition.dx - line.start.dx) * (line.end.dx - line.start.dx) +
                    (tapPosition.dy - line.start.dy) *
                        (line.end.dy - line.start.dy)) /
                l2,
          ),
        );

        final projection = Offset(
          line.start.dx + t * (line.end.dx - line.start.dx),
          line.start.dy + t * (line.end.dy - line.start.dy),
        );
        distance = (tapPosition - projection).distance;
      }

      if (distance <= hitThreshold) {
        return CanvasObjectRef(type: CanvasObjectType.line, id: line.id);
      }
    }

    // 4. Check Shapes (Matrix4 Inversion)
    for (int i = shapes.length - 1; i >= 0; i--) {
      final shape = shapes[i];

      // Recreate the shape's exact transformation matrix
      final matrix = Matrix4.identity()
        ..translate(shape.center.dx, shape.center.dy)
        ..rotateZ(shape.rotationRadians)
        ..multiply(
          Matrix4(
            1,
            shape.shearY,
            0,
            0,
            shape.shearX,
            1,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            1,
          ),
        )
        ..scale(shape.flipX, shape.flipY);

      // Invert the matrix
      final inverseMatrix = Matrix4.zero();
      final determinant = inverseMatrix.copyInverse(matrix);

      if (determinant != 0.0) {
        // Apply inverse matrix to the tap position to get local coordinates
        final localPosition = MatrixUtils.transformPoint(
          inverseMatrix,
          tapPosition,
        );

        final halfWidth = shape.width / 2;
        final halfHeight = shape.height / 2;
        final padding = shape.strokeWidth + 10.0;

        // Bounding Box Check
        if (localPosition.dx >= -halfWidth - padding &&
            localPosition.dx <= halfWidth + padding &&
            localPosition.dy >= -halfHeight - padding &&
            localPosition.dy <= halfHeight + padding) {
          // For Ellipses/Circles, we do a more accurate mathematical radius check inside the bounds
          if (shape.type == ShapeType.circle ||
              shape.type == ShapeType.ellipse) {
            final normalizedDistance =
                math.pow(localPosition.dx, 2) /
                    math.pow(halfWidth + padding, 2) +
                math.pow(localPosition.dy, 2) /
                    math.pow(halfHeight + padding, 2);
            if (normalizedDistance <= 1.0) {
              return CanvasObjectRef(
                type: CanvasObjectType.shape,
                id: shape.id,
              );
            }
          } else {
            // For squares/rectangles/triangles, bounding box is sufficient for tap selection
            return CanvasObjectRef(type: CanvasObjectType.shape, id: shape.id);
          }
        }
      }
    }

    // Nothing was hit
    return null;
  }
}
