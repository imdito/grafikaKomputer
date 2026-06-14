import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
class CanvasHint extends StatelessWidget {
  const CanvasHint({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tool = controller.selectedTool.value;
      final hasPendingLine = controller.pendingLineStart.value != null;
      
      final text = switch (tool) {
        DrawingTool.select => 'Mode Pilih: Gunakan menu untuk memilih & mengedit objek',
        DrawingTool.line when hasPendingLine => 'Tap titik akhir garis atau tekan batal',
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
    });
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
