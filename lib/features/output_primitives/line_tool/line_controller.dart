import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/models/canvas_models.dart';
import '../../../app/modules/home/controllers/home_controller.dart';

/// Controller managing the state and logic for the Line Tool.
class LineController extends GetxController {
  final x1Controller = TextEditingController();
  final y1Controller = TextEditingController();
  final x2Controller = TextEditingController();
  final y2Controller = TextEditingController();

  final selectedAlgorithm = LineAlgorithm.dda.obs;
  final errorMessage = RxnString();

  @override
  void onClose() {
    x1Controller.dispose();
    y1Controller.dispose();
    x2Controller.dispose();
    y2Controller.dispose();
    super.onClose();
  }

  void changeAlgorithm(LineAlgorithm algorithm) {
    selectedAlgorithm.value = algorithm;
  }

  /// Parses the user input and dispatches the line creation to the canvas service.
  void addLineFromInput() {
    final x1 = double.tryParse(x1Controller.text);
    final y1 = double.tryParse(y1Controller.text);
    final x2 = double.tryParse(x2Controller.text);
    final y2 = double.tryParse(y2Controller.text);

    if (x1 == null || y1 == null || x2 == null || y2 == null) {
      errorMessage.value = 'Masukkan nilai X1, Y1, X2, dan Y2 berupa angka.';
      return;
    }

    // Clear previous errors
    errorMessage.value = null;

    final start = Offset(x1, y1);
    final end = Offset(x2, y2);
    final algorithm = selectedAlgorithm.value;

    // Dispatch to the new Canvas Layer Architecture
    Get.find<HomeController>().addLine(start: start, end: end, algorithm: algorithm);
    
    debugPrint('Line Applied: $start to $end using $algorithm');

    x1Controller.clear();
    y1Controller.clear();
    x2Controller.clear();
    y2Controller.clear();
  }
}
