import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'point_controller.dart';
import '../../../../app/modules/home/widgets/inputs/common_inputs.dart';

class PointView extends GetView<PointController> {
  const PointView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tool Titik (Point)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.xController,
                label: 'Posisi X',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NumberField(
                controller: controller.yController,
                label: 'Posisi Y',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NumberField(
                controller: controller.radiusController,
                label: 'Radius / Ukuran',
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.addPointFromInput,
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
                    Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text('Buat Titik', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ],
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
}
