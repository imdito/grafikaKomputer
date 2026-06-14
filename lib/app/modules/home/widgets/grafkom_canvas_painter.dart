import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../data/models/canvas_models.dart';
import '../utils/painter_utils.dart';

/// CustomPainter utama yang merender (menggambar) seluruh objek pada canvas.
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
    canvas.drawCanvasBackground(size);
    canvas.drawGrid(size);
    canvas.drawAxis(size);
    _drawFills(canvas);
    _drawShapes(canvas);
    _drawLines(canvas);
    _drawFreehands(canvas);
    _drawPendingLineStart(canvas);
    _drawPendingFreehand(canvas);
    _drawPoints(canvas);
    _drawSelection(canvas);
  }

  /// Menggambar seluruh area flood fill
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

  /// Menggambar objek-objek primitif 2D (Lingkaran, Kotak, Segitiga, dsb)
  void _drawShapes(Canvas canvas) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color.withValues(alpha: shape.opacity)
        ..style = shape.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = shape.strokeWidth;

      canvas.withShapeTransform(shape, () {
        Path shapePath = Path();
        switch (shape.type) {
          case ShapeType.circle:
            shapePath.addOval(Rect.fromCenter(center: Offset.zero, width: shape.width, height: shape.width));
          case ShapeType.square:
          case ShapeType.rectangle:
            shapePath.addRect(PainterUtils.localShapeRect(shape));
          case ShapeType.ellipse:
            shapePath.addOval(PainterUtils.localShapeRect(shape));
          case ShapeType.triangle:
            shapePath = PainterUtils.trianglePath(shape);
          case ShapeType.diamond:
            shapePath = PainterUtils.diamondPath(shape);
          case ShapeType.trapezoid:
            shapePath = PainterUtils.trapezoidPath(shape);
        }

        if (!shape.isFilled && shape.strokeStyle != StrokeStyle.solid) {
          shapePath = PainterUtils.applyDashPattern(shapePath, shape.strokeStyle, shape.strokeWidth);
        }
        canvas.drawPath(shapePath, paint);
      });
    }
  }

  /// Menggambar kumpulan garis dari hasil rasterisasi (DDA atau Bresenham)
  void _drawLines(Canvas canvas) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color.withValues(alpha: line.opacity)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < line.rasterPoints.length; i++) {
        if (!PainterUtils.isStrokeVisible(i, line.strokeWidth, line.strokeStyle)) {
          continue;
        }
        canvas.drawCircle(line.rasterPoints[i], line.strokeWidth / 2, paint);
      }
    }
  }

  /// Menggambar objek coretan bebas (freehand)
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
      
      path = PainterUtils.applyDashPattern(path, fh.strokeStyle, fh.strokeWidth);
      canvas.drawPath(path, paint);
    }
  }

  /// Menggambar bayangan coretan bebas yang sedang digambar secara langsung
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

  /// Menggambar titik awal garis yang belum selesai ditarik (mode Garis dua titik)
  void _drawPendingLineStart(Canvas canvas) {
    final start = pendingLineStart;
    if (start == null) return;

    final paint = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(start, 8, paint);
  }

  /// Menggambar objek titik
  void _drawPoints(Canvas canvas) {
    for (final point in points) {
      final paint = Paint()
        ..color = point.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point.position, point.radius, paint);
    }
  }

  /// Menggambar highlight atau bounding box bagi objek yang sedang di-select
  void _drawSelection(Canvas canvas) {
    final ref = selectedObject;
    if (ref == null) return;

    final paint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    switch (ref.type) {
      case CanvasObjectType.point:
        final point = _findPoint(ref.id);
        if (point != null) canvas.drawCircle(point.position, point.radius + 8, paint);
      case CanvasObjectType.line:
        final line = _findLine(ref.id);
        if (line != null) {
          canvas.drawLine(line.start, line.end, paint);
          canvas.drawCircle(line.start, 7, paint);
          canvas.drawCircle(line.end, 7, paint);
        }
      case CanvasObjectType.shape:
        final shape = _findShape(ref.id);
        if (shape != null) {
          canvas.withShapeTransform(shape, () {
            canvas.drawRect(
              Rect.fromCenter(
                center: Offset.zero,
                width: shape.width + 14,
                height: shape.height + 14,
              ),
              paint,
            );
          });
        }
      case CanvasObjectType.fill:
        break;
      case CanvasObjectType.freehand:
        final fh = _findFreehand(ref.id);
        if (fh != null && fh.points.isNotEmpty) {
          Path path = Path()..moveTo(fh.points.first.dx, fh.points.first.dy);
          for (int i = 1; i < fh.points.length; i++) {
            path.lineTo(fh.points[i].dx, fh.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
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

  GrafkomFreehand? _findFreehand(int id) {
    for (final fh in freehands) {
      if (fh.id == id) return fh;
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
}
