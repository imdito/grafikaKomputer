import 'package:get/get.dart';
import 'shape_controller.dart';

class ShapeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShapeController>(() => ShapeController());
  }
}
