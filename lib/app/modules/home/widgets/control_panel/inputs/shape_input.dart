import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../data/models/canvas_models.dart';
import '../../../controllers/home_controller.dart';
import 'common_inputs.dart';

/// Komponen UI untuk mengatur opsi bentuk 2D (Shape).
class ShapeInput extends StatelessWidget {
  const ShapeInput({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Input Benda 2D',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ShapeType>(
          value: controller.selectedShapeType.value,
          decoration: const InputDecoration(
            labelText: 'Jenis benda',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: ShapeType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(shapeTypeName(type)),
            );
          }).toList(),
          onChanged: (type) {
            if (type != null) {
              controller.changeShapeType(type);
            }
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.shapeXController,
                label: 'X pusat',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeYController,
                label: 'Y pusat',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeWidthController,
                label: 'Lebar',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.shapeHeightController,
                label: 'Tinggi',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderRow(
          label: 'Outline',
          value: controller.shapeStrokeWidth.value,
          min: 1,
          max: 16,
          divisions: 15,
          displayValue: controller.shapeStrokeWidth.value.toStringAsFixed(0),
          onChanged: controller.changeShapeStrokeWidth,
        ),
        SliderRow(
          label: 'Opacity',
          value: controller.shapeOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.shapeOpacity.value * 100).round()}%',
          onChanged: controller.changeShapeOpacity,
        ),
        Row(
          children: [
            const Text('Isi warna'),
            Switch(
              value: controller.isFilledShape.value,
              onChanged: controller.toggleFilledShape,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: controller.addShapeFromInput,
              icon: const Icon(Icons.add),
              label: const Text('Buat Benda'),
            ),
          ],
        ),
      ],
    ));
  }
}
