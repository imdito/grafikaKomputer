import 'package:flutter/material.dart';
import '../../../../data/models/canvas_models.dart';
import '../../controllers/home_controller.dart';

/// Panel untuk mengubah atribut primitif (Tebal, Gaya Garis) dari objek terpilih.
class PrimitiveAttributesPanel extends StatelessWidget {
  const PrimitiveAttributesPanel({
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
    switch (ref.type) {
      case CanvasObjectType.point:
        final index = controller.points.indexWhere((p) => p.id == ref.id);
        return index != -1 ? controller.points[index].radius : 4.0;
      case CanvasObjectType.line:
        final index = controller.lines.indexWhere((l) => l.id == ref.id);
        return index != -1 ? controller.lines[index].strokeWidth : 4.0;
      case CanvasObjectType.shape:
        final index = controller.shapes.indexWhere((s) => s.id == ref.id);
        return index != -1 ? controller.shapes[index].strokeWidth : 3.0;
      case CanvasObjectType.freehand:
        final index = controller.freehands.indexWhere((fh) => fh.id == ref.id);
        return index != -1 ? controller.freehands[index].strokeWidth : 4.0;
      case CanvasObjectType.fill:
        return 4.0;
    }
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
    switch (ref.type) {
      case CanvasObjectType.line:
        final index = controller.lines.indexWhere((l) => l.id == ref.id);
        return index != -1 ? controller.lines[index].strokeStyle : StrokeStyle.solid;
      case CanvasObjectType.shape:
        final index = controller.shapes.indexWhere((s) => s.id == ref.id);
        return index != -1 ? controller.shapes[index].strokeStyle : StrokeStyle.solid;
      case CanvasObjectType.freehand:
        final index = controller.freehands.indexWhere((fh) => fh.id == ref.id);
        return index != -1 ? controller.freehands[index].strokeStyle : StrokeStyle.solid;
      default:
        return StrokeStyle.solid;
    }
  }
}
