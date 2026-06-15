import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fill_area_hub_controller.dart';
import 'flood_fill/flood_fill_view.dart';

class FillAreaHubView extends StatelessWidget {
  const FillAreaHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FillAreaHubController());

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.format_color_fill, size: 20),
              const SizedBox(width: 8),
              Text(
                'Primitive Fill Area',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  _buildToggleSegment(
                    icon: Icons.water_drop,
                    label: 'Flood Fill',
                    isSelected: controller.activeFill.value == FillType.flood,
                    onTap: () => controller.changeFill(FillType.flood),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white24),
          const SizedBox(height: 16),
          Obx(() {
            switch (controller.activeFill.value) {
              case FillType.flood:
                return const FloodFillView();
            }
          }),
      ],
    );
  }

  Widget _buildToggleSegment({required IconData icon, required String label, required bool isSelected, required VoidCallback onTap}) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
