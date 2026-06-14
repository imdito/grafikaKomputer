import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../controllers/home_controller.dart';

/// Komponen untuk memilih warna primer gambar.
class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key, required this.controller});

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
                  title: const Text('Pilih Warna'),
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
