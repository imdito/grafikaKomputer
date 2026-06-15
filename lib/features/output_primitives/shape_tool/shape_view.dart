import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shape_controller.dart';

/// Precise parameters and settings for the Shape Tool.
/// Displayed inside the larger ContextualToolPanel when the user taps the settings icon.
class ShapeView extends GetView<ShapeController> {
  const ShapeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Shape Settings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 16),

        // ── Fill / Outline Toggle ──
        Text(
          'Tipe Gambar',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildFillToggle(),
        const SizedBox(height: 16),

        // ── Precise Input Header ──
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Text(
              'Input Presisi (Manual)',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildDimensionInputs(),
        const SizedBox(height: 8),
        _buildCoordinateInputs(),
        const SizedBox(height: 16),

        // ── Add Shape Button ──
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: controller.addShapeFromInput,
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
                    'Tambah Bentuk',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFillToggle() {
    return Obx(() {
      final isFilled = controller.isFilledShape.value;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            _buildToggleSegment(
              label: 'Outline / Garis Luar',
              icon: Icons.panorama_fish_eye_rounded,
              isSelected: !isFilled,
              onTap: () => controller.isFilledShape.value = false,
            ),
            _buildToggleSegment(
              label: 'Filled / Warna Isi',
              icon: Icons.circle_rounded,
              isSelected: isFilled,
              onTap: () => controller.isFilledShape.value = true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildToggleSegment({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassInput(controller.shapeWidthController, 'Width (L)'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              _buildGlassInput(controller.shapeHeightController, 'Height (T)'),
        ),
      ],
    );
  }

  Widget _buildCoordinateInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassInput(controller.shapeXController, 'Center X'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildGlassInput(controller.shapeYController, 'Center Y'),
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
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
