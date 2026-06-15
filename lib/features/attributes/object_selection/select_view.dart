import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'select_controller.dart';

class SelectView extends GetView<SelectController> {
  const SelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Tool',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap on any object on the canvas to select it.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
    );
  }
}
