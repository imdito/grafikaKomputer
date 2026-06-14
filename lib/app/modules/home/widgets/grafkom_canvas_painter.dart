import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import '../../../data/models/canvas_models.dart';
class GrafkomCanvasPainter extends CustomPainter {
  GrafkomCanvasPainter({
    required this.points,
    required this.lines,
    required this.shapes,
    required this.fills,
    required this.freehands,
    required this.pendingLineStart,
    required this.pendingFreehandPoints,
    required this.selectedObject,
  });

  final List<GrafkomPoint> points;
  final List<GrafkomLine> lines;
  final List<GrafkomShape> shapes;
  final List<GrafkomFillRegion> fills;
  final List<GrafkomFreehand> freehands;
  final Offset? pendingLineStart;
  final List<Offset> pendingFreehandPoints;
  final CanvasObjectRef? selectedObject;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCanvasBackground(canvas, size);
    _drawGrid(canvas, size);
    _drawAxis(canvas, size);
    _drawFills(canvas);
    _drawShapes(canvas);
    _drawLines(canvas);
    _drawFreehands(canvas);
    _drawPendingLineStart(canvas);
    _drawPendingFreehand(canvas);
    _drawPoints(canvas);
    _drawSelection(canvas);
  }

  void _drawCanvasBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = Colors.blueGrey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Offset.zero & size;
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRect(rect, borderPaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;

    const spacing = 25.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawAxis(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  void _drawFills(Canvas canvas) {
    for (final fill in fills) {
      final paint = Paint()
        ..color = fill.color.withValues(alpha: fill.opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.square;

      canvas.drawPoints(ui.PointMode.points, fill.offsets, paint);
    }
  }

  void _drawShapes(Canvas canvas) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color.withValues(alpha: shape.opacity)
        ..style = shape.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = shape.strokeWidth;

      _withShapeTransform(canvas, shape, () {
        Path shapePath = Path();
        switch (shape.type) {
          case ShapeType.circle:
            shapePath.addOval(Rect.fromCenter(center: Offset.zero, width: shape.width, height: shape.width));
          case ShapeType.square:
          case ShapeType.rectangle:
            shapePath.addRect(_localShapeRect(shape));
          case ShapeType.ellipse:
            shapePath.addOval(_localShapeRect(shape));
          case ShapeType.triangle:
            shapePath = _trianglePath(shape);
          case ShapeType.diamond:
            shapePath = _diamondPath(shape);
          case ShapeType.trapezoid:
            shapePath = _trapezoidPath(shape);
        }

        if (!shape.isFilled && shape.strokeStyle != StrokeStyle.solid) {
          shapePath = _applyDashPattern(shapePath, shape.strokeStyle, shape.strokeWidth);
        }
        canvas.drawPath(shapePath, paint);
      });
    }
  }

  void _withShapeTransform(
    Canvas canvas,
    GrafkomShape shape,
    VoidCallback draw,
  ) {
    canvas.save();
    canvas.translate(shape.center.dx, shape.center.dy);
    canvas.rotate(shape.rotationRadians);
    canvas.transform(
      Float64List.fromList([
        shape.flipX,
        shape.shearY,
        0,
        0,
        shape.shearX,
        shape.flipY,
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
      ]),
    );
    draw();
    canvas.restore();
  }

  Rect _localShapeRect(GrafkomShape shape) {
    return Rect.fromCenter(
      center: Offset.zero,
      width: shape.width,
      height: shape.height,
    );
  }

  Path _trianglePath(GrafkomShape shape) {
    final halfWidth = shape.width / 2;
    final halfHeight = shape.height / 2;

    return Path()
      ..moveTo(0, -halfHeight)
      ..lineTo(-halfWidth, halfHeight)
      ..lineTo(halfWidth, halfHeight)
      ..close();
  }

  Path _diamondPath(GrafkomShape shape) {
    final halfWidth = shape.width / 2;
    final halfHeight = shape.height / 2;

    return Path()
      ..moveTo(0, -halfHeight)
      ..lineTo(halfWidth, 0)
      ..lineTo(0, halfHeight)
      ..lineTo(-halfWidth, 0)
      ..close();
  }

  Path _trapezoidPath(GrafkomShape shape) {
    final halfTop = shape.width * 0.3;
    final halfBottom = shape.width / 2;
    final halfHeight = shape.height / 2;

    return Path()
      ..moveTo(-halfTop, -halfHeight)
      ..lineTo(halfTop, -halfHeight)
      ..lineTo(halfBottom, halfHeight)
      ..lineTo(-halfBottom, halfHeight)
      ..close();
  }

  void _drawLines(Canvas canvas) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color.withValues(alpha: line.opacity)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < line.rasterPoints.length; i++) {
        if (!_isStrokeVisible(i, line.strokeWidth, line.strokeStyle)) {
          continue;
        }

        canvas.drawCircle(line.rasterPoints[i], line.strokeWidth / 2, paint);
      }
    }
  }

  bool _isStrokeVisible(int index, double strokeWidth, StrokeStyle style) {
    if (style == StrokeStyle.solid) return true;
    if (style == StrokeStyle.dashed) {
      final dashLength = (strokeWidth * 3).clamp(8, 28).round();
      final gapLength = (strokeWidth * 2).clamp(5, 18).round();
      final patternLength = dashLength + gapLength;
      return index % patternLength < dashLength;
    }
    if (style == StrokeStyle.dotted) {
      final gapLength = (strokeWidth * 2.5).clamp(6, 20).round();
      return index % (1 + gapLength) == 0;
    }
    return true;
  }

  Path _applyDashPattern(Path source, StrokeStyle style, double strokeWidth) {
    if (style == StrokeStyle.solid) return source;
    if (style == StrokeStyle.dashed) {
      final dashLen = (strokeWidth * 3).clamp(8.0, 28.0);
      final gapLen = (strokeWidth * 2).clamp(5.0, 18.0);
      return dashPath(source, dashArray: CircularIntervalList<double>([dashLen, gapLen]));
    }
    if (style == StrokeStyle.dotted) {
      final gapLen = (strokeWidth * 2.5).clamp(6.0, 20.0);
      return dashPath(source, dashArray: CircularIntervalList<double>([1.0, gapLen]));
    }
    return source;
  }

  void _drawFreehands(Canvas canvas) {
    for (final fh in freehands) {
      final paint = Paint()
        ..color = fh.color.withValues(alpha: fh.opacity)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = fh.strokeWidth;

      if (fh.points.isEmpty) continue;
      
      Path path = Path()..moveTo(fh.points.first.dx, fh.points.first.dy);
      for (int i = 1; i < fh.points.length; i++) {
        path.lineTo(fh.points[i].dx, fh.points[i].dy);
      }
      
      path = _applyDashPattern(path, fh.strokeStyle, fh.strokeWidth);
      canvas.drawPath(path, paint);
    }
  }

  void _drawPendingFreehand(Canvas canvas) {
    if (pendingFreehandPoints.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;

    Path path = Path()..moveTo(pendingFreehandPoints.first.dx, pendingFreehandPoints.first.dy);
    for (int i = 1; i < pendingFreehandPoints.length; i++) {
      path.lineTo(pendingFreehandPoints[i].dx, pendingFreehandPoints[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawPendingLineStart(Canvas canvas) {
    final start = pendingLineStart;
    if (start == null) {
      return;
    }

    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(start, 8, paint);
  }

  void _drawPoints(Canvas canvas) {
    for (final point in points) {
      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point.position, point.radius, paint);
    }
  }

  void _drawSelection(Canvas canvas) {
    final ref = selectedObject;
    if (ref == null) {
      return;
    }

    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (ref.type) {
      case CanvasObjectType.point:
        final point = _findPoint(ref.id);
        if (point == null) return;
        canvas.drawCircle(point.position, point.radius + 8, paint);
      case CanvasObjectType.line:
        final line = _findLine(ref.id);
        if (line == null) return;
        canvas.drawLine(line.start, line.end, paint);
        canvas.drawCircle(line.start, 7, paint);
        canvas.drawCircle(line.end, 7, paint);
      case CanvasObjectType.shape:
        final shape = _findShape(ref.id);
        if (shape == null) return;
        _withShapeTransform(canvas, shape, () {
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: shape.width + 14,
              height: shape.height + 14,
            ),
            paint,
          );
        });
      case CanvasObjectType.fill:
        break;
      case CanvasObjectType.freehand:
        final fh = _findFreehand(ref.id);
        if (fh == null || fh.points.isEmpty) return;
        Path path = Path()..moveTo(fh.points.first.dx, fh.points.first.dy);
        for (int i = 1; i < fh.points.length; i++) {
          path.lineTo(fh.points[i].dx, fh.points[i].dy);
        }
        canvas.drawPath(path, paint);
    }
  }

  GrafkomPoint? _findPoint(int id) {
    for (final point in points) {
      if (point.id == id) return point;
    }
    return null;
  }

  GrafkomLine? _findLine(int id) {
    for (final line in lines) {
      if (line.id == id) return line;
    }
    return null;
  }

  GrafkomShape? _findShape(int id) {
    for (final shape in shapes) {
      if (shape.id == id) return shape;
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant GrafkomCanvasPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lines != lines ||
        oldDelegate.shapes != shapes ||
        oldDelegate.fills != fills ||
        oldDelegate.freehands != freehands ||
        oldDelegate.pendingLineStart != pendingLineStart ||
        oldDelegate.pendingFreehandPoints != pendingFreehandPoints ||
        oldDelegate.selectedObject != selectedObject;
  }

  GrafkomFreehand? _findFreehand(int id) {
    for (final fh in freehands) {
      if (fh.id == id) return fh;
    }
    return null;
  }
}
