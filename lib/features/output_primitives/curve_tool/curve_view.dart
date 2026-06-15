import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'curve_controller.dart';
import '../../../app/modules/home/widgets/inputs/common_inputs.dart';

/// Panel pengaturan visual dan koordinat manual untuk Curve Tool (Bezier).
class CurveView extends GetView<CurveController> {
  const CurveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Bezier Curve',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Alur Menggambar (3-Ketukan):\n'
          '1. Ketuk titik awal kurva di canvas.\n'
          '2. Ketuk titik akhir kurva (muncul garis bantu).\n'
          '3. Ketuk posisi di canvas untuk menarik kelengkungan.',
          style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
        ),
        const SizedBox(height: 16),
        _buildCoordinateInputs(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: controller.addCurveFromInput,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Draw Curve',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        Obx(() {
          final error = controller.errorMessage.value;
          if (error != null) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                error,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildCoordinateInputs() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.x1Controller,
                label: 'X1 (Mula)',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y1Controller,
                label: 'Y1 (Mula)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.x2Controller,
                label: 'X2 (Akhir)',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.y2Controller,
                label: 'Y2 (Akhir)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.xcController,
                label: 'XC (Kontrol)',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.ycController,
                label: 'YC (Kontrol)',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
