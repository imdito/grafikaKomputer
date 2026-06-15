import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/modules/home/controllers/home_controller.dart';

/// Controller untuk mengelola keadaan dan input pada Curve Tool.
class CurveController extends GetxController {
  final x1Controller = TextEditingController();
  final y1Controller = TextEditingController();
  final xcController = TextEditingController();
  final ycController = TextEditingController();
  final x2Controller = TextEditingController();
  final y2Controller = TextEditingController();

  final errorMessage = RxnString();

  @override
  void onClose() {
    x1Controller.dispose();
    y1Controller.dispose();
    xcController.dispose();
    ycController.dispose();
    x2Controller.dispose();
    y2Controller.dispose();
    super.onClose();
  }

  /// Menambahkan kurva berdasarkan koordinat manual yang diinput pengguna.
  void addCurveFromInput() {
    final x1 = double.tryParse(x1Controller.text);
    final y1 = double.tryParse(y1Controller.text);
    final xc = double.tryParse(xcController.text);
    final yc = double.tryParse(ycController.text);
    final x2 = double.tryParse(x2Controller.text);
    final y2 = double.tryParse(y2Controller.text);

    if (x1 == null || y1 == null || xc == null || yc == null || x2 == null || y2 == null) {
      errorMessage.value = 'Lengkapi semua koordinat X1, Y1, XC, YC, X2, Y2 berupa angka.';
      return;
    }

    errorMessage.value = null;

    final start = Offset(x1, y1);
    final control = Offset(xc, yc);
    final end = Offset(x2, y2);

    Get.find<HomeController>().addCurve(start: start, control: control, end: end);

    x1Controller.clear();
    y1Controller.clear();
    xcController.clear();
    ycController.clear();
    x2Controller.clear();
    y2Controller.clear();
  }
}
