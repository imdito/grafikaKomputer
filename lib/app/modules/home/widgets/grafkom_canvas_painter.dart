import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../data/models/canvas_models.dart';
import '../utils/painter_utils.dart';
import '../../../data/models/canvas_layer.dart';

/// CustomPainter utama yang merender (menggambar) seluruh objek pada canvas.
class GrafkomCanvasPainter extends CustomPainter {
  GrafkomCanvasPainter({
    required this.layers,
    required this.pendingLineStart,
    required this.pendingFreehandPoints,
    required this.selectedObject,
    required this.pendingCurveStart,
    required this.pendingCurveEnd,
    this.pendingShape,
  });

  final List<CanvasLayer> layers;
  final Offset? pendingLineStart;
  final List<Offset> pendingFreehandPoints;
  final CanvasObjectRef? selectedObject;
  final Offset? pendingCurveStart;
  final Offset? pendingCurveEnd;
  final GrafkomShape? pendingShape;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCanvasBackground(size);
    canvas.drawGrid(size);
    canvas.drawAxis(size);

    for (final layer in layers) {
      if (!layer.isVisible) continue;
      _drawFills(canvas, layer.fills);
      _drawShapes(canvas, layer.shapes);
      _drawLines(canvas, layer.lines);
      _drawCurves(canvas, layer.curves);
      _drawFreehands(canvas, layer.freehands);
      _drawPoints(canvas, layer.points);
    }

    _drawPendingLineStart(canvas);
    _drawPendingCurve(canvas);
    _drawPendingFreehand(canvas);
    _drawPendingShape(canvas);
    _drawSelection(canvas);
  }

  /// Menggambar seluruh area flood fill
  void _drawFills(Canvas canvas, List<GrafkomFillRegion> fills) {
    for (final fill in fills) {
      final paint = Paint()
        ..color = fill.color.withValues(alpha: fill.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawPath(fill.path, paint);
    }
  }

  /// Menggambar objek-objek primitif 2D (Lingkaran, Kotak, Segitiga, dsb)
  void _drawShapes(Canvas canvas, List<GrafkomShape> shapes) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color.withValues(alpha: shape.opacity)
        ..style = shape.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = shape.strokeWidth;

      canvas.withShapeTransform(shape, () {
        if (shape.rasterPoints != null) {
          canvas.drawPoints(ui.PointMode.points, shape.rasterPoints!, paint);
          return;
        }

        Path shapePath = Path();
        switch (shape.type) {
          case ShapeType.circle:
            shapePath.addOval(
              Rect.fromCenter(
                center: Offset.zero,
                width: shape.width,
                height: shape.width,
              ),
            );
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
          shapePath = PainterUtils.applyDashPattern(
            shapePath,
            shape.strokeStyle,
            shape.strokeWidth,
          );
        }
        canvas.drawPath(shapePath, paint);
      });
    }
  }

  /// Menggambar kumpulan garis dari hasil rasterisasi (DDA atau Bresenham)
  void _drawLines(Canvas canvas, List<GrafkomLine> lines) {
    for (final line in lines) {
      final paint = Paint()
        ..color = line.color.withValues(alpha: line.opacity)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < line.rasterPoints.length; i++) {
        if (!PainterUtils.isStrokeVisible(
          i,
          line.strokeWidth,
          line.strokeStyle,
        )) {
          continue;
        }
        canvas.drawCircle(line.rasterPoints[i], line.strokeWidth / 2, paint);
      }
    }
  }

  /// Menggambar kurva hasil rasterisasi parametric Bezier
  void _drawCurves(Canvas canvas, List<GrafkomCurve> curves) {
    for (final curve in curves) {
      final paint = Paint()
        ..color = curve.color.withValues(alpha: curve.opacity)
        ..style = PaintingStyle.fill;

      for (final pt in curve.rasterPoints) {
        canvas.drawCircle(pt, curve.strokeWidth / 2, paint);
      }
    }
  }

  /// Menggambar objek coretan bebas (freehand)
  void _drawFreehands(Canvas canvas, List<GrafkomFreehand> freehands) {
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

      path = PainterUtils.applyDashPattern(
        path,
        fh.strokeStyle,
        fh.strokeWidth,
      );
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

    Path path = Path()
      ..moveTo(pendingFreehandPoints.first.dx, pendingFreehandPoints.first.dy);
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

  /// Menggambar titik dan garis bantu kurva Bezier yang belum selesai (mode Kurva 3 titik)
  void _drawPendingCurve(Canvas canvas) {
    if (pendingCurveStart == null) return;
    final start = pendingCurveStart!;

    final paintEndPoints = Paint()
      ..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(start, 6, paintEndPoints);

    if (pendingCurveEnd != null) {
      final end = pendingCurveEnd!;
      canvas.drawCircle(end, 6, paintEndPoints);

      final paintLine = Paint()
        ..color = Colors.blueGrey.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(start, end, paintLine);
    }
  }

  /// Menggambar objek titik
  void _drawPoints(Canvas canvas, List<GrafkomPoint> points) {
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
        if (point != null)
          canvas.drawCircle(point.position, point.radius + 8, paint);
      case CanvasObjectType.line:
        final line = _findLine(ref.id);
        if (line != null) {
          canvas.drawLine(line.start, line.end, paint);
          canvas.drawCircle(line.start, 7, paint);
          canvas.drawCircle(line.end, 7, paint);
        }
      case CanvasObjectType.curve:
        final curve = _findCurve(ref.id);
        if (curve != null) {
          final paintLine = Paint()
            ..color = Colors.lightBlueAccent.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawLine(curve.start, curve.control, paintLine);
          canvas.drawLine(curve.end, curve.control, paintLine);
          canvas.drawCircle(curve.start, 7, paint);
          canvas.drawCircle(curve.control, 7, paint..color = Colors.cyanAccent);
          canvas.drawCircle(curve.end, 7, paint..color = Colors.lightBlueAccent);
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
    for (final layer in layers) {
      for (final point in layer.points) {
        if (point.id == id) return point;
      }
    }
    return null;
  }

  GrafkomLine? _findLine(int id) {
    for (final layer in layers) {
      for (final line in layer.lines) {
        if (line.id == id) return line;
      }
    }
    return null;
  }

  GrafkomCurve? _findCurve(int id) {
    for (final layer in layers) {
      for (final curve in layer.curves) {
        if (curve.id == id) return curve;
      }
    }
    return null;
  }

  GrafkomShape? _findShape(int id) {
    for (final layer in layers) {
      for (final shape in layer.shapes) {
        if (shape.id == id) return shape;
      }
    }
    return null;
  }

  GrafkomFreehand? _findFreehand(int id) {
    for (final layer in layers) {
      for (final fh in layer.freehands) {
        if (fh.id == id) return fh;
      }
    }
    return null;
  }

  void _drawPendingShape(Canvas canvas) {
    final shape = pendingShape;
    if (shape == null) return;

    final paint = Paint()
      ..color = shape.color.withValues(alpha: shape.opacity)
      ..style = shape.isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = shape.strokeWidth;

    canvas.withShapeTransform(shape, () {
      if (shape.rasterPoints != null) {
        canvas.drawPoints(ui.PointMode.points, shape.rasterPoints!, paint);
        return;
      }

      Path shapePath = Path();
      switch (shape.type) {
        case ShapeType.circle:
          shapePath.addOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: shape.width,
              height: shape.width,
            ),
          );
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
        shapePath = PainterUtils.applyDashPattern(
          shapePath,
          shape.strokeStyle,
          shape.strokeWidth,
        );
      }
      canvas.drawPath(shapePath, paint);
    });
  }

  @override
  bool shouldRepaint(covariant GrafkomCanvasPainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.pendingLineStart != pendingLineStart ||
        oldDelegate.pendingCurveStart != pendingCurveStart ||
        oldDelegate.pendingCurveEnd != pendingCurveEnd ||
        oldDelegate.pendingFreehandPoints != pendingFreehandPoints ||
        oldDelegate.selectedObject != selectedObject ||
        oldDelegate.pendingShape != pendingShape;
  }
}
