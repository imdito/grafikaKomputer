import 'package:flutter/material.dart';
import 'enums.dart';

/// Kelas model untuk objek Bentuk 2D (Shape) pada canvas.
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
    this.rasterPoints,
  });

  /// ID unik untuk shape
  final int id;

  /// Tipe dari bentuk 2D (Lingkaran, Kotak, dll)
  final ShapeType type;

  /// Titik pusat bentuk 2D
  final Offset center;

  /// Lebar bounding box bentuk 2D
  final double width;

  /// Tinggi bounding box bentuk 2D
  final double height;

  /// Ketebalan garis luar
  final double strokeWidth;

  /// Gaya garis luar (solid, dashed, dll)
  final StrokeStyle strokeStyle;

  /// Transparansi warna (0.0 - 1.0)
  final double opacity;

  /// Apakah bentuk 2D diwarnai di dalamnya
  final bool isFilled;

  /// Warna dari bentuk (garis maupun isinya jika isFilled true)
  final Color color;

  /// Sudut rotasi bentuk 2D dalam radian
  final double rotationRadians;

  /// Nilai skew/shear pada sumbu X
  final double shearX;

  /// Nilai skew/shear pada sumbu Y
  final double shearY;

  /// Nilai pembalikan (flip) arah X (-1.0 atau 1.0)
  final double flipX;

  /// Nilai pembalikan (flip) arah Y (-1.0 atau 1.0)
  final double flipY;

  /// Titik rasterisasi jika bentuk ini digambar menggunakan algoritma primitif manual (Midpoint)
  final List<Offset>? rasterPoints;

  /// Membuat salinan objek ini dengan beberapa nilai yang dapat diubah
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
    List<Offset>? rasterPoints,
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
      rasterPoints: rasterPoints ?? this.rasterPoints,
    );
  }
}
