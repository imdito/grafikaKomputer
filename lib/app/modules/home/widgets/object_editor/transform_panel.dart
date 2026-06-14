import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../control_panel/inputs/common_inputs.dart';

/// Panel untuk melakukan operasi transformasi (Translasi, Skala, Rotasi, Pencerminan).
class TransformPanel extends StatelessWidget {
  const TransformPanel({
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
