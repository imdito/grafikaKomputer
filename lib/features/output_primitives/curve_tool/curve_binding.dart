import 'package:get/get.dart';
import 'curve_controller.dart';

/// Binding untuk menginisialisasi CurveController.
class CurveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CurveController>(() => CurveController());
  }
}
