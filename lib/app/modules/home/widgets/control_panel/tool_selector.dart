import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/canvas_models.dart';
import '../../controllers/home_controller.dart';

/// Komponen UI untuk memilih alat gambar aktif.
class ToolSelector extends StatelessWidget {
  const ToolSelector({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildChip(DrawingTool.select, 'Pilih', Icons.ads_click),
          _buildChip(DrawingTool.line, 'Garis', Icons.show_chart),
          _buildChip(DrawingTool.shape, 'Benda 2D', Icons.category_outlined),
          _buildChip(DrawingTool.fill, 'Fill Warna', Icons.format_color_fill),
          _buildChip(DrawingTool.pen, 'Pen', Icons.draw),
        ],
      );
    });
  }

  /// Membuat tombol chip untuk sebuah alat
  Widget _buildChip(DrawingTool tool, String label, IconData icon) {
    final isSelected = controller.selectedTool.value == tool;
    return ChoiceChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.changeTool(tool);
      },
    );
  }
}
