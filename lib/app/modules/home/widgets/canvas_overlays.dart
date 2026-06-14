import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
class CanvasHint extends StatelessWidget {
  const CanvasHint({required this.tool, required this.hasPendingLine});

  final DrawingTool tool;
  final bool hasPendingLine;

  @override
  Widget build(BuildContext context) {
    final text = switch (tool) {
      DrawingTool.point => 'Tap canvas untuk membuat titik',
      DrawingTool.line when hasPendingLine =>
        'Tap titik akhir garis atau tekan batal',
      DrawingTool.line => 'Tap titik awal, lalu tap titik akhir garis',
      DrawingTool.shape => 'Tap canvas untuk membuat benda 2D',
      DrawingTool.fill => 'Tap di dalam area tertutup untuk mengisi warna',
      DrawingTool.pen => 'Sentuh dan tarik (drag) untuk membuat coretan bebas',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

class CanvasNavigationHint extends StatelessWidget {
  const CanvasNavigationHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.85),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.open_with, size: 16),
            SizedBox(width: 6),
            Text(
              'Geser untuk menjelajah canvas • pinch/scroll untuk zoom',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class ObjectCounter extends StatelessWidget {
  const ObjectCounter({
    required this.totalPoints,
    required this.totalLines,
    required this.totalShapes,
    required this.totalFills,
  });

  final int totalPoints;
  final int totalLines;
  final int totalShapes;
  final int totalFills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.circle, size: 16),
          label: Text('$totalPoints titik'),
        ),
        Chip(
          avatar: const Icon(Icons.show_chart, size: 16),
          label: Text('$totalLines garis'),
        ),
        Chip(
          avatar: const Icon(Icons.category_outlined, size: 16),
          label: Text('$totalShapes benda'),
        ),
        Chip(
          avatar: const Icon(Icons.format_color_fill, size: 16),
          label: Text('$totalFills fill'),
        ),
      ],
    );
  }
}

String shapeTypeName(ShapeType type) {
  return switch (type) {
    ShapeType.circle => 'Lingkaran',
    ShapeType.square => 'Persegi',
    ShapeType.rectangle => 'Persegi Panjang',
    ShapeType.triangle => 'Segitiga',
    ShapeType.ellipse => 'Elips',
    ShapeType.diamond => 'Belah Ketupat',
    ShapeType.trapezoid => 'Trapesium',
  };
}
