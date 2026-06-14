import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/canvas_models.dart';
import '../../../controllers/home_controller.dart';
import 'common_inputs.dart';

/// Komponen UI untuk mengatur opsi alat Pen (coretan bebas).
class PenInput extends StatelessWidget {
  const PenInput({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menggambar Coretan Bebas (Pen)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Sentuh dan tahan (drag) pada canvas untuk menggambar coretan bebas secara langsung.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
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
          ],
        ),
      ],
    ));
  }
}
