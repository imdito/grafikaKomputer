import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../app/modules/home/controllers/home_controller.dart';

/// Komponen untuk memilih warna primer gambar.
class ColorPickerView extends StatelessWidget {
  const ColorPickerView({super.key, required this.controller});

  /// Referensi ke HomeController
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        const Text('Warna:'),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                Color currentColor = controller.selectedColor.value;
                return AlertDialog(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  title: const Text('Pilih Warna', style: TextStyle(color: Colors.white)),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: currentColor,
                      onColorChanged: (color) {
                        currentColor = color;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Simpan'),
                      onPressed: () {
                        controller.changeColor(currentColor);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: controller.selectedColor.value,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueGrey, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
