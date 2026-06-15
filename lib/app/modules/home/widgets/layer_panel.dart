import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/models/canvas_layer.dart';
import 'package:final_project_flutter/app/data/grafkom_theme.dart';
import 'glass/glass_container.dart';

class LayerPanel extends StatelessWidget {
  const LayerPanel({super.key, required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 400,
      child: GlassContainer(
        blurSigma: GrafkomTheme.blurModal,
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top Header ──
            Row(
              children: [
                const Text(
                  'Layers',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  color: Colors.transparent,
                  elevation: 0,
                  offset: const Offset(-20, 30),
                  onSelected: (value) {
                    if (value == 'delete') {
                      if (controller.layers.length > 1) {
                        final idx = controller.activeLayerIndex.value;
                        controller.layers.removeAt(idx);
                        if (controller.activeLayerIndex.value >= controller.layers.length) {
                          controller.activeLayerIndex.value = controller.layers.length - 1;
                        }
                      }
                    } else if (value == 'rename') {
                      _showRenameDialog(context, controller);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      enabled: false,
                      padding: EdgeInsets.zero,
                      child: GlassContainer(
                        blurSigma: GrafkomTheme.blurModal,
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context, 'rename');
                              },
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('Rename Layer', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.1),
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            InkWell(
                              onTap: () {
                                if (controller.layers.length > 1) {
                                  Navigator.pop(context, 'delete');
                                }
                              },
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: controller.layers.length > 1 ? Colors.redAccent : Colors.white24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Delete Layer',
                                      style: TextStyle(
                                        color: controller.layers.length > 1 ? Colors.redAccent : Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Layer List ──
            Expanded(
              child: Obx(() {
                return ReorderableListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.layers.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final activeLayerObj = controller.layers[controller.activeLayerIndex.value];
                    
                    final item = controller.layers.removeAt(oldIndex);
                    controller.layers.insert(newIndex, item);
                    
                    controller.activeLayerIndex.value = controller.layers.indexOf(activeLayerObj);
                  },
                  itemBuilder: (context, index) {
                    final layer = controller.layers[index];
                    final isActive = controller.activeLayerIndex.value == index;

                    return Container(
                      key: ValueKey(layer.id),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.activeLayerIndex.value = index;
                              controller.selectedObject.value = null;
                            },
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isActive ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    CustomPaint(
                                      painter: _CheckerboardPainter(),
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.layers_outlined,
                                        color: Colors.black.withValues(alpha: 0.3),
                                        size: 32,
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            layer.isVisible = !layer.isVisible;
                                            controller.layers.refresh();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              layer.isVisible
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              size: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            layer.name,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white70,
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            // ── Add Layer Button ──
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                int maxId = 0;
                for (var layer in controller.layers) {
                  if (layer.id > maxId) maxId = layer.id;
                }
                final newId = maxId + 1;
                controller.layers.insert(0, CanvasLayer(id: newId, name: 'Layer $newId'));
                controller.activeLayerIndex.value = 0;
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, HomeController controller) {
    if (controller.layers.isEmpty) return;
    final activeLayer = controller.layers[controller.activeLayerIndex.value];
    final textController = TextEditingController(text: activeLayer.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
          ),
          title: const Text('Rename Layer', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new layer name',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            ),
            autofocus: true,
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) {
                activeLayer.name = val.trim();
                controller.layers.refresh();
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.trim().isNotEmpty) {
                  activeLayer.name = textController.text.trim();
                  controller.layers.refresh();
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    const double squareSize = 6.0;
    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final isEvenRow = (y / squareSize).floor() % 2 == 0;
        final isEvenCol = (x / squareSize).floor() % 2 == 0;
        paint.color = (isEvenRow == isEvenCol)
            ? Colors.white.withValues(alpha: 0.8)
            : Colors.grey.shade300;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
