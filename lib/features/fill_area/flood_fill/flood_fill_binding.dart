import 'package:get/get.dart';
import 'flood_fill_controller.dart';

class FloodFillBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FloodFillController>(() => FloodFillController());
  }
}
