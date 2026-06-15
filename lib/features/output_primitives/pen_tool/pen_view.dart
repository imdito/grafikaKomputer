import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pen_controller.dart';

/// Visual panel for the Pen Tool.
/// Since Pen is mostly freehand drawing on canvas, this view might be empty
/// or contain specific stroke smoothing settings in the future.
class PenView extends GetView<PenController> {
  const PenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pen Tool',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Draw freely on the canvas.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
    );
  }
}
