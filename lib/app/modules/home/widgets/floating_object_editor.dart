import 'control_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
class FloatingObjectEditor extends StatelessWidget {
  const FloatingObjectEditor({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_location_alt_outlined, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.selectedObjectLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup editor',
                    onPressed: () => controller.selectObject(null),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PrimitiveAttributesPanel(controller: controller, enabled: true),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              TransformPanel(controller: controller, enabled: true),
            ],
          ),
        ),
      ),
    );
  }
}

class TransformPanel extends StatelessWidget {
  const TransformPanel({required this.controller, required this.enabled});

  final HomeController controller;
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
              'Operasi Transformasi',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: controller.translateXController,
                    label: 'Trans X',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberField(
                    controller: controller.translateYController,
                    label: 'Trans Y',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: controller.applyTranslation,
                  child: const Text('Translasi'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: controller.scaleXController,
                    label: 'Scale X',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberField(
                    controller: controller.scaleYController,
                    label: 'Scale Y',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: controller.applyScale,
                  child: const Text('Scale'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: controller.rotateController,
                    label: 'Derajat',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: controller.applyRotation,
                  child: const Text('Rotasi'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: controller.deleteSelectedObject,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: controller.shearXController,
                    label: 'Shear X',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NumberField(
                    controller: controller.shearYController,
                    label: 'Shear Y',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: controller.applyShear,
                  child: const Text('Shear'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Pencerminan (Mirroring)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokal (Terhadap Pusat Objek):',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: controller.reflectHorizontal,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Kiri-Kanan'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.reflectVertical,
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Atas-Bawah'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Global (Terhadap Sumbu Canvas):',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: controller.mirrorGlobalY,
                  icon: const Icon(Icons.align_horizontal_center),
                  label: const Text('Sumbu Y (Vertikal)'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.mirrorGlobalX,
                  icon: const Icon(Icons.align_vertical_center),
                  label: const Text('Sumbu X (Horisontal)'),
                ),
                OutlinedButton.icon(
                  onPressed: controller.mirrorGlobalOrigin,
                  icon: const Icon(Icons.filter_tilt_shift),
                  label: const Text('Pusat Canvas (0,0)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class PrimitiveAttributesPanel extends StatelessWidget {
  const PrimitiveAttributesPanel({super.key, required this.controller, required this.enabled});

  final HomeController controller;
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

  bool _hasStrokeStyle() {
    final ref = controller.selectedObject.value;
    if (ref == null) return false;
    return ref.type == CanvasObjectType.line || ref.type == CanvasObjectType.shape || ref.type == CanvasObjectType.freehand;
  }

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
