import 'enums.dart';
export 'enums.dart';
export 'object_reference.dart';
export 'grafkom_point.dart';
export 'grafkom_line.dart';
export 'grafkom_shape.dart';
export 'grafkom_freehand.dart';
export 'grafkom_fill_region.dart';
export 'grafkom_curve.dart';

/// Mengembalikan nama tipe bentuk dalam bahasa Indonesia
String shapeTypeName(ShapeType type) {
  switch (type) {
    case ShapeType.circle:
      return 'Lingkaran';
    case ShapeType.square:
      return 'Persegi';
    case ShapeType.rectangle:
      return 'Persegi Panjang';
    case ShapeType.triangle:
      return 'Segitiga';
    case ShapeType.ellipse:
      return 'Elips';
    case ShapeType.diamond:
      return 'Belah Ketupat';
    case ShapeType.trapezoid:
      return 'Trapesium';
  }
}
