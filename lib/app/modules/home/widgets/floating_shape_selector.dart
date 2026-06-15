import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import '../../../../features/output_primitives/shape_tool/shape_controller.dart';
import '../../../data/models/canvas_models.dart';
import '../controllers/dock_controller.dart';
import 'glass/glass_container.dart';
import 'glass/glass_icon_button.dart';

/// A floating, capsule-shaped horizontal bar dedicated solely to shape selection.
/// Replicates the exact size, padding, and button styles of the main FloatingToolDock.
class FloatingShapeSelector extends StatelessWidget {
  const FloatingShapeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShapeController>()) return const SizedBox.shrink();
    final controller = Get.find<ShapeController>();

    final shapeIcons = <ShapeType, IconData>{
      ShapeType.circle: Icons.circle_outlined,
      ShapeType.square: Icons.crop_square_rounded,
      ShapeType.rectangle: Icons.crop_3_2_rounded,
      ShapeType.triangle: Icons.change_history_rounded,
      ShapeType.ellipse: Icons.circle_sharp,
      ShapeType.diamond: Icons.diamond_outlined,
      ShapeType.trapezoid: Icons.category_outlined,
    };

    final shapeNames = <ShapeType, String>{
      ShapeType.circle: 'Lingkaran',
      ShapeType.square: 'Persegi',
      ShapeType.rectangle: 'Persegi Panjang',
      ShapeType.triangle: 'Segitiga',
      ShapeType.ellipse: 'Elips',
      ShapeType.diamond: 'Belah Ketupat',
      ShapeType.trapezoid: 'Trapesium',
    };

    return Center(
      child: GlassContainer(
        blurSigma: GrafkomTheme.blurDock,
        borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Shape Icons ──
              Obx(() {
                final selectedType = controller.selectedShapeType.value;
                return Row(
                  children: ShapeType.values.map((type) {
                    final isSelected = selectedType == type;
                    final icon = shapeIcons[type] ?? Icons.help_outline;
                    final name = shapeNames[type] ?? type.name;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GlassIconButton(
                        size: 42,
                        icon: icon,
                        tooltip: name,
                        isActive: isSelected,
                        iconSize: 20,
                        onPressed: () {
                          controller.selectedShapeType.value = type;
                        },
                      ),
                    );
                  }).toList(),
                );
              }),

              // ── Divider ──
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: GrafkomTheme.glassBorder,
              ),

              // ── Tune / Settings Button ──
              Obx(() {
                final isPanelOpen = Get.isRegistered<DockController>() &&
                    Get.find<DockController>().isToolPanelVisible.value;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GlassIconButton(
                    size: 42,
                    icon: Icons.tune_rounded,
                    tooltip: 'Pengaturan Detail',
                    isActive: isPanelOpen,
                    iconSize: 20,
                    onPressed: () {
                      if (Get.isRegistered<DockController>()) {
                        final dockCtrl = Get.find<DockController>();
                        dockCtrl.isToolPanelVisible.value =
                            !dockCtrl.isToolPanelVisible.value;
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
