import 'package:get/get.dart';
import 'point_controller.dart';

class PointBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PointController>(() => PointController());
  }
}
