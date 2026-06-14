import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/control_panel.dart';
import '../widgets/floating_object_editor.dart';
import '../widgets/canvas_overlays.dart';
import '../widgets/floating_navbar.dart';
import '../widgets/interactive_canvas.dart';

/// Halaman utama aplikasi yang menampilkan canvas gambar, panel kontrol,
/// dan menu melayang.
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  /// Ukuran virtual dari canvas gambar
  static const _canvasSize = Size(2400, 1800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Latar belakang dan interaksi gambar
          Positioned.fill(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: InteractiveCanvas(
                controller: controller,
                canvasSize: _canvasSize,
              ),
            ),
          ),
          
          // Petunjuk/hint UI (Kursor dan panduan mode saat ini)
          Positioned.fill(
            child: IgnorePointer(
              child: CanvasHint(controller: controller),
            ),
          ),
          
          // Tombol navbar aksi (Export, Undo, Hapus, Sembunyikan)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingNavbar(
                controller: controller,
                onShowMenu: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ControlPanel(controller: controller),
                  );
                },
              ),
            ),
          ),

          // Tombol mengembalikan menu jika disembunyikan
          Positioned(
            top: 16,
            left: 16,
            child: Obx(
              () => controller.isNavbarVisible.value
                  ? const SizedBox()
                  : IconButton.filledTonal(
                      tooltip: 'Tampilkan Menu',
                      onPressed: () => controller.isNavbarVisible.value = true,
                      icon: const Icon(Icons.expand_more),
                    ),
            ),
          ),

          // Editor properti objek yang muncul saat memilih garis/bentuk 2D
          Obx(() {
            if (controller.selectedObject.value != null) {
              return Positioned(
                top: 80,
                right: 16,
                child: FloatingObjectEditor(controller: controller),
              );
            }
            return const SizedBox();
          }),
        ],
      ),
    );
  }
}
