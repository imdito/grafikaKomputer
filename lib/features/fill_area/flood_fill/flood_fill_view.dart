import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/modules/home/controllers/home_controller.dart';
import '../../attributes/color_picker/color_picker_view.dart';
import 'flood_fill_controller.dart';

class FloodFillView extends GetView<FloodFillController> {
  const FloodFillView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Flood Fill',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => CheckboxListTile(
            title: const Text('Sample All Layers'),
            subtitle: const Text('Fill intersects boundaries from every visible layer'),
            value: controller.isSampleAllLayersActive.value,
            onChanged: (val) {
              if (val != null) {
                controller.isSampleAllLayersActive.value = val;
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          )),
          const Divider(height: 24, color: Colors.white24),
          const SizedBox(height: 4),
          ColorPickerView(controller: homeController),
        ],
    );
  }
}

