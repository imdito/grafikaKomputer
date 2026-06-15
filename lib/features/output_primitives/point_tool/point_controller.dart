import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/modules/home/controllers/home_controller.dart';

class PointController extends GetxController {
  final xController = TextEditingController();
  final yController = TextEditingController();
  final radiusController = TextEditingController(text: '6');

  final errorMessage = RxnString();

  @override
  void onClose() {
    xController.dispose();
    yController.dispose();
    radiusController.dispose();
    super.onClose();
  }

  void addPointFromInput() {
    final x = double.tryParse(xController.text);
    final y = double.tryParse(yController.text);
    final r = double.tryParse(radiusController.text);

    if (x == null || y == null || r == null) {
      errorMessage.value = 'Masukkan nilai X, Y, dan Radius berupa angka.';
      return;
    }

    errorMessage.value = null;

    final homeController = Get.find<HomeController>();
    homeController.addPoint(
      position: Offset(x, y),
      radius: r,
    );

    xController.clear();
    yController.clear();
  }
}
