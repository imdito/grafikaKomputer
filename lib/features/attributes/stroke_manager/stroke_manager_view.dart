import 'package:flutter/material.dart';
import '../../../../app/data/models/canvas_models.dart';
import '../../../../app/modules/home/controllers/home_controller.dart';

class StrokeManagerView extends StatelessWidget {
  const StrokeManagerView({
    super.key,
    required this.controller,
    required this.enabled,
  });

  /// Referensi ke HomeController
  final HomeController controller;
  
  /// Apakah panel ini aktif (dapat diinteraksi)
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atribut Primitif',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Tebal:'),
                Expanded(
                  child: Slider(
                    value: _getCurrentThickness(),
                    min: 1,
                    max: 16,
                    divisions: 15,
                    onChanged: controller.updateSelectedThickness,
                  ),
                ),
                Text(_getCurrentThickness().toStringAsFixed(0)),
              ],
            ),
            if (_hasStrokeStyle())
              Row(
                children: [
                  const Text('Gaya Garis:'),
                  const SizedBox(width: 8),
                  DropdownButton<StrokeStyle>(
                    value: _getCurrentStrokeStyle(),
                    items: const [
                      DropdownMenuItem(value: StrokeStyle.solid, child: Text('Solid')),
                      DropdownMenuItem(value: StrokeStyle.dashed, child: Text('Dashed')),
                      DropdownMenuItem(value: StrokeStyle.dotted, child: Text('Dotted')),
                    ],
                    onChanged: (style) {
                      if (style != null) controller.updateSelectedStrokeStyle(style);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Mengambil ketebalan saat ini dari objek yang sedang dipilih
  double _getCurrentThickness() {
    final ref = controller.selectedObject.value;
    if (ref == null) return 4.0;
    
    for (final layer in controller.layers) {
      switch (ref.type) {
        case CanvasObjectType.point:
          final index = layer.points.indexWhere((p) => p.id == ref.id);
          if (index != -1) return layer.points[index].radius;
          break;
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((l) => l.id == ref.id);
          if (index != -1) return layer.lines[index].strokeWidth;
          break;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((s) => s.id == ref.id);
          if (index != -1) return layer.shapes[index].strokeWidth;
          break;
        case CanvasObjectType.freehand:
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) return layer.freehands[index].strokeWidth;
          break;
        case CanvasObjectType.curve:
          final index = layer.curves.indexWhere((c) => c.id == ref.id);
          if (index != -1) return layer.curves[index].strokeWidth;
          break;
        case CanvasObjectType.fill:
          return 4.0;
      }
    }
    return 4.0;
  }

  /// Mengecek apakah objek yang dipilih mendukung pengaturan gaya garis
  bool _hasStrokeStyle() {
    final ref = controller.selectedObject.value;
    if (ref == null) return false;
    return ref.type == CanvasObjectType.line ||
           ref.type == CanvasObjectType.shape ||
           ref.type == CanvasObjectType.freehand;
  }

  /// Mengambil gaya garis dari objek yang sedang dipilih
  StrokeStyle _getCurrentStrokeStyle() {
    final ref = controller.selectedObject.value;
    if (ref == null) return StrokeStyle.solid;
    
    for (final layer in controller.layers) {
      switch (ref.type) {
        case CanvasObjectType.line:
          final index = layer.lines.indexWhere((l) => l.id == ref.id);
          if (index != -1) return layer.lines[index].strokeStyle;
          break;
        case CanvasObjectType.shape:
          final index = layer.shapes.indexWhere((s) => s.id == ref.id);
          if (index != -1) return layer.shapes[index].strokeStyle;
          break;
        case CanvasObjectType.freehand:
          final index = layer.freehands.indexWhere((fh) => fh.id == ref.id);
          if (index != -1) return layer.freehands[index].strokeStyle;
          break;
        default:
          break;
      }
    }
    return StrokeStyle.solid;
  }
}
