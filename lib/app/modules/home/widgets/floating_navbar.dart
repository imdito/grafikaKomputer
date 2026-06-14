import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

/// Navbar melayang yang berisi menu utama dan aksi kanvas (Export, Undo, Hapus).
class FloatingNavbar extends StatelessWidget {
  const FloatingNavbar({
    super.key,
    required this.controller,
    required this.onShowMenu,
  });

  /// Referensi ke HomeController
  final HomeController controller;
  
  /// Callback ketika tombol "Menu" ditekan
  final VoidCallback onShowMenu;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: controller.isNavbarVisible.value ? Offset.zero : const Offset(0, -1.5),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: controller.isNavbarVisible.value ? 1.0 : 0.0,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: onShowMenu,
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Menu'),
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Export',
                    onPressed: controller.exportCanvas,
                    icon: const Icon(Icons.ios_share, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Undo',
                    onPressed: controller.undoLast,
                    icon: const Icon(Icons.undo, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Hapus',
                    onPressed: controller.clearCanvas,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Sembunyikan',
                    onPressed: () => controller.isNavbarVisible.value = false,
                    icon: const Icon(Icons.expand_less, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
