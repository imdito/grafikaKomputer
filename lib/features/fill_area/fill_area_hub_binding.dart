import 'package:get/get.dart';
import 'fill_area_hub_controller.dart';
import 'flood_fill/flood_fill_binding.dart';

class FillAreaHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FillAreaHubController>(() => FillAreaHubController());
    FloodFillBinding().dependencies();
  }
}
