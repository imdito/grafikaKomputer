import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/modules/home/controllers/home_controller.dart';
import 'color_picker/color_picker_view.dart';
import 'stroke_manager/stroke_manager_view.dart';
import 'object_selection/select_view.dart';
import '../../../app/modules/home/widgets/selection_panel.dart';

class AttributesHubView extends StatelessWidget {
  const AttributesHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, size: 20),
              const SizedBox(width: 8),
              Text(
                'Primitive Attributes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SelectView(), // Selection Mode Toggle
          const SizedBox(height: 16),
          SelectionPanel(controller: controller),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          ColorPickerView(controller: controller),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          StrokeManagerView(controller: controller, enabled: true),
        ],
    );
  }
}
