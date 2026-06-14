import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import 'common_inputs.dart';

/// Komponen UI untuk mengatur opsi mewarnai area (Flood Fill).
class FillInput extends StatelessWidget {
  const FillInput({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mewarnai Area (Flood Fill)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih warna global di atas, lalu tutup menu ini dan TAP di area tertutup mana saja (termasuk potongan benda/garis berpotongan) di canvas.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        SliderRow(
          label: 'Opacity',
          value: controller.shapeOpacity.value,
          min: 0.1,
          max: 1,
          divisions: 9,
          displayValue: '${(controller.shapeOpacity.value * 100).round()}%',
          onChanged: controller.changeShapeOpacity,
        ),
      ],
    ));
  }
}
