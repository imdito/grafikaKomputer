import 'package:get/get.dart';
import 'pen_controller.dart';

class PenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PenController>(() => PenController());
  }
}
