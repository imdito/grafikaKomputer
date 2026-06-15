import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import '../../../data/models/canvas_models.dart';
import '../widgets/floating_tool_dock.dart';
import '../widgets/undo_redo_pill.dart';
import '../widgets/interactive_canvas.dart';
import '../widgets/layer_panel.dart';
import '../widgets/contextual_tool_panel.dart';
import '../widgets/floating_shape_selector.dart';
import '../widgets/glass/glass_container.dart';
import '../widgets/glass/glass_icon_button.dart';
import '../controllers/dock_controller.dart';

/// Halaman utama aplikasi yang menampilkan canvas gambar dan overlay UI.
///
/// Layout architecture (Obsidian Glass design):
/// - Layer 0: Dark canvas background + InteractiveCanvas
/// - Layer 1: Undo/Redo Pill (top-left)
/// - Layer 2: FloatingObjectEditor (top-right, when object selected)
/// - Layer 3: Canvas Hint (bottom, above dock)
/// - Layer 4: Floating Tool Dock (bottom-center)
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  /// Ukuran virtual dari canvas gambar
  static const _canvasSize = Size(2400, 1800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            // ── Layer 0: Canvas background & drawing ──
            Positioned.fill(
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: InteractiveCanvas(
                  controller: controller,
                  canvasSize: _canvasSize,
                ),
              ),
            ),

            // ── Layer 1: Undo/Redo Pill (top-left) ──
            UndoRedoPill(controller: controller),

            // ── Trash/Clear Progress Button (top-right) ──
            Positioned(
              top:
                  MediaQuery.of(context).padding.top +
                  GrafkomTheme.marginMobile,
              right: GrafkomTheme.marginMobile,
              child: GlassContainer(
                blurSigma: GrafkomTheme.blurDock,
                borderRadius: BorderRadius.circular(GrafkomTheme.radiusFull),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: GlassIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Hapus Semua Progres',
                  size: 40,
                  iconSize: 20,
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ),
            ),

            // ── Layer 2: Removed FloatingObjectEditor ──

            // ── Layer 3: Removed Canvas Hint (now a tooltip) ──

            // ── Layer 4: Floating Tool Dock (bottom-center) ──
            FloatingToolDock(controller: controller),

            // ── Layer 5: Contextual Pop-out Panel (Instant Visibility) ──
            Obx(() {
              if (!Get.isRegistered<DockController>())
                return const SizedBox.shrink();
              final isVisible =
                  Get.find<DockController>().isToolPanelVisible.value;
              if (!isVisible) return const SizedBox.shrink();

              final activeTool = controller.selectedTool.value;

              // If shape tool is active, panel sits higher to make room for FloatingShapeSelector
              final double bottomOffset = (activeTool == DrawingTool.shape)
                  ? 144
                  : 96;

              return Positioned(
                bottom: bottomOffset,
                left: 16,
                right: 16,
                child: ContextualToolPanel(controller: controller),
              );
            }),

            // ── Layer 6: Floating Shape Selector Pill ──
            Obx(() {
              final activeTool = controller.selectedTool.value;
              final isVisible = activeTool == DrawingTool.shape;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                bottom: isVisible ? 82 : -100,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: isVisible ? 1.0 : 0.0,
                  child: const FloatingShapeSelector(),
                ),
              );
            }),

            // ── Layer 7: Layer Panel (bottom-right) ──
            Obx(() {
              if (controller.isLayerPanelVisible.value) {
                return Positioned(
                  bottom: 100,
                  right: 16,
                  child: LayerPanel(controller: controller),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: GlassContainer(
              blurSigma: 15.0,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Hapus Progres?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tindakan ini akan menghapus seluruh objek gambar di semua layer secara permanen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.clearAllProgress();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'Hapus',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
