import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';

/// Displays a subtle hint chip above the floating dock
/// indicating the currently active tool and its usage instructions.
class CanvasHint extends StatelessWidget {
  const CanvasHint({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tool = controller.selectedTool.value;
      final hasPendingLine = controller.pendingLineStart.value != null;
      final hasPendingCurve = controller.pendingCurveStart.value != null;
      final hasPendingCurveEnd = controller.pendingCurveEnd.value != null;

      final text = switch (tool) {
        DrawingTool.primitives when hasPendingLine =>
          'Tap titik akhir garis atau tekan batal',
        DrawingTool.hand => 'Sentuh dan geser untuk navigasi canvas',
        DrawingTool.primitives => 'Tap titik awal, lalu tap titik akhir garis',
        DrawingTool.shape => 'Tap canvas untuk membuat benda 2D',
        DrawingTool.attributes => '',
        DrawingTool.transformations => 'Tap objek untuk melakukan transformasi',
        DrawingTool.fill => 'Tap di dalam area tertutup untuk mengisi warna',
        DrawingTool.pen =>
          'Sentuh dan tarik (drag) untuk membuat coretan bebas',
        DrawingTool.curve when hasPendingCurve && !hasPendingCurveEnd =>
          'Tap titik akhir kurva',
        DrawingTool.curve when hasPendingCurve && hasPendingCurveEnd =>
          'Tap titik kontrol untuk menarik kelengkungan kurva',
        DrawingTool.curve => 'Tap titik awal kurva',
      };

      if (text.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: GrafkomTheme.glassSurface,
          borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
          border: Border.all(color: GrafkomTheme.glassBorder),
        ),
        child: Text(
          text,
          style: GrafkomTheme.labelMd.copyWith(
            color: GrafkomTheme.onSurfaceVariant,
          ),
        ),
      );
    });
  }
}

class CanvasNavigationHint extends StatelessWidget {
  const CanvasNavigationHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GrafkomTheme.glassSurface,
        borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
        border: Border.all(color: GrafkomTheme.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.open_with, size: 16, color: GrafkomTheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            'Geser untuk menjelajah canvas • pinch/scroll untuk zoom',
            style: GrafkomTheme.labelMd.copyWith(
              color: GrafkomTheme.onSurfaceVariant,
            ),
          ),
        ],
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
