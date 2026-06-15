import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/modules/home/controllers/home_controller.dart';
import 'rotate/rotate_controller.dart';
import 'scale/scale_controller.dart';
import 'shear/shear_controller.dart';
import 'translate/translate_controller.dart';
import '../../../app/modules/home/widgets/inputs/common_inputs.dart';

/// Panel untuk melakukan operasi transformasi (Translasi, Skala, Rotasi, Pencerminan).
class TransformationsHubView extends StatefulWidget {
  const TransformationsHubView({
    super.key,
    required this.controller,
    required this.enabled,
  });

  /// Referensi ke HomeController
  final HomeController controller;

  /// Apakah panel ini aktif (dapat diinteraksi)
  final bool enabled;

  @override
  State<TransformationsHubView> createState() => _TransformationsHubViewState();
}

class _TransformationsHubViewState extends State<TransformationsHubView> {
  String _activeTab = 'Translasi';

  final List<Map<String, dynamic>> _tabs = [
    {'name': 'Translasi', 'icon': Icons.open_with},
    {'name': 'Skala', 'icon': Icons.aspect_ratio},
    {'name': 'Rotasi', 'icon': Icons.rotate_right},
    {'name': 'Shear', 'icon': Icons.format_italic},
    {'name': 'Cermin', 'icon': Icons.flip},
  ];

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TranslateController>() ||
        !Get.isRegistered<ScaleController>() ||
        !Get.isRegistered<RotateController>() ||
        !Get.isRegistered<ShearController>()) {
      return const SizedBox();
    }

    final translateController = Get.find<TranslateController>();
    final scaleController = Get.find<ScaleController>();
    final rotateController = Get.find<RotateController>();
    final shearController = Get.find<ShearController>();

    return Obx(() {
      final isSelected = widget.controller.selectedObject.value != null;
      if (!isSelected) {
        return Column(
          children: const [
            Icon(Icons.touch_app, size: 32, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Pilih objek terlebih dahulu untuk melakukan transformasi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ],
        );
      }

      return Opacity(
        opacity: widget.enabled ? 1 : 0.55,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Operasi Transformasi',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              // Horizontal Tab bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _tabs.map((tab) {
                    final isTabSelected = _activeTab == tab['name'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(tab['name']),
                        avatar: Icon(
                          tab['icon'] as IconData,
                          size: 14,
                          color: isTabSelected ? Colors.white : Colors.white70,
                        ),
                        selected: isTabSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activeTab = tab['name'];
                            });
                          }
                        },
                        labelStyle: TextStyle(
                          color: isTabSelected ? Colors.white : Colors.white70,
                          fontWeight: isTabSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        selectedColor: Colors.white.withValues(alpha: 0.15),
                        side: BorderSide(
                          color: isTabSelected ? Colors.white30 : Colors.white10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Tab content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildTabContent(
                  translateController,
                  scaleController,
                  rotateController,
                  shearController,
                ),
              ),

              const Divider(height: 32, color: Colors.white24),
              SizedBox(
                width: double.infinity,
                child: _buildGlassButton(
                  label: 'Hapus Objek',
                  icon: Icons.delete_outline,
                  color: Colors.redAccent,
                  onTap: widget.controller.deleteSelectedObject,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabContent(
    TranslateController translateController,
    ScaleController scaleController,
    RotateController rotateController,
    ShearController shearController,
  ) {
    switch (_activeTab) {
      case 'Translasi':
        return Column(
          key: const ValueKey('Translasi'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geser posisi objek secara horizontal (X) dan vertikal (Y).',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: translateController.translateXController,
                    label: 'Translasi X',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumberField(
                    controller: translateController.translateYController,
                    label: 'Translasi Y',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _buildGlassButton(
                label: 'Terapkan Translasi',
                icon: Icons.open_with,
                onTap: translateController.applyTranslation,
              ),
            ),
          ],
        );
      case 'Skala':
        return Column(
          key: const ValueKey('Skala'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubah ukuran objek terhadap sumbu X dan Y.',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: scaleController.scaleXController,
                    label: 'Skala X',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumberField(
                    controller: scaleController.scaleYController,
                    label: 'Skala Y',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _buildGlassButton(
                label: 'Terapkan Skala',
                icon: Icons.aspect_ratio,
                onTap: scaleController.applyScale,
              ),
            ),
          ],
        );
      case 'Rotasi':
        return Column(
          key: const ValueKey('Rotasi'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Putar objek berdasarkan derajat sudut (searah jarum jam).',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: rotateController.degreeController,
                    label: 'Derajat (°)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _buildGlassButton(
                label: 'Terapkan Rotasi',
                icon: Icons.rotate_right,
                onTap: rotateController.applyRotation,
              ),
            ),
          ],
        );
      case 'Shear':
        return Column(
          key: const ValueKey('Shear'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan efek kemiringan objek pada sumbu X atau Y.',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumberField(
                    controller: shearController.shearXController,
                    label: 'Shear X',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumberField(
                    controller: shearController.shearYController,
                    label: 'Shear Y',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _buildGlassButton(
                label: 'Terapkan Shear',
                icon: Icons.format_italic,
                onTap: shearController.applyShear,
              ),
            ),
          ],
        );
      case 'Cermin':
        return Column(
          key: const ValueKey('Cermin'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cerminkan objek secara lokal maupun global.',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 16),
            Text(
              'Lokal (Terhadap Pusat Objek):',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scaleController.reflectHorizontal,
                    icon: const Icon(Icons.swap_horiz, size: 14),
                    label: const Text('Kiri-Kanan', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scaleController.reflectVertical,
                    icon: const Icon(Icons.swap_vert, size: 14),
                    label: const Text('Atas-Bawah', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Global (Terhadap Sumbu Canvas):',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scaleController.mirrorGlobalY,
                    icon: const Icon(Icons.align_horizontal_center, size: 14),
                    label: const Text('Sumbu Y', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: scaleController.mirrorGlobalX,
                    icon: const Icon(Icons.align_vertical_center, size: 14),
                    label: const Text('Sumbu X', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: scaleController.mirrorGlobalOrigin,
                icon: const Icon(Icons.filter_tilt_shift, size: 14),
                label: const Text('Pusat Canvas (0,0)', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildGlassButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
