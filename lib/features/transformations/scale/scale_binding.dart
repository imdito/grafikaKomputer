import 'package:get/get.dart';
import 'scale_controller.dart';

class ScaleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScaleController>(() => ScaleController());
  }
}
