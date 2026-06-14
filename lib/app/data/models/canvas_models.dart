import 'package:flutter/material.dart';

enum CanvasObjectType { point, line, shape, fill, freehand }

enum DrawingTool { point, line, shape, fill, pen }

enum LineAlgorithm { dda, bresenham }

enum StrokeStyle { solid, dashed, dotted }

enum ShapeType {
  circle,
  square,
  rectangle,
  triangle,
  ellipse,
  diamond,
  trapezoid,
}

class CanvasObjectRef {
  const CanvasObjectRef({required this.type, required this.id});

  final CanvasObjectType type;
  final int id;

  @override
  bool operator ==(Object other) {
    return other is CanvasObjectRef && other.type == type && other.id == id;
  }

  @override
  int get hashCode => Object.hash(type, id);
}

class CanvasObjectOption {
  const CanvasObjectOption({required this.ref, required this.label});

  final CanvasObjectRef ref;
  final String label;
}

class GrafkomPoint {
  const GrafkomPoint({
    required this.id,
    required this.position,
    required this.radius,
    required this.color,
  });

  final int id;
  final Offset position;
  final double radius;
  final Color color;

  GrafkomPoint copyWith({Offset? position, double? radius, Color? color}) {
    return GrafkomPoint(
      id: id,
      position: position ?? this.position,
      radius: radius ?? this.radius,
      color: color ?? this.color,
    );
  }
}

class GrafkomLine {
  const GrafkomLine({
    required this.id,
    required this.start,
    required this.end,
    required this.algorithm,
    required this.strokeWidth,
    this.strokeStyle = StrokeStyle.solid,
    required this.opacity,
    required this.color,
    required this.rasterPoints,
  });

  final int id;
  final Offset start;
  final Offset end;
  final LineAlgorithm algorithm;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final double opacity;
  final Color color;
  final List<Offset> rasterPoints;

  Offset get center => Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

  GrafkomLine copyWith({
    Offset? start,
    Offset? end,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    double? opacity,
    Color? color,
    List<Offset>? rasterPoints,
  }) {
    return GrafkomLine(
      id: id,
      start: start ?? this.start,
      end: end ?? this.end,
      algorithm: algorithm,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
      rasterPoints: rasterPoints ?? this.rasterPoints,
    );
  }
}

class GrafkomFreehand {
  const GrafkomFreehand({
    required this.id,
    required this.points,
    required this.strokeWidth,
    this.strokeStyle = StrokeStyle.solid,
    required this.opacity,
    required this.color,
  });

  final int id;
  final List<Offset> points;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final double opacity;
  final Color color;

  Offset get center {
    if (points.isEmpty) return Offset.zero;
    double sumX = 0;
    double sumY = 0;
    for (final p in points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }

  GrafkomFreehand copyWith({
    List<Offset>? points,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    double? opacity,
    Color? color,
  }) {
    return GrafkomFreehand(
      id: id,
      points: points ?? this.points,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      opacity: opacity ?? this.opacity,
      color: color ?? this.color,
    );
  }
}

class GrafkomFillRegion {
  const GrafkomFillRegion({
    required this.id,
    required this.offsets,
    required this.color,
    required this.opacity,
  });

  final int id;
  final List<Offset> offsets;
  final Color color;
  final double opacity;
}

class GrafkomShape {
  const GrafkomShape({
    required this.id,
    required this.type,
    required this.center,
    required this.width,
    required this.height,
    required this.strokeWidth,
    this.strokeStyle = StrokeStyle.solid,
    required this.opacity,
    required this.isFilled,
    required this.color,
    this.rotationRadians = 0,
    this.shearX = 0,
    this.shearY = 0,
    this.flipX = 1,
    this.flipY = 1,
  });

  final int id;
  final ShapeType type;
  final Offset center;
  final double width;
  final double height;
  final double strokeWidth;
  final StrokeStyle strokeStyle;
  final double opacity;
  final bool isFilled;
  final Color color;
  final double rotationRadians;
  final double shearX;
  final double shearY;
  final double flipX;
  final double flipY;

  GrafkomShape copyWith({
    Offset? center,
    double? width,
    double? height,
    double? strokeWidth,
    StrokeStyle? strokeStyle,
    double? opacity,
    bool? isFilled,
    Color? color,
    double? rotationRadians,
    double? shearX,
    double? shearY,
    double? flipX,
    double? flipY,
  }) {
    return GrafkomShape(
      id: id,
      type: type,
      center: center ?? this.center,
      width: width ?? this.width,
      height: height ?? this.height,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeStyle: strokeStyle ?? this.strokeStyle,
      opacity: opacity ?? this.opacity,
      isFilled: isFilled ?? this.isFilled,
      color: color ?? this.color,
      rotationRadians: rotationRadians ?? this.rotationRadians,
      shearX: shearX ?? this.shearX,
      shearY: shearY ?? this.shearY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
    );
  }
}
