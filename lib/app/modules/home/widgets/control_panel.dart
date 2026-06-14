import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_models.dart';
import 'selection_panel.dart';
import 'control_panel/tool_selector.dart';
import 'control_panel/color_selector.dart';
import 'control_panel/inputs/line_input.dart';
import 'control_panel/inputs/shape_input.dart';
import 'control_panel/inputs/fill_input.dart';
import 'control_panel/inputs/pen_input.dart';

/// Komponen Panel Kontrol utama yang muncul dari bawah (BottomSheet).
/// Digunakan untuk memilih warna, alat, dan parameter gambar.
class ControlPanel extends StatelessWidget {
  const ControlPanel({required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectionPanel(controller: controller),
                const Divider(height: 28),
                ToolSelector(controller: controller),
                const SizedBox(height: 12),
                ColorSelector(controller: controller),
                const SizedBox(height: 12),
                switch (controller.selectedTool.value) {
                  DrawingTool.select => const SizedBox(),
                  DrawingTool.line => LineInput(controller: controller),
                  DrawingTool.shape => ShapeInput(controller: controller),
                  DrawingTool.fill => FillInput(controller: controller),
                  DrawingTool.pen => PenInput(controller: controller),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
