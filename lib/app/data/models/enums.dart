/// Enum untuk menentukan tipe alat gambar atau mode yang sedang aktif
enum DrawingTool {
  hand,
  primitives,
  shape,
  fill,
  pen,
  curve,
  attributes,
  transformations,
}

/// Enum untuk menentukan tipe objek pada canvas
enum CanvasObjectType { point, line, shape, fill, freehand, curve }

/// Enum untuk algoritma garis yang digunakan
enum LineAlgorithm { dda, bresenham }

/// Enum untuk menentukan gaya garis
enum StrokeStyle { solid, dashed, dotted }

/// Enum untuk berbagai bentuk 2D yang bisa digambar
enum ShapeType {
  circle,
  square,
  rectangle,
  triangle,
  ellipse,
  diamond,
  trapezoid,
}
