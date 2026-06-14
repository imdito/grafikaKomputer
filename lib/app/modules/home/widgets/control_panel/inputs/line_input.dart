import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/canvas_models.dart';
import '../../../controllers/home_controller.dart';
import 'common_inputs.dart';

/// Komponen UI untuk mengatur opsi input Garis.
class LineInput extends StatelessWidget {
  const LineInput({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Garis Manual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SegmentedButton<LineAlgorithm>(
          segments: const [
            ButtonSegment(value: LineAlgorithm.dda, label: Text('DDA')),
            ButtonSegment(
              value: LineAlgorithm.bresenham,
              label: Text('Bresenham'),
            ),
          ],
          selected: {controller.selectedAlgorithm.value},
          onSelectionChanged: (selection) {
            controller.changeAlgorithm(selection.first);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.x1Controller,
                label: 'X1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y1Controller,
                label: 'Y1',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.x2Controller,
                label: 'X2',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y2Controller,
                label: 'Y2',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderRow(
          label: 'Tebal',
          value: controller.strokeWidth.value,
          min: 1,
          max: 16,
          divisions: 15,
          displayValue: controller.strokeWidth.value.toStringAsFixed(0),
          onChanged: controller.changeStrokeWidth,
        ),
        SliderRow(
          label: 'Opacity',
          value: controller.lineOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.lineOpacity.value * 100).round()}%',
          onChanged: controller.changeLineOpacity,
        ),
        Row(
          children: [
            const Text('Gaya Garis:'),
            const SizedBox(width: 8),
            DropdownButton<StrokeStyle>(
              value: controller.lineStyle.value,
              items: const [
                DropdownMenuItem(value: StrokeStyle.solid, child: Text('Solid')),
                DropdownMenuItem(value: StrokeStyle.dashed, child: Text('Dashed')),
                DropdownMenuItem(value: StrokeStyle.dotted, child: Text('Dotted')),
              ],
              onChanged: (style) {
                if (style != null) controller.changeLineStyle(style);
              },
            ),
            const Spacer(),
            if (controller.pendingLineStart.value != null)
              TextButton.icon(
                onPressed: controller.cancelPendingLine,
                icon: const Icon(Icons.close),
                label: const Text('Batal titik awal'),
              ),
            const Spacer(),
            FilledButton.icon(
              onPressed: controller.addLineFromInput,
              icon: const Icon(Icons.add),
              label: const Text('Buat Garis'),
            ),
          ],
        ),
      ],
    ));
  }
}
