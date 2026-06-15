import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'line_controller.dart';
import '../../../app/data/models/canvas_models.dart';

/// Visual panel for the Line Tool.
class LineView extends GetView<LineController> {
  const LineView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Line Tool',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlgorithmToggle(context),
          const SizedBox(height: 16),
          _buildCoordinateInputs(),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: controller.addLineFromInput,
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
                    Text('Draw Line', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
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

  Widget _buildAlgorithmToggle(BuildContext context) {
    return Obx(() {
      return Row(
        children: [
          const Text('Algorithm: ', style: TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  _buildToggleSegment(
                    label: 'DDA',
                    isSelected: controller.selectedAlgorithm.value == LineAlgorithm.dda,
                    onTap: () => controller.changeAlgorithm(LineAlgorithm.dda),
                  ),
                  _buildToggleSegment(
                    label: 'Bresenham',
                    isSelected: controller.selectedAlgorithm.value == LineAlgorithm.bresenham,
                    onTap: () => controller.changeAlgorithm(LineAlgorithm.bresenham),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildToggleSegment({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateInputs() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildGlassInput(controller.x1Controller, 'X1'),
              const SizedBox(height: 8),
              _buildGlassInput(controller.y1Controller, 'Y1'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              _buildGlassInput(controller.x2Controller, 'X2'),
              const SizedBox(height: 8),
              _buildGlassInput(controller.y2Controller, 'Y2'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassInput(TextEditingController controller, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
