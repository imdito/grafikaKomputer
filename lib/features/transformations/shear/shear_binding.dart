import 'package:get/get.dart';
import 'shear_controller.dart';

class ShearBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShearController>(() => ShearController());
  }
}
